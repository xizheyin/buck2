/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under both the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree and the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree.
 */

use buck2_core::provider::label::ConfiguredProvidersLabel;
use starlark_map::small_set::SmallSet;

use crate::attrs::configured_traversal::ConfiguredAttrTraversal;

#[derive(Default, Debug)]
pub struct ConfiguredAttrInfoForTests {
    // Including transitioned deps.
    pub deps: SmallSet<ConfiguredProvidersLabel>,
    pub execution_deps: SmallSet<ConfiguredProvidersLabel>,
}

impl ConfiguredAttrInfoForTests {
    pub fn new() -> Self {
        Self::default()
    }
}

impl ConfiguredAttrTraversal for ConfiguredAttrInfoForTests {
    fn dep(&mut self, dep: &ConfiguredProvidersLabel) -> buck2_error::Result<()> {
        self.deps.insert(dep.clone());
        Ok(())
    }

    fn exec_dep(&mut self, dep: &ConfiguredProvidersLabel) -> buck2_error::Result<()> {
        self.execution_deps.insert(dep.clone());
        Ok(())
    }
}
