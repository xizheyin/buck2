/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under both the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree and the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree.
 */

use buck2_events::dispatch::EventDispatcher;
use buck2_util::properly_reaped_child::reap_on_drop_command;
use tokio::sync::OnceCell;

/// Spawn tasks to collect version control information
/// and return a droppable handle that will cancel them on drop.
pub(crate) fn spawn_version_control_collector(dispatch: EventDispatcher) -> AbortOnDropHandle {
    AbortOnDropHandle {
        handle: tokio::spawn(async move {
            let event = create_revision_data().await;
            dispatch.instant_event(event);
        }),
    }
}

/// Abort the underlying task on drop.
pub(crate) struct AbortOnDropHandle {
    pub handle: tokio::task::JoinHandle<()>,
}

impl Drop for AbortOnDropHandle {
    fn drop(&mut self) {
        self.handle.abort();
    }
}

#[derive(Clone, Copy, Debug)]
enum RepoVcs {
    Hg,
    Git,
    Unknown,
}

async fn create_revision_data() -> buck2_data::VersionControlRevision {
    let mut revision = buck2_data::VersionControlRevision::default();
    match repo_type().await {
        Ok(repo_vcs) => {
            match repo_vcs {
                RepoVcs::Hg => {
                    if let Err(e) = add_current_revision(&mut revision).await {
                        revision.command_error = Some(e.to_string());
                    }
                    if let Err(e) = add_status_info(&mut revision).await {
                        revision.command_error = Some(e.to_string());
                    }
                }
                RepoVcs::Git => {
                    // TODO(rajneeshl): Implement the git data
                    // Add a message for now so we can actually tell if revision is null due to git
                    revision.command_error = Some("Git revision data not implemented".to_owned());
                }
                RepoVcs::Unknown => {
                    revision.command_error = Some("Unknown repository type".to_owned());
                }
            }
        }
        Err(e) => {
            revision.command_error = Some(e.to_string());
        }
    }
    revision
}

async fn add_current_revision(
    revision: &mut buck2_data::VersionControlRevision,
) -> buck2_error::Result<()> {
    // `hg whereami` returns the full hash of the revision
    let whereami_output = reap_on_drop_command("hg", &["whereami"], Some(&[("HGPLAIN", "1")]))?
        .output()
        .await;

    match whereami_output {
        Ok(result) => {
            if !result.status.success() {
                revision.command_error = Some(format!(
                    "Command `hg whereami` failed with error code {}; stderr:\n{}",
                    result.status,
                    std::str::from_utf8(&result.stderr)?
                ));
                return Ok(());
            }
            let stdout = std::str::from_utf8(&result.stdout)?.trim();
            // whereami will sometimes return multiple revisions (Possibly due to merge state not handled well)
            // This is not a common pattern (less than 1%) and the last revision should be accurate enough
            // `hg log -r . -T '{node}'`` handles this properly but it's ~40% slower, we should switch if that becomes more performant
            let last_line = stdout.split('\n').last().unwrap_or(stdout);
            if last_line.len() == 40 {
                revision.hg_revision = Some(last_line.to_owned());
            } else {
                revision.command_error = Some(format!("Unexpected revision: {}", stdout));
            }
        }
        Err(e) => {
            revision.command_error =
                Some(format!("Command `hg whereami` failed with error: {:?}", e));
        }
    };
    Ok(())
}

async fn add_status_info(
    revision: &mut buck2_data::VersionControlRevision,
) -> buck2_error::Result<()> {
    // `hg status` returns if there are any local changes
    let status_output = reap_on_drop_command("hg", &["status"], Some(&[("HGPLAIN", "1")]))?
        .output()
        .await;

    match status_output {
        Ok(result) => {
            if !result.status.success() {
                revision.command_error = Some(format!(
                    "Command `hg status` failed with error code {}; stderr:\n{}",
                    result.status,
                    std::str::from_utf8(&result.stderr)?
                ));
                return Ok(());
            }
            revision.has_local_changes =
                Some(!std::str::from_utf8(&result.stdout)?.trim().is_empty());
            return Ok(());
        }
        Err(e) => {
            revision.command_error =
                Some(format!("Command `hg status` failed with error: {:?}", e));
        }
    };
    Ok(())
}

async fn repo_type() -> buck2_error::Result<&'static RepoVcs> {
    static REPO_TYPE: OnceCell<buck2_error::Result<RepoVcs>> = OnceCell::const_new();
    async fn repo_type_impl() -> buck2_error::Result<RepoVcs> {
        let (hg_output, git_output) = tokio::join!(
            reap_on_drop_command("hg", &["root"], Some(&[("HGPLAIN", "1")]))?.output(),
            reap_on_drop_command("git", &["rev-parse", "--is-inside-work-tree"], None)?.output()
        );

        let is_hg = hg_output.is_ok_and(|output| {
            std::str::from_utf8(&output.stdout).is_ok_and(|s| !s.trim().is_empty())
        });
        let is_git = git_output.is_ok_and(|output| {
            std::str::from_utf8(&output.stdout).is_ok_and(|s| s.trim() == "true")
        });

        if is_hg {
            Ok(RepoVcs::Hg)
        } else if is_git {
            Ok(RepoVcs::Git)
        } else {
            Ok(RepoVcs::Unknown)
        }
    }
    REPO_TYPE
        .get_or_init(repo_type_impl)
        .await
        .as_ref()
        .map_err(|e| e.clone())
}
