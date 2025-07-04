# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is dual-licensed under either the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree or the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree. You may select, at your option, one of the
# above-listed licenses.

load("@prelude//:paths.bzl", "paths")
load("@prelude//java:java_toolchain.bzl", "JavaToolchainInfo")

# Infer the likely package name for the given path based on conventional
# source root components.
def get_src_package(src_root_prefixes: list[str], src_root_elements: list[str], path: str) -> str:
    for prefix in src_root_prefixes:
        if path.startswith(prefix):
            return paths.relativize(
                path,
                prefix,
            )
    parts = path.split("/")
    for i in range(len(parts) - 2, -1, -1):
        part = parts[i]
        if part in src_root_elements:
            return "/".join(parts[i + 1:])

    return path

def get_resources_map(
        java_toolchain: JavaToolchainInfo,
        package: str,
        resources: list[Artifact],
        resources_root: [str, None]) -> dict[str, Artifact]:
    # As in v1, root the resource root via the current package.
    if resources_root != None:
        resources_root = paths.normalize(paths.join(package, resources_root))

    resources_to_copy = {}
    for resource in resources:
        # Create the full resource path.
        full_resource = paths.join(
            resource.owner.package if resource.owner else package,
            resource.short_path,
        )

        # As in v1 (https://fburl.com/code/j2vwny56, https://fburl.com/code/9era0xpz),
        # if this resource starts with the resource root, relativize and insert it as
        # is.
        if resources_root != None and paths.starts_with(full_resource, resources_root):
            resource_name = paths.relativize(
                full_resource,
                resources_root,
            )
            if not resource_name:
                # Match v1 behavior: https://fburl.com/code/x7zhlz5m
                resource_name = resource.short_path
        else:
            resource_name = get_src_package(java_toolchain.src_root_prefixes, java_toolchain.src_root_elements, full_resource)
        resources_to_copy[resource_name] = resource
    return resources_to_copy

def parse_src_roots(src_roots: list[str]) -> (list[str], list[str]):
    prefixes = []
    elements = []
    for src_root in src_roots:
        if src_root.startswith("/"):
            if not src_root.endswith("/"):
                fail("Elements in java.src_roots config that begin with a / must end in one too, but {} does not".format(src_root))
            prefixes.append(src_root[1:])
        elif "/" in src_root:
            fail("No / is permitted in java.src_roots config elements, but {} has one".format(src_root))
        else:
            elements.append(src_root)

    return elements, prefixes
