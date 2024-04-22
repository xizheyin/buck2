/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under both the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree and the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree.
 */

/**
  * The sidebars for buck2 documentation work slightly differently than normal.
  * Normally when globbing you don't have control over any ordering (in an easy to manage way)
  * Instead, we do some processing on the manualSidebar array to remove any manually specified
  * files from the autogenerated glob, and keep the manuallly specified ones in order.
  *
  * - To specify manual ordering, just put the filename into the list of items.
  * - New sections should be in a subdirectory, and should generally end have an autogenerated
  *   item as their last item.
  * - Directories that should be excluded from sidebars should be added to the
  *   'universallyExcludedDirs' set below
  *
  * If you're curious how this works, look at `generateSidebarExclusions` and
  * `filterItems` in this module, and `sidebarItemsGenerator` in docusaurus.config.js. Note
  * that `sidebarItemsGenerator` runs for each "autogenerated" item, so that's why we
  * keep track of all globs that have been specified. We need to make sure that only things
  * in "developers/" are included in the developers glob, e.g.
  */

const { isInternal } = require("docusaurus-plugin-internaldocs-fb/internal");

const universallyExcludedDirs = new Set([
  "rfcs/",
  "legacy/",
]);

const manualSidebar = [
    'index',
  {
    type: 'category',
    label: 'About Buck2',
    items: [
      'why',
      // The getting_started page is for OSS only.
      isInternal() ? [] : 'getting_started',
      {
        type: 'category',
        label: 'Benefits',
        items: [
          'benefits',
          isInternal() ? 'testimonials' : [],
        ],
      },
      isInternal() ? 'knowledge_sharing' : [],
      'bootstrapping',
    ],
  },
  {
    type: 'category',
    label: 'Concepts',
    items: [
      'concepts/key_concepts',
      'concepts/concept_map',
      'concepts/build_rule',
      'concepts/build_file',
      'concepts/build_target',
      'concepts/target_pattern',
      'concepts/buck_out',
      'concepts/visibility',
      'concepts/daemon',
      'concepts/buckconfig',
      'concepts/configurations',
      'concepts/glossary',
    ],
  },
  {
    type: 'category',
    label: 'Buck2 Users',
    items: [
      isInternal() ? 'users/migration_guide' : [],
      {
        type: 'category',
        label: 'Commands',
        items: [
          { type: 'autogenerated', dirName: 'users/commands'},
        ],
      },
      'users/cheat_sheet',
      {
        type: 'category',
        label: 'Troubleshooting',
        items: [
          isInternal() ? 'users/faq/getting_help' : [],
          'users/faq/common_issues',
          isInternal() ? 'users/faq/meta_issues' : [],
          isInternal() ? 'users/faq/meta_installation' : [],
          isInternal() ? 'users/faq/remote_execution' : [],
          'users/faq/starlark_peak_mem',
          'users/faq/buck_hanging',
          isInternal() ? 'users/faq/how_to_bisect' : [],
          isInternal() ? 'users/faq/how_to_expedite_fix' : [],
        ],
      },
      {
        type: 'category',
        label: 'Build Observability',
        items: [
          'users/build_observability/interactive_console',
          'users/build_observability/logging',
          'users/build_observability/build_report',
          isInternal() ? 'users/build_observability/observability' : [],
          isInternal() ? 'users/build_observability/scuba' : [],
          isInternal() ? 'users/build_observability/ods' : [],
        ],
      },
      'users/remote_execution',
      {
        type: 'category',
        label: 'Queries',
        items: [
          { type: 'autogenerated', dirName: 'users/query' },
        ],
      },
      {
        type: 'category',
        label: 'Advanced Features',
        items: [
          'users/advanced/deferred_materialization',
          'users/advanced/restarter',
          'users/advanced/in_memory_cache',
          'users/advanced/external_cells',
          isInternal() ? 'users/advanced/offline_build_archives' : [],
          isInternal() ? 'users/advanced/vpnless' : [],
        ],
      },
    ],
  },
  {
    type: 'category',
    label: 'Rule Authors',
    items: [
      'rule_authors/writing_rules',
      'rule_authors/transitive_sets',
      'rule_authors/configurations',
      'rule_authors/configuration_transitions',
      'rule_authors/dynamic_dependencies',
      'rule_authors/anon_targets',
      'rule_authors/test_execution',
      'rule_authors/optimization',
      isInternal() ? 'rule_authors/rule_writing_tips' : [],
      'rule_authors/incremental_actions',
      'rule_authors/alias',
      'rule_authors/local_resources',
      'rule_authors/package_files',
      isInternal() ? 'rule_authors/client_metadata' : [],
      isInternal() ? 'rule_authors/action_error_handler' : [],
      { type: 'autogenerated', dirName: 'rule_authors' },
    ],
  },
  {
    type: 'category',
    label: 'BXL Developers',
    items:  [
      {
        type: 'category',
        label: 'About BXL',
        items: [
          'developers/bxl',
          isInternal() ? 'developers/bxl_testimonials' : [],
        ],
      },
      {
        type: 'category',
        label: 'User Guide',
        items: [
          'developers/bxl_getting_started',
          'developers/bxl_basics',
          'developers/bxl_how_tos',
          'developers/target_universe',
          'developers/bxl_telemetry',
          'developers/anon_targets',
          'developers/dynamic_output',
        ],
      },
      'developers/bxl_faqs',
      {
        type: 'category',
        label: 'BXL APIs',
        items: [
          { type: 'autogenerated', dirName: 'api/bxl' },
        ],
      },
    ],
  },
  {
    type: 'category',
    label: 'Buck2 Developers',
    items: [
      {
        type: 'category',
        label: 'Architecture',
        items: [
           'developers/architecture/buck2',
           'developers/architecture/buck1_vs_buck2',
        ],
      },
      isInternal() ? 'developers/developers' : [],
      isInternal() ? 'developers/heap_profiling' : [],
      'developers/what-ran',
      {
        type: 'category',
        label: 'Starlark Language',
        items: [
          { type: 'autogenerated', dirName: 'developers/starlark' },
        ],
      },
      'developers/request_for_comments',
      'developers/windows_cheat_sheet',
    ],
  },
  {
    type: 'category',
    label: 'API',
    link: {
      type: 'doc',
      id: 'api',
    },
    items: [
      {
        type: 'doc',
        id: 'api/rules',
        label: 'Rules',
      },
      {
        type: 'category',
        label: 'Starlark APIs',
        items: [{ type: 'autogenerated', dirName: 'api/starlark' }],
      },
      {
        type: 'category',
        label: 'Build APIs',
        items: [{ type: 'autogenerated', dirName: 'api/build' }],
      },
      {
        type: 'category',
        label: 'BXL APIs',
        items: [
          { type: 'autogenerated', dirName: 'api/bxl' },
        ],
      },
    ]
  }
]

function generateSidebarExclusions(items) {
  let excludedDirs = new Set();
  let excludedFiles = new Set();

  for (const item of items) {
    if (item["type"] === "category") {
      const [newExcludedDirs, newExcludedFiles] = generateSidebarExclusions(item.items);
      excludedDirs = new Set([...excludedDirs, ...newExcludedDirs]);
      excludedFiles = new Set([...excludedFiles, ...newExcludedFiles]);
    } else if (item["type"] === "autogenerated") {
      excludedDirs.add(item.dirName + "/");
    } else if (Array.isArray(item)) {
      const [newExcludedDirs, newExcludedFiles] = generateSidebarExclusions(item);
      excludedDirs = new Set([...excludedDirs, ...newExcludedDirs]);
      excludedFiles = new Set([...excludedFiles, ...newExcludedFiles]);
    } else {
      excludedFiles.add(item)
    }
  }

  return [excludedDirs, excludedFiles];
}

const [mainExcludedDirs, mainExcludedFiles] = generateSidebarExclusions(manualSidebar);

function itemFilter(item, docs) {
  const dirName = item.dirName + '/';
  return docs.filter((doc) => {
    if (!isInternal() && doc.source.endsWith(".fb.md")) {
      return false;
    }
    if (item.dirName != '.' && !doc.id.startsWith(dirName)) {
      return false;
    }
    if (mainExcludedFiles.has(doc.id)) {
      return false;
    }
    for (dir of universallyExcludedDirs) {
      if (doc.id.startsWith(dir)) {
        return false;
      }
    }
    for (dir of mainExcludedDirs) {
      if (dirName != dir && doc.id.startsWith(dir)) {
        return false;
      }
    }
    return true;
  });
}

function itemSort(items) {
  function is_globals(x) {
    // We want API "globals" docs to come first
    return x.id && x.id.endsWith("/globals") ? 0 : 1;
  }

  // Reverse items in categories
  const result = items.map((item) => {
    if (item.type === 'category') {
      return {...item, items: itemSort(item.items)};
    }
    return item;
  });
  // Make `globals` come first
  result.sort((a, b) => is_globals(a) - is_globals(b));
  return result;
}

module.exports = {
  itemFilter: itemFilter,
  itemSort: itemSort,
  manualSidebar: manualSidebar,
};
