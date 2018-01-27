### 打包结果分析

1.

~~~
webpack --profile --json > stats.json
webpack --profile --json | Out-file 'stats.json' -Encoding OEM
~~~

传到[官方](http://webpack.github.io/analyse/)

2.

~~~
cnpm install webpack-bundle-analyzer --save-dev

const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
new BundleAnalyzerPlugin()
~~~

3. vue-cli使用

~~~
"analyz": "NODE_ENV=production npm_config_report=true npm run build"
npm run analyz
~~~

### 优化打包速度

在写admin的时候[项目地址](https://github.com/missxiaolin/vue-admin)

后面发现打包速度越来越慢，如何处理（第三方依赖不需要重复打包）

先打包一遍

<img src="http://oni42o7kl.bkt.clouddn.com/vue-build1.jpg">

在build下创建webpacl.ddl.conf.js
~~~
const path = require('path')
const webpack = require('webpack')

/**
 * 打包第三方库
 */
module.exports = {
    entry: {
        vue: ['vue', 'vue-router'],
        ui: ['element-ui']
    },

    output: {
        path: path.join(__dirname, '../src/dll/'),
        filename: '[name].dll.js',
        library: '[name]'
    },

    plugins: [
        new webpack.DllPlugin({
            path: path.join(__dirname, '../src/dll/', '[name]-manifest.json'),
            name: '[name]'
        }),

        new webpack.optimize.UglifyJsPlugin()
    ]
}
~~~

运行 会在src下生成ui-manifest.json 和 vue-manifest.json

~~~
webpack --config build/webpacl.ddl.conf.js
~~~

找到webpack.prod.conf.js,在plugins加入

~~~
new webpack.DllReferencePlugin({
  manifest: require('../src/dll/ui-manifest.json')
}),

new webpack.DllReferencePlugin({
  manifest: require('../src/dll/vue.json')
}),
~~~

<img src="http://oni42o7kl.bkt.clouddn.com/vue-build2.jpg">

找到webpack.prod.conf.js,在plugins修改UglifyJsPlugin增加cache: true缓存，sourceMap改成false

~~~
new webpack.optimize.UglifyJsPlugin({
	compress: {
		warnings: false
	},
	sourceMap: false,
	cache: true
})
~~~













