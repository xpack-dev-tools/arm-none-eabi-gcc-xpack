// DO NOT EDIT!
// Automatically generated from docusaurus-template-liquid/templates/docusaurus.

/* eslint-disable */
import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
// import logger from '@docusaurus/logger';
import util from 'node:util';

import { redirects } from './docusaurus-config-redirects';
import { getCustomFields } from './customFields';

// The node.js modules cannot be used in modules imported in browser code:
// webpack < 5 used to include polyfills for node.js core modules by default.
// so the entire initialisation code must be in this file, that is
// not processed by webpack.

// ----------------------------------------------------------------------------

const customFields = getCustomFields();
console.log('customFields: ' + util.inspect(customFields));

const actualBaseUrl = process.env.DOCUSAURUS_BASEURL ??
  '/arm-none-eabi-gcc-xpack/';

// ----------------------------------------------------------------------------

const config: Config = {
  title: 'xPack GNU Arm Embedded GCC' +
    ((process.env.DOCUSAURUS_IS_PREVIEW === 'true') ? ' (preview)' : ''),
  tagline: 'A binary distribution of GNU Arm Embedded GCC',

  // Explicitly set in headTags.
  // favicon: '/img/favicon.ico',

  // Set the production url of your site here
  url: 'https://xpack-dev-tools.github.io/',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: actualBaseUrl,

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'xpack-dev-tools', // Usually your GitHub org/user name.
  projectName: 'arm-none-eabi-gcc-xpack', // Usually your repo name.

  onBrokenAnchors: 'throw',
  onBrokenLinks: 'throw',

  onDuplicateRoutes: 'throw',

  // Useful for the sitemap.xml, to avoid redirects, since
  // GitHub redirects all to trailing slash.
  trailingSlash: true,

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  markdown: {
    format: 'detect',
    hooks: {
        onBrokenMarkdownLinks: 'throw'
    }
  },

  plugins: [
    [
      // https://docusaurus.io/docs/next/api/plugins/@docusaurus/plugin-client-redirects#redirects
      '@docusaurus/plugin-client-redirects',
      redirects,
    ],
    [
      '@docusaurus/plugin-ideal-image',
      {
        quality: 70,
        max: 1030, // max resized image's size.
        min: 640, // min resized image's size. if original is lower, use that size.
        steps: 2, // the max number of images generated between min and max (inclusive)
        disableInDev: false,
      },
    ],

    // Local plugins.
    './src/plugins/SelectReleasesPlugin',
  ],

  themes: [
    // [
    //   // Explicitly required when not using `preset-classic`.
    //   // https://docusaurus.io/docs/search#using-algolia-docsearch
    //   '@docusaurus/theme-search-algolia',
    //   {
    //   }
    // ],
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: 'https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/edit/website/website/',
          // showLastUpdateAuthor: true,
          showLastUpdateTime: true,
        },
        // https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-content-blog
        blog: {
          showReadingTime: true,
          blogSidebarCount: 8,
          feedOptions: {
            type: ['rss', 'atom'],
            xslt: true,
          },
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: 'https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/edit/website/website/',
          // Useful options to enforce blogging best practices
          onInlineTags: 'warn',
          onInlineAuthors: 'warn',
          onUntruncatedBlogPosts: 'warn',
        },
        pages: {},
        // https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-google-gtag
        // https://tagassistant.google.com
        gtag: {
          trackingID: 'G-7QE5W7V05S',
          anonymizeIP: false,
        },
        // https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-sitemap
        sitemap: {
          lastmod: 'date',
          changefreq: 'weekly',
          priority: 0.5,
          ignorePatterns: [
            actualBaseUrl + 'blog/archive/**',
            actualBaseUrl + 'blog/authors/**',
            actualBaseUrl + 'blog/tags/**'
          ],
          filename: 'sitemap.xml',
        },

        debug: true,

        theme: {
          customCss: './src/css/custom.css',
        },

      } satisfies Preset.Options,
    ],
  ],

  // https://docusaurus.io/docs/api/docusaurus-config#headTags
  headTags: [
    {
      tagName: 'link',
      attributes: {
        rel: 'icon',
        type: 'image/png',
        href: actualBaseUrl + 'favicons/favicon-96x96.png',
        sizes: '96x96'
      }
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'icon',
        type: 'image/png',
        href: actualBaseUrl + 'favicons/favicon-48x48.png',
        sizes: '48x48'
      }
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'icon',
        type: 'image/svg+xml',
        href: actualBaseUrl + 'favicons/favicon.svg'
      }
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'shortcut icon',
        href: actualBaseUrl + 'favicons/favicon.ico'
      }
    },
    {
      // This might also go to themeConfig.metadata.
      tagName: 'meta',
      attributes: {
        name: 'apple-mobile-web-app-title',
        content: 'xPack'
      }
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'manifest',
        href: actualBaseUrl + 'favicons/site.webmanifest'
      }
    }
  ],

  // https://docusaurus.io/docs/seo
  themeConfig: {
    // The project's social card, og:image, twitter:image, 1200x630
    image: 'img/sunrise-og-image.jpg',

    metadata: [
      {
        name: 'keywords',
        content: 'xpack, binary, development, tools, reproducibility, arm-none-eabi-gcc'
      }
    ],
    navbar: {
      title: 'The xPack Binary Tools',

      logo: {
        alt: 'xPack Logo',
        src: 'img/logo-256.png',
        href: 'https://xpack-dev-tools.github.io/'
      },
      items: [
        {
          to: '/',
          label: 'arm-none-eabi-gcc',
          className: 'header-home-link',
          position: 'left'
        },
        {
          type: 'dropdown',
          label: 'Documentation',
          to: 'docs/getting-started',
          position: 'left',
          items: [
            {
              label: 'Getting Started',
              to: '/docs/getting-started'
            },
            {
              label: 'Installation Guide',
              to: '/docs/install'
            },
            {
              label: 'User\'s Guide',
              to: '/docs/user'
            },
            {
              label: 'Contributor\'s Guide',
              to: '/docs/developer'
            },
            {
              label: 'Maintainer\'s Guide',
              to: '/docs/maintainer'
            },
            {
              label: 'FAQ',
              to: '/docs/faq'
            },
            {
              label: 'Help Centre',
              to: '/docs/support'
            },
            {
              label: 'Releases',
              to: '/docs/releases'
            },
            {
              label: 'About',
              to: '/docs/project/about'
            },
          ],
        },
        {
          type: 'dropdown',
          to: '/blog',
          label: 'Blog',
          position: 'left',
          items: [
            {
              label: 'Recent',
              to: '/blog'
            },
            {
              label: 'Archive',
              to: '/blog/archive'
            },
            {
              label: 'Tags',
              to: '/blog/tags'
            },
          ]
        },
        {
          href: 'https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/',
          position: 'right',
          className: 'header-github-link',
          'aria-label': 'GitHub repository',
        },
        {
          type: 'dropdown',
          href: 'https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/',
          position: 'right',
          label: 'GitHub',
          items: [
            {
              label: `arm-none-eabi-gcc-xpack project`,
              href: `https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/`,
            },
            {
              label: 'xpack org',
              href: 'https://github.com/xpack/',
            },
            {
              label: 'xpack-dev-tools org',
              href: 'https://github.com/xpack-dev-tools/',
            },
          ]
        },
        {
          label: `${customFields.xpackVersion}`,
          position: 'right',
          href: `https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v${customFields.xpackVersion}`,
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Pages',
          items: [
            {
              label: 'Getting Started',
              to: '/docs/getting-started',
            },
            {
              label: 'Releases',
              to: '/docs/releases',
            },
            {
              label: 'About',
              to: '/docs/project/about',
            },
            {
              label: 'Blog',
              to: '/blog',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'GitHub Discussions',
              href: 'https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/discussions',
            },
            {
              label: 'Stack Overflow',
              href: 'https://stackoverflow.com/questions/tagged/xpack',
            },
            {
              label: 'Discord',
              href: 'https://discord.com/invite/kbzWaJerFG',
            },
            {
              label: 'X/Twitter',
              href: 'https://twitter.com/xpack_project',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Donate via PayPal',
              href: 'https://www.paypal.com/donate/?hosted_button_id=5MFRG9ZRBETQ8',
            },
            {
              label: 'GitHub arm-none-eabi-gcc-xpack project',
              href: 'https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/',
            },
            {
              label: 'GitHub xpack org',
              href: 'https://github.com/xpack/',
            },
            {
              label: 'GitHub xpack-dev-tools org',
              href: 'https://github.com/xpack-dev-tools/',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Liviu Ionescu. Built with Docusaurus v${customFields.docusaurusVersion} on ${new Date(customFields.buildTime).toDateString()}.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
    // https://docusaurus.io/docs/search#using-algolia-docsearch
    // https://docsearch.algolia.com/docs/docsearch-v3/
    algolia: {
      // The application ID provided by Algolia
      appId: "KIDD7R4CL1",

      // Public API key: it is safe to commit it
      apiKey: "ca2ffc431941284609f2d50202fc5506",

      indexName: "xpackio",

      // It ensures that search results are relevant to the current
      // language and version. Enabled by default.
      contextualSearch: true,

      // Optional: Specify domains where the navigation should occur
      // through window.location instead on history.push. Useful when
      // our Algolia config crawls multiple documentation sites and
      // we want to navigate with window.location.href to them.
      // externalUrlRegex: 'external\\.com|domain\\.com',
      externalUrlRegex: 'xpack\\.github\\.io|xpack-dev-tools\\.github\\.io',

      // Optional: Replace parts of the item URLs from Algolia.
      // Useful when using the same search index for multiple deployments
      // using a different baseUrl. You can use regexp or string in the
      // `from` param. For example: localhost:3000 vs myCompany.com/docs
      // replaceSearchResultPathname: {
      //  from: '/docs/', // or as RegExp: /\/docs\//
      //  to: '/',
      // },

      // Optional: Algolia search parameters
      searchParameters: {},

      // Optional: path for search page that enabled by default (`false` to disable it)
      searchPagePath: 'search',

      // Optional: whether the insights feature is enabled or not on Docsearch (`false` by default)
      insights: false,
    },
  } satisfies Preset.ThemeConfig,

  // TODO: find out how to disable cascade CSSs.
  // future: {
  //   v4: true,
  //   experimental_faster: true,
  // },

  customFields: customFields,
};

export default config;
