---
title: webpack
date: 2017-09-07 15:16:46
categories: "前端之巅"
tags: '前端'
---

## webpack打包

Webpack 是一个前端资源加载/打包工具。它将根据模块的依赖关系进行静态分析，然后将这些模块按照指定的规则生成对应的静态资源。

<img src="http://oni42o7kl.bkt.clouddn.com/what-is-webpack.png">

从图中我们可以看出，Webpack 可以将多种静态资源 js、css、less 转换成一个静态文件，减少了页面的请求。
接下来我们简单为大家介绍 Webpack 的安装与使用。

### 安装 Webpack

~~~
cnpm install webpack -g
~~~

### Webpack.js

[下载地址](http://oni42o7kl.bkt.clouddn.com/webpack.js)

~~~
const path = require('path'),
    webpack = require('webpack'),
    NODE_ENV = process.env.NODE_ENV || "DEV", //环境类型
    NODE_RUN = process.env.NODE_RUN || "0", //是否是运行
    ROOT_PATH = path.resolve(__dirname) + "/",
    OUT_PATH = path.resolve(ROOT_PATH, 'build') + "/",
    SERVER_PATH = process.env.SERVER || "./build/", // 服务路径
    ExtractTextPlugin = require("extract-text-webpack-plugin"),
    HtmlWebpackPlugin = require("html-webpack-plugin");
module.exports = {
    entry: {
        page: "./src/js/entrance.js", //[ROOT_PATH + "\\js\\entrance.js"],
        // 打包第三方库作为公共包
        commons: ['vue', 'vue-router']
    },
    output: {
        path: NODE_RUN === "0" ? path.resolve(__dirname, './build') : "/", //"./build",//"./build",//path.resolve(__dirname, './build'), //path.resolve(__dirname, './build'), //
        //publicPath路径就是你发布之后的路径，比如你想发布到你站点的/util/vue/build 目录下, 那么设置publicPath: "/util/vue/build/",此字段配置如果不正确，发布后资源定位不对，比如：css里面的精灵图路径错误
        publicPath: NODE_RUN === "0" ? "/build/" : "/", //"build/",//SERVER_PATH, //process.env.CUSTOM ? "/git/WebApp/n-build/" : "/n-build/",
        filename: NODE_RUN === "0" ? "build.[hash].js" : "build.js",
    },
    externals: [require('webpack-require-http')],
    module: {
        rules: [{
            test: /\.html$/,
            use: [{
                loader: 'html-loader',
                options: {
                    attrs: ['img:src', 'link:href']
                }
            }]
        }, {
            test: /\.js(x)*$/,
            exclude: /^node_modules$/,
            use: ['babel-loader']
        }, {
            test: /\.vue$/,
            //use: ['vue-loader'],
            loader: 'vue-loader',
            options: {
                loaders: {
                    css: ExtractTextPlugin.extract({
                        loader: 'css-loader',
                        fallbackLoader: 'vue-style-loader'
                    }),
                    'scss': ExtractTextPlugin.extract({
                        loader: 'css-loader!sass-loader',
                        fallbackLoader: 'vue-style-loader'
                    }),
                    'sass': ExtractTextPlugin.extract({
                        loader: 'css-loader!sass-loader?indentedSyntax',
                        fallbackLoader: 'vue-style-loader'
                    }),
                    'less': ExtractTextPlugin.extract({
                        loader: 'css-loader!less-loader',
                        fallbackLoader: 'vue-style-loader'
                    })
                }
            }
        }, {
            test: /\.css$/,
            exclude: /^node_modules$/,
            loader: ExtractTextPlugin.extract({
                fallbackLoader: "style-loader",
                loader: "css-loader",
                publicPath: "./"
            })
        }, {
            test: /\.less/,
            exclude: /^node_modules$/,
            loader: ExtractTextPlugin.extract({
                fallbackLoader: 'style-loader',
                loader: "css-loader!less-loader",
                publicPath: "./"
            })
        }, {
            test: /\.scss/,
            exclude: /^node_modules$/,
            loader: ExtractTextPlugin.extract({
                fallbackLoader: 'style-loader',
                loader: "css-loader!sass-loader",
                publicPath: "./"
            })
        }, {
            test: /\.(png|jpe?g|gif|svg|ico)(\?.*)?$/,
            use: [{
                loader: "url-loader",
                query: {
                    limit: 9000,
                    name: 'imgs/[name].[hash:7].[ext]'
                }
            }]
        }, {
            test: /\.(woff2?|eot|ttf|otf)(\?.*)?$/,
            use: [{
                loader: "url-loader",
                query: {
                    limit: 5000,
                    name: 'fonts/[name].[hash:7].[ext]'
                }
            }]
        }]
    },
    plugins: [
        new ExtractTextPlugin(NODE_RUN === "0" ? "style.[hash].css" : "style.css"),
        new HtmlWebpackPlugin({
            filename: "../index.html", //生成的html存放路径，相对于 path
            template: './src/index.html', //html模板路径
            favicon: "./src/imgs/site.ico",
            inject: true, //允许插件修改哪些内容，包括head与body
            minify: { //压缩HTML文件
                removeComments: true, //移除HTML中的注释
                collapseWhitespace: false, //删除空白符与换行符
            }
        }),
        /*
         * 使用CommonsChunkPlugin插件来处理重复代码因为vendor.js和index.js都引用了spa-history, 
         * 如果不处理的话, 两个文件里都会有spa-history包的代码, 我们用CommonsChunkPlugin插件来使共同引用的文件只打包进vendor.js
         */
        new webpack.optimize.CommonsChunkPlugin({
            name: "commons",
            filename: NODE_RUN === "0" ? "common.[hash].js" : "common.js",
            minChunks: function(module, count) {
                // any required modules inside node_modules are extracted to vendor
                return (module.resource && /\.js$/.test(module.resource) && module.resource.indexOf(path.join(__dirname, '../node_modules')) === 0);
            }
        }),
        //自动分析重用的模块并且打包成单独的文件
        new webpack.ProvidePlugin({
            //根据环境加载JS
            config: ROOT_PATH + "/src/js/config/" + NODE_ENV,
            $: "mui",
            mui: "mui"
        })
    ],
    resolve: {
        extensions: ['.js', '.vue', '.jsx', '.less', '.scss', '.css'], //后缀名自动补全
        alias: {
        	mui: ROOT_PATH + "/src/js/lib/mui"
        }
    },
    devServer: {
        historyApiFallback: true, //配置为true, 当访问的文件不存在时, 返回根目录下的index.html文件
        noInfo: true,
        disableHostCheck: true, // 禁用服务检查
        publicPath: "/"
    },
    performance: {
        hints: false
    },
    devtool: '#eval-source-map'
}
var fileSystem = require('fs');
//打包状态
if (NODE_RUN === "0") {
    module.exports.devtool = false;
    module.exports.plugins = (module.exports.plugins || []).concat([
        //      new webpack.LoaderOptionsPlugin({
        //              minimize: true
        //      }), //加上这个编辑“url('data:image/svg+xml;charset=utf-8,<svg....”会报错
        new webpack.DefinePlugin({
            'process.env': {
                NODE_ENV: '"production"'
            }
        }),
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                warnings: false
            },
            output: {
                comments: false
            },
            sourceMap: false
        })
    ]);
    //非开发环境下要清空 output 文件夹下的文件
    var dirArray = [];
    //递归删文件
    var clearOutPutDir = function(path) {
        if (fileSystem.existsSync(path)) {
            var dirList = fileSystem.readdirSync(path);
            dirList.forEach(function(fileName) {
                if (fileSystem.statSync(path + fileName).isDirectory()) {
                    console.info("目录:" + path + fileName);
                    // 目录
                    dirArray.push(path + fileName);
                    clearOutPutDir(path + fileName + "/");
                } else {
                    console.info("文件:" + path + fileName);
                    fileSystem.unlinkSync(path + fileName);
                }
            });
        };
    }
    clearOutPutDir(OUT_PATH);
    for (var i = dirArray.length - 1, j = 0; i >= j; i--) {
        console.info(dirArray[i])
        fileSystem.rmdirSync(dirArray[i]);
    }
} else {
    console.info("run........................................");
    //本地运行状态把index.html中的href、src连接修改掉
//  fileSystem.readFile("index.html", 'utf-8', function(err, data) {
//      if (err) {
//          console.log("error");
//      } else {
//          //将index.html里面的hash值清除掉
//          var devhtml = data.replace(/((?:href|src)="[^"]+\.)(\w{20}\.)(js|css)/g, '$1$3');
//          fileSystem.writeFileSync('index.html', devhtml);
//      }
//  });
}
~~~