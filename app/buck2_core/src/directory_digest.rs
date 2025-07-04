/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is dual-licensed under either the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree or the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree. You may select, at your option, one of the
 * above-listed licenses.
 */

use std::fmt::Debug;
use std::fmt::Display;
use std::hash::Hash;

use allocative::Allocative;
use dupe::Dupe;

pub trait DirectoryDigest:
    Allocative + PartialEq + Eq + Hash + Clone + Dupe + Debug + Display
{
}

/// Indicates that this type of digest is suitable for use for interning.
///
/// Specifically, this is not implemented for `NoDigest`, as that returns the same `()` digest for
/// all directories.
pub trait InternableDirectoryDigest: DirectoryDigest {}
