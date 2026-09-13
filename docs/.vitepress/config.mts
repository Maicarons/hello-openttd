import { defineConfig } from 'vitepress'

// GitHub Pages 项目站点需与仓库名一致；若仓库名变更请同步修改 base。
const base = '/hello-openttd/'

const zhGuide = {
  gettingStarted: '开始使用',
  introduction: '简介',
  install: '安装',
  quickStart: '快速上手',
  features: '功能指南',
  versions: '版本管理',
  downloads: '下载与镜像',
  config: '配置管理',
  mods: '模组中心',
  launch: '启动器',
  saves: '存档管理',
  settings: '外观与语言',
  help: '帮助',
  faq: '常见问题'
}

const enGuide = {
  gettingStarted: 'Getting Started',
  introduction: 'Introduction',
  install: 'Installation',
  quickStart: 'Quick Start',
  features: 'Features',
  versions: 'Version Management',
  downloads: 'Downloads & Mirrors',
  config: 'Config Management',
  mods: 'Mod Center',
  launch: 'Launcher',
  saves: 'Save Management',
  settings: 'Appearance & Language',
  help: 'Help',
  faq: 'FAQ'
}

const zhDev = {
  project: '项目',
  overview: '总览与决策记录',
  setup: '环境搭建',
  structure: '目录结构',
  architecture: '架构设计',
  featureSpecs: '功能规格',
  downloadEngine: '下载引擎',
  bananas: 'BaNaNaS 集成',
  cfgParser: '配置解析器',
  process: '进程与启动',
  saves: '存档服务',
  engineering: '工程质量',
  security: '安全设计',
  testing: '测试策略',
  release: '发布流程'
}

const enDev = {
  project: 'Project',
  overview: 'Overview & ADRs',
  setup: 'Setup',
  structure: 'Project Structure',
  architecture: 'Architecture',
  featureSpecs: 'Feature Specs',
  downloadEngine: 'Download Engine',
  bananas: 'BaNaNaS Integration',
  cfgParser: 'Config Parser',
  process: 'Process & Launch',
  saves: 'Save Service',
  engineering: 'Engineering',
  security: 'Security',
  testing: 'Testing',
  release: 'Release Process'
}

function sidebarGuide(basePath: string, t: typeof zhGuide) {
  return [
    {
      text: t.gettingStarted,
      items: [
        { text: t.introduction, link: `${basePath}/introduction` },
        { text: t.install, link: `${basePath}/install` },
        { text: t.quickStart, link: `${basePath}/quick-start` }
      ]
    },
    {
      text: t.features,
      items: [
        { text: t.versions, link: `${basePath}/versions` },
        { text: t.downloads, link: `${basePath}/downloads` },
        { text: t.config, link: `${basePath}/config` },
        { text: t.mods, link: `${basePath}/mods` },
        { text: t.launch, link: `${basePath}/launch` },
        { text: t.saves, link: `${basePath}/saves` },
        { text: t.settings, link: `${basePath}/settings` }
      ]
    },
    {
      text: t.help,
      items: [{ text: t.faq, link: `${basePath}/faq` }]
    }
  ]
}

function sidebarDev(basePath: string, t: typeof zhDev) {
  return [
    {
      text: t.project,
      items: [
        { text: t.overview, link: `${basePath}/overview` },
        { text: t.setup, link: `${basePath}/setup` },
        { text: t.structure, link: `${basePath}/structure` },
        { text: t.architecture, link: `${basePath}/architecture` }
      ]
    },
    {
      text: t.featureSpecs,
      items: [
        { text: t.downloadEngine, link: `${basePath}/download-engine` },
        { text: t.bananas, link: `${basePath}/bananas` },
        { text: t.cfgParser, link: `${basePath}/cfg-parser` },
        { text: t.process, link: `${basePath}/process` },
        { text: t.saves, link: `${basePath}/saves` }
      ]
    },
    {
      text: t.engineering,
      items: [
        { text: t.security, link: `${basePath}/security` },
        { text: t.testing, link: `${basePath}/testing` },
        { text: t.release, link: `${basePath}/release` }
      ]
    }
  ]
}

const repo = 'https://github.com/hello-openttd/hello-openttd'

export default defineConfig({
  base,
  title: 'hello-openttd',
  head: [['link', { rel: 'icon', type: 'image/svg+xml', href: `${base}logo.svg` }]],
  lastUpdated: true,
  cleanUrls: false,

  locales: {
    root: {
      label: '简体中文',
      lang: 'zh-Hans',
      themeConfig: {
        nav: [
          { text: '指南', link: '/guide/introduction', activeMatch: '/guide/' },
          { text: '开发', link: '/dev/overview', activeMatch: '/dev/' },
          { text: '更新日志', link: `${repo}/blob/main/CHANGELOG.md` }
        ],
        sidebar: [
          ...sidebarGuide('/guide', zhGuide),
          ...sidebarDev('/dev', zhDev)
        ],
        search: { provider: 'local' },
        outline: { level: [2, 3], label: '本页目录' },
        docFooter: { prev: '上一页', next: '下一页' },
        lastUpdatedText: '最后更新于',
        returnToTopLabel: '回到顶部',
        sidebarMenuLabel: '菜单',
        darkModeSwitchLabel: '主题',
        lightModeSwitchTitle: '切换到浅色模式',
        darkModeSwitchTitle: '切换到深色模式',
        socialLinks: [{ icon: 'github', link: repo }],
        editLink: {
          pattern: `${repo}/edit/main/docs/:path`,
          text: '在 GitHub 上编辑此页'
        },
        footer: {
          message: '基于 AGPL-3.0 发布 · 与 OpenTTD 官方无隶属关系',
          copyright: 'hello-openttd Contributors'
        }
      }
    },
    en: {
      label: 'English',
      lang: 'en-US',
      link: '/en/',
      themeConfig: {
        nav: [
          { text: 'Guide', link: '/en/guide/introduction', activeMatch: '/en/guide/' },
          { text: 'Development', link: '/en/dev/overview', activeMatch: '/en/dev/' },
          { text: 'Changelog', link: `${repo}/blob/main/CHANGELOG.md` }
        ],
        sidebar: [
          ...sidebarGuide('/en/guide', enGuide),
          ...sidebarDev('/en/dev', enDev)
        ],
        search: { provider: 'local' },
        outline: { level: [2, 3] },
        socialLinks: [{ icon: 'github', link: repo }],
        editLink: {
          pattern: `${repo}/edit/main/docs/:path`,
          text: 'Edit this page on GitHub'
        },
        footer: {
          message: 'Released under AGPL-3.0 · Not affiliated with the OpenTTD team',
          copyright: 'hello-openttd Contributors'
        }
      }
    }
  },

  markdown: {
    theme: 'github-dark'
  }
})
