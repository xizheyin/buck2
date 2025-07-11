# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is dual-licensed under either the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree or the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree. You may select, at your option, one of the
# above-listed licenses.

# pyre-unsafe

import contextlib
import json
from asyncio import subprocess, wait_for
from typing import Any

from buck2.tests.e2e_util.api.process import Process


class SubscribeClient(contextlib.AbstractAsyncContextManager):
    def __init__(self, start: Process, process: subprocess.Process):
        self._start = start
        self._process = process

    @classmethod
    async def create(cls, start: Process):
        process = await start.start()
        return cls(start, process)

    @property
    def stdin(self):
        return self._process.stdin

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc, tb):
        self._process.stdin.close()
        await wait_for(
            self._start._get_result_or_raise_exception(self._process), timeout=120
        )

    async def read_message(self) -> Any:
        stdout = self._process.stdout
        assert stdout is not None
        message = await wait_for(stdout.readline(), timeout=30)
        return json.loads(message)
