/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under both the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree and the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree.
 */

mod markdown;

use async_trait::async_trait;
use buck2_cli_proto::new_generic::DocsOutputFormat;
use buck2_cli_proto::new_generic::DocsRequest;
use buck2_cli_proto::new_generic::DocsStarlarkRequest;
use buck2_client_ctx::client_ctx::ClientCommandContext;
use buck2_client_ctx::common::ui::CommonConsoleOptions;
use buck2_client_ctx::common::CommonBuildConfigurationOptions;
use buck2_client_ctx::common::CommonCommandOptions;
use buck2_client_ctx::common::CommonEventLogOptions;
use buck2_client_ctx::common::CommonStarlarkOptions;
use buck2_client_ctx::daemon::client::BuckdClientConnector;
use buck2_client_ctx::exit_result::ExitResult;
use buck2_client_ctx::streaming::StreamingCommand;
use buck2_error::BuckErrorContext;
use dupe::Dupe;

use crate::starlark::markdown::MarkdownFileOptions;

#[derive(Debug, Clone, Dupe, clap::ValueEnum)]
#[clap(rename_all = "snake_case")]
enum DocsOutputFormatArg {
    Json,
    MarkdownFiles,
}

#[derive(Debug, clap::Parser)]
#[clap(
    name = "docs-starlark",
    about = "Print documentation of user-defined starlark symbols"
)]
pub(crate) struct DocsStarlarkCommand {
    #[clap(
        name = "SYMBOL_PATTERNS",
        help = "Patterns to interpret. //foo:bar.bzl is 'every symbol in //foo:bar.bzl', //foo:bar.bzl:baz only returns the documentation for the symbol 'baz' in //foo:bar.bzl"
    )]
    patterns: Vec<String>,

    #[clap(flatten)]
    markdown_file_opts: MarkdownFileOptions,

    #[clap(
        long = "format",
        help = "how to format the returned documentation",
        default_value = "json",
        value_enum,
        ignore_case = true
    )]
    format: DocsOutputFormatArg,

    #[clap(flatten)]
    common_opts: CommonCommandOptions,
}

#[async_trait]
impl StreamingCommand for DocsStarlarkCommand {
    const COMMAND_NAME: &'static str = "docs starlark";
    async fn exec_impl(
        self,
        buckd: &mut BuckdClientConnector,
        matches: &clap::ArgMatches,
        ctx: &mut ClientCommandContext<'_>,
    ) -> ExitResult {
        let client_context = ctx.client_context(matches, &self)?;

        let format = match self.format {
            DocsOutputFormatArg::Json => DocsOutputFormat::Json,
            DocsOutputFormatArg::MarkdownFiles => {
                let p = self
                    .markdown_file_opts
                    .destination_dir
                    .as_ref()
                    .internal_error_anyhow("Args definition requires this")?
                    .resolve(&ctx.working_dir);
                DocsOutputFormat::Markdown(p)
            }
        };

        let response = buckd
            .with_flushing()
            .new_generic(
                client_context,
                buck2_cli_proto::new_generic::NewGenericRequest::Docs(DocsRequest::Starlark(
                    DocsStarlarkRequest {
                        symbol_patterns: self.patterns.clone(),
                        format,
                        markdown_starlark_subdir: self.markdown_file_opts.starlark_subdir.clone(),
                        markdown_native_subdir: self.markdown_file_opts.native_subdir.clone(),
                    },
                )),
                ctx.stdin()
                    .console_interaction_stream(&self.common_opts.console_opts),
            )
            .await??;

        let buck2_cli_proto::new_generic::NewGenericResponse::Docs(response) = response else {
            return ExitResult::bail("Unexpected response type from generic command");
        };

        if let Some(json_output) = response.json_output {
            buck2_client_ctx::println!("{}", json_output.trim_end())?;
        }

        ExitResult::success()
    }

    fn console_opts(&self) -> &CommonConsoleOptions {
        &self.common_opts.console_opts
    }

    fn event_log_opts(&self) -> &CommonEventLogOptions {
        &self.common_opts.event_log_opts
    }

    fn build_config_opts(&self) -> &CommonBuildConfigurationOptions {
        &self.common_opts.config_opts
    }

    fn starlark_opts(&self) -> &CommonStarlarkOptions {
        &self.common_opts.starlark_opts
    }
}
