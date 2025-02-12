# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under both the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree and the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree.

load("@prelude//decls:test_common.bzl", "test_common")
load(":common.bzl", "CxxRuntimeType", "CxxSourceType", "HeadersAsRawHeadersMode", "LinkableDepType", "buck", "prelude_rule")
load(":cxx_common.bzl", "cxx_common")
load(":native_common.bzl", "native_common")
load(":python_common.bzl", "python_common")

NativeLinkStrategy = ["separate", "merged"]

def _typing_arg():
    return {
        "py_version_for_type_checking": attrs.option(attrs.string(), default = None, doc = """
    This option will force the type checker to perform checking under a specific version of Python interpreter.
"""),
        "shard_typing": attrs.option(attrs.bool(), default = None, doc = """
    Determines if sharding should be enabled on a given target.
"""),
        # NOTE(grievejia): Setting default to True here may have non-trivial impact on build memory
        # usage (see S395002)
        "typing": attrs.bool(default = False, doc = """
    Determines whether to perform type checking on the given target. Default is False.
"""),
    }

cxx_python_extension = prelude_rule(
    name = "cxx_python_extension",
    docs = """
        A `cxx_python_extension()` rule is a variant of a C/C++ library which is built as a Python module. As such,
        it has a module name formed by the `base_module` parameter and the rule name.
    """,
    examples = """
        ```

        # A rule that builds a Python extension from a single .cpp file.
        cxx_python_extension(
          name = 'mymodule',
          base_module = 'foo.bar',
          srcs = [
            'mymodule.cpp',
          ],
        )

        # A library rule which has a single source importing the above extension.
        python_library(
          name = 'utils',
          srcs = [
            'utils.py',
          ],
          deps = [
            ':mymodule',
          ],
        )

        ```

        ```

        ## The `utils.py` source, wrapped by the `utils` rule above.

        ## Import the C/C++ extension build above.
        from foo.bar import mymodule

        ...

        ```
    """,
    further = None,
    attrs = (
        # @unsorted-dict-items
        buck.labels_arg() |
        python_common.base_module_arg() |
        cxx_common.srcs_arg() |
        cxx_common.deps_arg() |
        cxx_common.platform_srcs_arg() |
        cxx_common.headers_arg() |
        cxx_common.platform_headers_arg() |
        cxx_common.header_namespace_arg() |
        cxx_common.preprocessor_flags_arg() |
        cxx_common.platform_preprocessor_flags_arg() |
        cxx_common.compiler_flags_arg() |
        cxx_common.platform_compiler_flags_arg() |
        {
            "link_style": attrs.option(attrs.enum(LinkableDepType), default = None, doc = """
                Determines whether to build and link this rule's dependencies statically or dynamically.
                 Can be either `static`, `static_pic` or `shared`.
                 Note: since shared libraries re-export its dependencies, depending on multiple shared libraries
                 which themselves have overlapping static dependencies may cause problems if they init using global state.
            """),
        } |
        cxx_common.linker_extra_outputs_arg() |
        cxx_common.linker_flags_arg() |
        cxx_common.local_linker_flags_arg() |
        cxx_common.platform_linker_flags_arg() |
        {
            "contacts": attrs.list(attrs.string(), default = []),
            "cxx_runtime_type": attrs.option(attrs.enum(CxxRuntimeType), default = None),
            "default_host_platform": attrs.option(attrs.configuration_label(), default = None),
            "default_platform": attrs.option(attrs.string(), default = None),
            "defaults": attrs.dict(key = attrs.string(), value = attrs.string(), sorted = False, default = {}),
            "executable_name": attrs.option(attrs.string(), default = None),
            "frameworks": attrs.list(attrs.string(), default = []),
            "headers_as_raw_headers_mode": attrs.option(attrs.enum(HeadersAsRawHeadersMode), default = None),
            "include_directories": attrs.set(attrs.string(), sorted = True, default = []),
            "lang_compiler_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.arg()), sorted = False, default = {}),
            "lang_platform_compiler_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg()))), sorted = False, default = {}),
            "lang_platform_preprocessor_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg()))), sorted = False, default = {}),
            "lang_preprocessor_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.arg()), sorted = False, default = {}),
            "libraries": attrs.list(attrs.string(), default = []),
            "licenses": attrs.list(attrs.source(), default = []),
            "module_name": attrs.option(attrs.string(), default = None),
            "platform_deps": attrs.list(attrs.tuple(attrs.regex(), attrs.set(attrs.dep(), sorted = True)), default = []),
            "post_linker_flags": attrs.list(attrs.arg(anon_target_compatible = True), default = []),
            "post_platform_linker_flags": attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg(anon_target_compatible = True))), default = []),
            "precompiled_header": attrs.option(attrs.source(), default = None),
            "prefix_header": attrs.option(attrs.source(), default = None),
            "raw_headers": attrs.set(attrs.source(), sorted = True, default = []),
            "type_stub": attrs.option(attrs.source(), default = None),
        }
    ),
)

prebuilt_python_library = prelude_rule(
    name = "prebuilt_python_library",
    docs = """
        A `prebuilt_python_library()` rule is used to include prebuilt python packages into the output of a
        top-level `python_binary()` or `python_test()` rule.


        These prebuilt libraries can either be [whl files](https://www.python.org/dev/peps/pep-0427/) or eggs


        whls for most packages are available for download from [PyPI](https://pypi.org). The whl used may be
        downloaded with `remote_file()`. However, Buck does not attempt to infer dependency information from pip,
        so that information will have to be imparted by the user.


        To create an egg for a package, run `python setup.py bdist_egg` in the package source distribution.
    """,
    examples = """
        ```

        # A simple prebuilt_python_library with no external dependencies.
        remote_file(
          name = "requests-download",
          url = "https://files.pythonhosted.org/packages/51/bd/23c926cd341ea6b7dd0b2a00aba99ae0f828be89d72b2190f27c11d4b7fb/requests-2.22.0-py2.py3-none-any.whl",
          sha1 = "e1fc28120002395fe1f2da9aacea4e15a449d9ee",
          out = "requests-2.22.0-py2.py3-none-any.whl",
        )

        prebuilt_python_library(
          name = "requests",
          binary_src = ":requests-download",
        )

        # A slightly more complex example
        prebuilt_python_library(
          name = "greenlet",
          binary_src = "greenlet-0.4.7-py2.7-macosx-10.10-x86_64.egg",
        )

        prebuilt_python_library(
          name = "gevent",
          binary_src = "gevent-1.0.2-py2.7-macosx-10.10-x86_64.egg",
          deps = [
            ":greenlet",
          ],
        )

        ```
    """,
    further = None,
    attrs = (
        # @unsorted-dict-items
        buck.labels_arg() |
        {
            "binary_src": attrs.source(doc = """
                The path to the `.whl` or `.egg` to use.

                 Note: `.egg` files have a very particular naming convention
                 that must be followed - otherwise it will not be found at runtime!
            """),
            "deps": attrs.list(attrs.dep(), default = [], doc = """
                Other `prebuilt_python_library()` rules which this library depends on. These may also
                 be `python_library` rules if you want to depend on a source-based copy of the library.
            """),
        } |
        python_common.exclude_deps_from_merged_linking_arg() |
        {
            "compile": attrs.bool(default = False),
            "contacts": attrs.list(attrs.string(), default = []),
            "cxx_header_dirs": attrs.option(attrs.list(attrs.string()), default = None),
            "infer_cxx_header_dirs": attrs.bool(default = False),
            "default_host_platform": attrs.option(attrs.configuration_label(), default = None),
            "ignore_compile_errors": attrs.bool(default = False),
            "licenses": attrs.list(attrs.source(), default = []),
            "strip_soabi_tags": attrs.bool(
                default = False,
                doc = """
                    Strip the SOABI tags from extensions in the prebuilt library.

                    Note that this should be considered unsafe, as it removes builtin
                    protections that fail fast when a potententially incompatible
                    native extension is imported.
                """,
            ),
        }
    ),
)

python_binary = prelude_rule(
    name = "python_binary",
    docs = """
        A `python_binary()` rule is used to build an executable Python package
        that includes Python sources and resources from all transitive
        dependencies.
    """,
    examples = """
        Build an executable from the Python files in the BUCK directory.


        ```

        # BUCK

        python_binary(
          name = 'tailer',
          main_module = 'tailer',
          deps = [
            ':tailerutils',
          ],
        )

        python_library(
          name = 'tailerutils',
          # The main module, tailer.py, is specified here.
          # (Separated out from the glob pattern for clarity.)
          srcs = glob(['tailer.py', '*.py']),
        )

        ```
    """,
    further = None,
    attrs = (
        # @unsorted-dict-items
        buck.labels_arg() |
        {
            "main_module": attrs.option(attrs.string(), default = None, doc = """
                The python module that should be the entry point of the binary. This should be
                 a module name within a `python_library` that this binary depends on. Note that
                 module names take `base_module` of the library into account.
                 This property is mutually exclusive with `main`, and should be preferred to `main`, which is deprecated.
            """),
            "main": attrs.option(attrs.source(), default = None, doc = """
                The Python file which serves as the entry point for the binary.
                 The interpreter initiates execution of the binary with the code in this file.
            """),
            "base_module": attrs.option(attrs.string(), default = None, doc = """
                The package in which the main module should reside in its final
                 location in the binary. If unset, Buck uses the project-relative directory
                 that contains the BUCK file.
            """),
        } |
        python_common.platform_arg() |
        {
            "deps": attrs.list(attrs.dep(), default = [], doc = """
                A list of `python_library()` rules that specify Python
                 modules to include in the binary — including all transitive
                 dependencies of these rules.
            """),
        } |
        python_common.version_selections_arg() |
        python_common.preload_deps_arg() |
        python_common.package_style_arg() |
        python_common.linker_flags_arg() |
        python_common.deduplicate_merged_link_roots() |
        native_common.link_group_deps() |
        native_common.link_group_public_deps_label() |
        {
            "build_args": attrs.list(attrs.arg(), default = []),
            "compile": attrs.option(attrs.bool(), default = None),
            "contacts": attrs.list(attrs.string(), default = []),
            "default_host_platform": attrs.option(attrs.configuration_label(), default = None),
            "dummy_omnibus": attrs.option(attrs.dep(), default = None),
            "extension": attrs.option(attrs.string(), default = None),
            "licenses": attrs.list(attrs.source(), default = []),
            "native_link_strategy": attrs.option(attrs.enum(NativeLinkStrategy), default = None),
            "platform_deps": attrs.list(attrs.tuple(attrs.regex(), attrs.set(attrs.dep(), sorted = True)), default = []),
            "platform_linker_flags": attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg(anon_target_compatible = True))), default = []),
            "platform_preload_deps": attrs.list(attrs.tuple(attrs.regex(), attrs.set(attrs.dep(), sorted = False)), default = []),
            "repl_only_deps": attrs.list(attrs.dep(), default = []),
            "repl_main": attrs.option(attrs.string(), default = None),
            "prefer_stripped_native_objects": attrs.bool(default = False),
            "zip_safe": attrs.option(attrs.bool(), default = None),
        } |
        buck.allow_cache_upload_arg() |
        _typing_arg()
    ),
)

python_library = prelude_rule(
    name = "python_library",
    docs = """
        A `python_library()` rule is used to group together Python
        source files and resources to be passed together in as a `dep` of other rules.
    """,
    examples = """
        Include Python source files and resource files.


        ```

        # BUCK

        # A rule that includes a single Python file.
        python_library(
          name = 'fileutil',
          srcs = ['fileutil.py'],
          deps = [
            '//third_party/python-magic:python-magic',
          ],
        )

        # A rule that uses glob() to include all Python source files in the
        # directory in which the rule is defined. The rule also specifies a
        # resource file that gets packaged with the source file.
        python_library(
          name = 'testutil',
          srcs = glob(['testutil/**/*.py']),
          resources = [
            'testdata.dat',
          ],
        )

        ```
    """,
    further = None,
    attrs = (
        # @unsorted-dict-items
        buck.labels_arg() |
        python_common.srcs_arg() |
        python_common.platform_srcs_arg() |
        python_common.resources_arg() |
        python_common.platform_resources_arg() |
        python_common.base_module_arg() |
        {
            "deps": attrs.list(attrs.dep(), default = [], doc = """
                Other `python_library()` rules that list `srcs` from
                 which this rule imports modules.
            """),
        } |
        python_common.exclude_deps_from_merged_linking_arg() |
        {
            "contacts": attrs.list(attrs.string(), default = []),
            "default_host_platform": attrs.option(attrs.configuration_label(), default = None),
            "ignore_compile_errors": attrs.bool(default = False),
            "licenses": attrs.list(attrs.source(), default = []),
            "platform": attrs.option(attrs.string(), default = None),
            "platform_deps": attrs.list(attrs.tuple(attrs.regex(), attrs.set(attrs.dep(), sorted = True)), default = []),
            "type_stubs": attrs.named_set(attrs.source(), sorted = True, default = []),
            "versioned_resources": attrs.option(attrs.versioned(attrs.named_set(attrs.source(), sorted = True)), default = None),
            "versioned_srcs": attrs.option(attrs.versioned(attrs.named_set(attrs.source(), sorted = True)), default = None),
            "zip_safe": attrs.option(attrs.bool(), default = None),
        } |
        _typing_arg()
    ),
)

python_test = prelude_rule(
    name = "python_test",
    docs = """
        A `python_test()` rule defines a set of `.py` files that contain tests to run via the [Python unit testing framework](https://docs.python.org/library/unittest.html).


         If your test requires static files you should specify these in
         the **resources** or **platform\\_resources** arguments.
         If you do not specify these files, they won't be available when your
         test runs.
    """,
    examples = """
        ```

        # A rule that includes a single .py file containing tests.
        python_test(
          name = 'fileutil_test',
          srcs = ['fileutil_tests.py'],
          deps = [
            ':fileutil',
          ],
        )

        # A rule that uses glob() to include all sources in the directory which the
        # rule is defined.  It also lists a resource file that gets packaged with
        # the sources in this rule.
        python_library(
          name = 'fileutil',
          srcs = glob(['fileutil/**/*.py']),
          resources = [
            'testdata.dat',
          ],
        )

        ```
    """,
    further = None,
    attrs = (
        # @unsorted-dict-items
        buck.inject_test_env_arg() |
        buck.labels_arg() |
        python_common.srcs_arg() |
        python_common.platform_srcs_arg() |
        python_common.resources_arg() |
        python_common.platform_resources_arg() |
        python_common.base_module_arg() |
        python_common.exclude_deps_from_merged_linking_arg() |
        {
            "main_module": attrs.option(attrs.string(), default = None, doc = """
                The main module used to run the tests.
                 This parameter is normally not needed, as Buck will provide a default main
                 module that runs all tests. However, you can override this with your own
                 module to perform custom initialization or command line processing. Your
                 custom module can import the standard Buck test main
                 as `__test_main__`, and can invoke it's normal main function
                 as `__test_main__.main(sys.argv)`.
            """),
        } |
        python_common.platform_arg() |
        {
            "env": attrs.dict(key = attrs.string(), value = attrs.arg(), sorted = False, default = {}, doc = """
                A map of environment names and values to set when running the test.



                 It is also possible to expand references to other rules within the **values** of
                 these environment variables, using builtin `string parameter macros`
                :

                `$(location //path/to:target)`
                Expands to the location of the output of the build rule. This
                 means that you can refer to these without needing to be aware of how
                 Buck is storing data on the disk mid-build.
            """),
            "deps": attrs.list(attrs.dep(), default = [], doc = """
                other rules used by the tests in this rule's sources.
            """),
        } |
        python_common.version_selections_arg() |
        buck.test_rule_timeout_ms() |
        python_common.package_style_arg() |
        python_common.preload_deps_arg() |
        python_common.linker_flags_arg() |
        python_common.deduplicate_merged_link_roots() |
        native_common.link_group_deps() |
        native_common.link_group_public_deps_label() |
        {
            "additional_coverage_targets": attrs.list(attrs.dep(), default = []),
            "build_args": attrs.list(attrs.arg(), default = []),
            "compile": attrs.option(attrs.bool(), default = None),
            "contacts": attrs.list(attrs.string(), default = []),
            "default_host_platform": attrs.option(attrs.configuration_label(), default = None),
            "dummy_omnibus": attrs.option(attrs.dep(), default = None),
            "extension": attrs.option(attrs.string(), default = None),
            "licenses": attrs.list(attrs.source(), default = []),
            "native_link_strategy": attrs.option(attrs.enum(NativeLinkStrategy), default = None),
            "needed_coverage": attrs.list(attrs.tuple(attrs.int(), attrs.dep(), attrs.option(attrs.string())), default = []),
            "platform_deps": attrs.list(attrs.tuple(attrs.regex(), attrs.set(attrs.dep(), sorted = True)), default = []),
            "platform_linker_flags": attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg(anon_target_compatible = True))), default = []),
            "platform_preload_deps": attrs.list(attrs.tuple(attrs.regex(), attrs.set(attrs.dep(), sorted = False)), default = []),
            "repl_only_deps": attrs.list(attrs.dep(), default = []),
            "repl_main": attrs.option(attrs.string(), default = None),
            "prefer_stripped_native_objects": attrs.bool(default = False),
            "runner": attrs.option(attrs.dep(), default = None),
            "specs": attrs.option(attrs.arg(json = True), default = None),
            "versioned_resources": attrs.option(attrs.versioned(attrs.named_set(attrs.source(), sorted = True)), default = None),
            "versioned_srcs": attrs.option(attrs.versioned(attrs.named_set(attrs.source(), sorted = True)), default = None),
            "zip_safe": attrs.option(attrs.bool(), default = None),
        } |
        _typing_arg() |
        test_common.attributes()
    ),
)

python_test_runner = prelude_rule(
    name = "python_test_runner",
    docs = "",
    examples = None,
    further = None,
    attrs = (
        # @unsorted-dict-items
        buck.labels_arg() |
        {
            "contacts": attrs.list(attrs.string(), default = []),
            "default_host_platform": attrs.option(attrs.configuration_label(), default = None),
            "licenses": attrs.list(attrs.source(), default = []),
            "main_module": attrs.string(default = ""),
            "src": attrs.source(),
        }
    ),
)

python_rules = struct(
    cxx_python_extension = cxx_python_extension,
    prebuilt_python_library = prebuilt_python_library,
    python_binary = python_binary,
    python_library = python_library,
    python_test = python_test,
    python_test_runner = python_test_runner,
)
