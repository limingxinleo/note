---
title: requirejs压缩工具r.js打包（三）
date: 2017-09-13 10:22:22
categories: "前端之巅"
tags: '前端'
---

## npm

- npm 全名为Node Package Manager，是Node.js 的套件（package）管理工具，类似Perl 的ppm 或PHP 的PEAR 等。安装npm 后，使用npm install module name 指令即可安装新套件，维护管理套件的工作会更加轻松。
- npm 可以让Node.js 的开发者，直接利用、扩充在线的套件库（packages registry），加速软件项目的开发。npm 提供很友善的搜寻功能，可以快速找到、安装需要的套件，当这些套件发行新版本时，npm 也可以协助开发者自动更新这些套件。
- npm 不仅可用于安装新的套件，它也支持搜寻、列出已安装模块及更新的功能。
- Node.js 在0.6.3 版本开始内建npm，读者安装的版本若是此版本或更新的版本，否则需要单独安装。
- npm 目前拥有超过6000 种套件（packages），可以在npm registry 使用关键词搜寻套件。http://search.npmjs.org/

### 常用命令

~~~
npm -v                   #显示版本，检查npm 是否正确安装。
npm install express      #安装express模块
npm install -g express   #加上 -g 启用global安装模式
npm list                 #列出已安装模块
npm show express         #显示模块详情
npm update               #升级所有套件
npm update express       #升级指定的模块
npm uninstall express    #删除指定的模块
~~~

npm就介绍到这里

### 生成package.json

~~~
npm init
~~~

### 加入命令

~~~
{
  "name": "xiaolin",
  "version": "1.0.0",
  "description": "",
  "main": "app.build.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "all": "r.js -o app.build.js"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/missxiaolin/require.git"
  },
  "author": "xiaolin",
  "license": "ISC",
  "bugs": {
    "url": "https://github.com/missxiaolin/require/issues"
  },
  "homepage": "https://github.com/missxiaolin/require#readme"
}

~~~