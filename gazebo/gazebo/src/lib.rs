/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is dual-licensed under either the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree or the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree. You may select, at your option, one of the
 * above-listed licenses.
 */

#![cfg_attr(feature = "str_pattern_extensions", feature(pattern))]
#![allow(clippy::too_long_first_doc_paragraph)]

//! A collection of well-tested primitives that have been useful. Most modules stand alone.

pub mod cast;
pub mod cell;
pub mod cmp;
pub(crate) mod ext;
pub mod file;
pub mod hash;
pub mod phantom;
pub mod prelude;
pub mod types;
pub mod variants;

#[cfg(test)]
mod test;
