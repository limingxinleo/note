---
title: vue-cli 打包vendor大如何处理
date: 2018-01-25 15:16:46
categories: "前端之巅"
tags: '前端'
---

## vue-cli 打包vendor大如何处理

在写admin的时候[项目地址](https://github.com/missxiaolin/vue-admin)
打包发现vendor.js特别大 如何提高用户体验呢

接下来我们看看怎么做

### 定位 webpack 大的原因

~~~
"analyz": "NODE_ENV=production npm_config_report=true npm run build"
~~~

### 尽量使用模块化引入

如果说 jQuery 确实没有引入必要，很多人会同意；但对于 lodash 这类依赖的工具，并不是所有人都会去造一发轮子的。然而全包引入 400kb 的体量，可否有让你心肝一颤？幸好的是，lodash 提供了模块化的引入方式；可按需引入，快哉快哉：

~~~
import { debounce } from 'lodash'
import { throttle } from 'lodash'

// 改成如下写法

import debounce from 'lodash/debounce'
import throttle from 'lodash/throttle'
~~~

擅懒如你的优秀程序员，是否也发现这样写颇为麻烦？那么恭喜你，这个问题已经被解决；lodash-webpack-plugin 和 babel-plugin-lodash 的存在（组合使用），即是解决这问题的。它可将全路径引用的 lodash， 自动转变为模块化按使用引入（如下例示）；并且所需配置也十分简单，就不在此赘述(温馨提示：当涉及些特殊方法时，尚需些留意)。

~~~
// 引入组件，自动转换
import _ from 'lodash'
_.debounce()
_.throttle()
~~~

额外补充的是，即便采用如上写法，还是不够快捷，每个用到的文件，都写一遍 import，实在多有不便。更可取的是，将项目所需的方法，统一引入，按需添加，组建出本地 lodash 类库，然后 export 给框架层（比如 Vue.prototype），以便全局使用；详情可参见：vue-modular-import-lodash。

~~~
// helper 文件夹下 lodash，统一引入你需要的方法
import _ from 'lodash'

export default {
  cloneDeep: _.cloneDeep,
  debounce: _.debounce,
  throttle: _.throttle,
  size: _.size,
  pick: _.pick,
  isEmpty: _.isEmpty
}

// 注入到全局
import _ from '@helper/lodash.js'
Vue.prototype.$_ = _

// vue 组件内运用
this.$_.debounce()
~~~

### 按需异步加载模块

关于前端开发优化，重要的一条是，尽可能合并请求及资源，如常用的请求数据合并，压缩合并 js，构造雪碧图诸此等等（当然得适当，注意体积，过大不宜）；但，同时也当因需制宜，根据需要去异步加载，避免无端就引入早成的浪费。webpack 也是内置对这方面的支持； 假如，你使用的是 Vue，将一个组件（以及其所有依赖）改为异步加载，所需要的只是把：

~~~
import Foo from './Foo.vue'
~~~

改写成

~~~
const Foo = () => import('./Foo.vue')
~~~

如此分割之时，该组件所依赖的其他组件或其他模块，都会自动被分割进对应的 chunk 里，实现异步加载，当然也支持把组件按组分块，将同组中组件，打包在同个异步 chunk 中。如此能够非常有效的抑制 Javascript 包过大，同时也使得资源的利用更加合理化。

### 生产环境，压缩混淆并移除console

现代化中等规模以上的开发中，区分开发环境、测试环境和生产环境，并根据需要予以区别对待，已然成为行业共识；可能的话，还会有预发布环境。对待生产环境，压缩混淆可以很有效的减小包的体积；同时，如果能够移除使用比较频繁的 console，而不是简单的替换为空方法，也是精彩的一笔小优化。如果使用 UglifyJsPlugin 插件来压缩代码，加入如下配置，即可移除掉代码中的 console：

~~~
new webpack.optimize.UglifyJsPlugin({
  compress: {
    warnings: false,
    drop_console: true,
    pure_funcs: ['console.log']
  },
  sourceMap: false
})
~~~

### 依赖包

很多人发现自己引用的第三方依赖包特别多的时候vendor.js会打包的特别大

解决方法：

在config/index.js 中找到productionGzip 设置为true 并且安装 npm install --save-dev compression-webpack-plugin

~~~
const path = require('path')

module.exports = {
  build: {
    env: require('./prod.env'),
    index: path.resolve(__dirname, '../dist/index.html'),
    assetsRoot: path.resolve(__dirname, '../dist'),
    assetsSubDirectory: 'static',
    assetsPublicPath: '/',
    productionSourceMap: true,
    // Gzip off by default as many popular static hosts such as
    // Surge or Netlify already gzip all static assets for you.
    // Before setting to `true`, make sure to:
    // npm install --save-dev compression-webpack-plugin
    productionGzip: true,
    productionGzipExtensions: ['js', 'css'],
    // Run the build command with an extra argument to
    // View the bundle analyzer report after build finishes:
    // `npm run build --report`
    // Set to `true` or `false` to always turn it on or off
    bundleAnalyzerReport: process.env.npm_config_report
  },
  dev: {
    env: require('./dev.env'),
    port: process.env.PORT || 8080,
    autoOpenBrowser: true,
    assetsSubDirectory: 'static',
    assetsPublicPath: '/',
    proxyTable: {},
    // CSS Sourcemaps off by default because relative paths are "buggy"
    // with this option, according to the CSS-Loader README
    // (https://github.com/webpack/css-loader#sourcemaps)
    // In our experience, they generally work as expected,
    // just be aware of this issue when enabling this option.
    cssSourceMap: false
  }
}
~~~

接下来我们看看webpack.prod.conf 这里做了什么，会生成gz文件


<img src="http://oni42o7kl.bkt.clouddn.com/vue-build.jpeg">

~~~
if (config.build.productionGzip) {
  const CompressionWebpackPlugin = require('compression-webpack-plugin')

  webpackConfig.plugins.push(
    new CompressionWebpackPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: new RegExp(
        '\\.(' +
        config.build.productionGzipExtensions.join('|') +
        ')$'
      ),
      threshold: 10240,
      minRatio: 0.8
    })
  )
}
~~~

这样做就可以了吗，然而并不是 配合nginx

~~~
server {
    listen       80;
    server_name  vue.phalcon.app;
    root   /Users/limx/Applications/vue/dist;
    index  index.html index.htm;
    client_max_body_size 8M;

    proxy_set_header    Host                $host:$server_port;
    proxy_set_header    X-Real-IP           $remote_addr;
    proxy_set_header    X-Real-PORT         $remote_port;
    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;

    gzip on;
    # gzip_static on;
    gzip_min_length 1k;
    gzip_buffers 16 64k;
    gzip_http_version 1.1;
    gzip_comp_level 9;
    gzip_types text/plain application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png;
    gzip_vary on;

    #charset koi8-r;
    #access_log  /var/log/nginx/log/host.access.log  main;

    location / {
        try_files $uri $uri/ /index.html$is_args$args;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
~~~










