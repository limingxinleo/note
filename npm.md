### 国内镜像
× 编辑~/.npmrc
~~~
registry = https://registry.npm.taobao.org
~~~

### npm的镜像源管理工具
>npm install -g nrm

* 命令：nrm ls 用于展示所有可切换的镜像地址
* 命令：nrm use cnpm 我们这样就可以直接切换到cnpm上了。当然也可以按照上面罗列的其他内容进行切换。

### 使用webpack
* 安装
~~~
// 全局安装
npm install -g webpack
// 安装到当前目录项目
npm install webpack
~~~

* 初始化项目
~~~
npm init
npm install --save-dev webpack
~~~

* 编写webpack.config.js
~~~
var webpack = require('webpack');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
module.exports = {
    entry: {
        main: __dirname + "/asset/main.js",
        vendor: ["jquery", "bootstrap"]
    },//已多次提及的唯一入口文件
    output: {
        path: __dirname + "/public",//打包后的文件存放的地方
        filename: "[name].js"//打包后输出文件的文件名
    },
    module: {
        loaders: [
            {
                test: /\.css$/,
                loader: ExtractTextPlugin.extract("style-loader", "css-loader")
            },
            {
                test: /\.scss$/,
                loader: "style!css!sass"
            },
            {
                test: /\.less$/,
                loader: "style!css!less"
            },
            {
                test: /\.(eot|woff|ttf|woff2)$/, loader: "file-loader"
            },
            {
                test: /\.svg$/, loader: 'svg-loader'
            },
        ]
    },
    plugins: [
        new webpack.optimize.CommonsChunkPlugin({
            names: ['vendor']
        }),
        new ExtractTextPlugin("styles.css"),
    ]
}
~~~
* package.json 样例
~~~
{
    "name": "phalcon-rbac",
    "version": "1.0.0",
    "description": "基于phalcon框架rbac设计的权限管理项目",
    "main": "index.js",
    "directories": {
        "test": "tests"
    },
    "scripts": {
        "test": "echo \"Error: no test specified\" && exit 1"
    },
    "repository": {
        "type": "git",
        "url": "git+https://limingxinleo@github.com/limingxinleo/phalcon-rbac.git"
    },
    "keywords": [
        "phalcon",
        "rbac"
    ],
    "author": "limx",
    "license": "ISC",
    "bugs": {
        "url": "https://github.com/limingxinleo/phalcon-rbac/issues"
    },
    "homepage": "https://github.com/limingxinleo/phalcon-rbac#readme",
    "devDependencies": {
        "css-loader": "^0.26.1",
        "extract-text-webpack-plugin": "^1.0.1",
        "file-loader": "^0.9.0",
        "style-loader": "^0.13.1",
        "svg-loader": "0.0.2",
        "webpack": "^1.14.0"
    },
    "dependencies": {
        "bootstrap": "^3.3.7",
        "jquery": "^2.2.4"
    }
}

~~~

* 打包
~~~
webpack
~~~

