# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under both the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree and the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree.

# pyre-strict


from buck2.tests.core.common.io.file_watcher import FileWatcherProvider
from buck2.tests.core.common.io.file_watcher_dir_tests import (
    run_create_directory_test,
    run_remove_directory_test,
    run_rename_directory_test,
)
from buck2.tests.core.common.io.file_watcher_file_tests import (
    run_create_file_test,
    run_modify_file_test,
    run_remove_file_test,
    run_rename_file_test,
    run_replace_file_test,
)
from buck2.tests.core.common.io.file_watcher_tests import FileSystemType

from buck2.tests.e2e_util.api.buck import Buck
from buck2.tests.e2e_util.buck_workspace import buck_test


@buck_test(setup_eden=False)
async def test_fs_hash_cralwer_create_file(buck: Buck) -> None:
    await run_create_file_test(
        buck, FileSystemType.NATIVE, FileWatcherProvider.FS_HASH_CRAWLER
    )


@buck_test(setup_eden=False)
async def test_fs_hash_cralwer_modify_file(buck: Buck) -> None:
    await run_modify_file_test(
        buck, FileSystemType.NATIVE, FileWatcherProvider.FS_HASH_CRAWLER
    )


@buck_test(setup_eden=False)
async def test_fs_hash_cralwer_remove_file(buck: Buck) -> None:
    await run_remove_file_test(
        buck, FileSystemType.NATIVE, FileWatcherProvider.FS_HASH_CRAWLER
    )


@buck_test(setup_eden=False)
async def test_fs_hash_cralwer_rename_file(buck: Buck) -> None:
    await run_rename_file_test(
        buck, FileSystemType.NATIVE, FileWatcherProvider.FS_HASH_CRAWLER
    )


# File replace is not supported on Windows
@buck_test(setup_eden=False, skip_for_os=["windows"])
async def test_fs_hash_cralwer_replace_file(buck: Buck) -> None:
    await run_replace_file_test(
        buck, FileSystemType.NATIVE, FileWatcherProvider.FS_HASH_CRAWLER
    )


@buck_test(setup_eden=False)
async def test_fs_hash_cralwer_create_directory(buck: Buck) -> None:
    await run_create_directory_test(
        buck, FileSystemType.NATIVE, FileWatcherProvider.FS_HASH_CRAWLER
    )


@buck_test(setup_eden=False)
async def test_fs_hash_cralwer_remove_directory(buck: Buck) -> None:
    await run_remove_directory_test(
        buck, FileSystemType.NATIVE, FileWatcherProvider.FS_HASH_CRAWLER
    )


@buck_test(setup_eden=False)
async def test_fs_hash_cralwer_rename_directory(buck: Buck) -> None:
    await run_rename_directory_test(
        buck, FileSystemType.NATIVE, FileWatcherProvider.FS_HASH_CRAWLER
    )
