---
title: requirejs压缩工具r.js的build.js配置详解（一）
date: 2017-09-11 15:16:46
categories: "前端之巅"
tags: '前端'
---

## require之r.js打包

至于requirejs大家都是很熟悉的了，它的打包工具r.js是非常好用，也非常强大的，但是建于它的配置参数比较多，这里列出一份所有参数的中文详解，方便理解和记忆。


还有不明白的童鞋可以看看 [require](https://missxiaolin.github.io/2017/03/11/%E5%89%8D%E7%AB%AF/require/)

| 参数 |  |  |
| ------ || ------ |
| appDir: “some/path/” || 选填）app的顶级目录。如果指定该参数，说明您的所有文件都在这个目录下面（包括baseUrl和dir都以这个为根目录）。如果不指定，则以baseUrl参数为准 |
| baseUrl: ”./” || 模块所在默认相对目录。如果baseUrl指定不明确，所有被加载的模块都相对于生成目录。如果appDir被指定，baseUrl将相对于appDir目录。 |
| mainConfigFile: “../some/path/to/main.js” || 配置文件地址。默认所有的优化配置都在命令行或者配置文件里，而通过requirejs的data-main引入配置文件的方式是不起作用的。当然，如果你不想重复声明配置，可以直接通过这个参数指向data-main的文件。文件中的第一个requirejs({})，require({})，requirejs.config({})或者require.config({})方法调用会被用到。在2.1.10版本中，mainConfigFile可以是数组，并且后指定的值会覆盖先指定的值。 |
| paths: {“foo.bar”: “../scripts/foo/bar”,“baz”: “../another/path/baz”} || 设置模块的路径。相对路径以baseUrl为当前目录。如果是”empty:”则指向一个空文件。使优化器在输出时不会包含该文件。对于指向CDN或者其它在浏览器中运行的http:URL的模块有用，在优化过程中它应该被跳过因为它没有依赖项。 |
| map: {} || 建立一个模块到其它模块的ID地图 |
| packages: [] || 配置CommonJS包，查看[http://requirejs.org/docs/api.html#packages](http://requirejs.org/docs/api.html#packages) |
| dir: “../some/path” || 输出目录。如果不指定，默认会创建一个build目录，相对于生成文件所在的目录。 |
| keepBuildDir: false || 在2.0.2版本中，dir指向的目录在生成开始之前会被删除。如果你有一个大型的生成项目并且不会通过onBuildRead/onBuildWrite改变源文件，你可以使用这个参数来保持原目录，这样可以让重新生成时更快速，但是如果生成的代码被某种方式改变的话，可能会导致未知的错误。 |
| shim: {} || 如果shim配置在requirejs运行过程中被使用的话，需要在这里重复声明，这样才能将依赖模块正确引入。最好是使用mainConfigFile指定配置文件，这样就可以只在一个地方声明。当然，如果mainConfigFile没有声明，shim配置就必须声明。 |
| wrapShim: false || 在2.1.11版本中，shim的依赖可以包含在define()里。具体参见：[http://requirejs.org/docs/api.html#config-shim](http://requirejs.org/docs/api.html#config-shim) |
| Locale: “en-us” || 使用i18n源文件指定语言 |
| optimize: “uglify” || 默认会压缩所有js文件，closure none |
| skipDirOptimize: false || 2.1.2中提到，如果使用dir作为输出目录，优化器会优化输出目录的所有JS（包括没有在modules配置中声明的）。当然，如果没有在modules里面声明的JS文件在生成过后不会被使用你可以跳过这些文件，以加快生成速度。将该参数设置为true来跳过这些不用被生成的JS文件。 |
| generateSourceMaps: false || 在2.1.2中是实验性质。 |
| normalizeDirDefines: “skip” || 2.1.11中：如果dir被声明且不为”none”，并且skipDirOptimize 为false，通常所有的JS文件都会被压缩，这个值自动设置为”all”。为了让JS文件能够在压缩过正确执行，优化器会加一层define()调用并且会插入一个依赖数组。当然，这样会有一点点慢如果有很多文件或者有大文件的时候。所以，设置该参数为”skip”这个过程就不会执行，如果optimize设置为”none”也一样。如果你想手动设置值的话：1）优化后：如果你打算压缩没在modules声明的JS文件，在优化器执行过后，你应该设置这个值为”all”2）优化中：但在动态加载过后，你想做一个会文件优化，但不打算在动态加载这些文件可以设置成”skip”最后：所有生成的文件（无论在不在modules里声明过）自动标准化 |
| uglify: {toplevel: true,ascii_only: true,beautify: true,max_line_length: 1000,defines: {DEBUG: [“name”, “false”]},no_mangle: true} || 如果用UglifyJS做优化，这些配置参数会被传递到UglifyJS，详情见：https://github.com/mishoo/UglifyJS |
| Uglify2: {output: {beautify: true},compress: {sequences: false,global_defs: {DEBUG: false}},warnings: true,mangle: false} || 如果用UglifyJS2来优化，这些配置参数会被传入UglifyJS2 |
| closure: {CompilerOption: {},CompilationLevel: “SIMPLE_OPTIMIZATIONS”,loggingLevel: “WANING”} || 如果用Closure Compiler优化，这个参数可以用来配置Closure Compiler，详细请看Closure Compiler的文档 |
| optimizeCss: “standard.keepLines.keepWhitespace || 允许优化CSS，参数值：“standard”: @import引入并删除注释，删除空格和换行。删除换行在IE可能会出问题，取决于CSS的类型“standard.keepLines”: 和”standard”一样但是会保持换行“none”: 跳过CSS优化“standard.keepComments”: 保持注释，但是去掉换行(r.js 1.0.8+)“standard.keepComments.keepLines”: 保持注释和换行(r.js 1.0.8+)“standard.keepWhitespace”: 和”standard”一样但保持空格 |
| cssImportIgnore: null || 如果optimizeCss可用，列出需要忽略@import的文件。值应该是以逗号分隔的CSS文件名（例：”a.css,b.css”，文件名必须和@import的相同 |
| cssIn: “path/to/main.css”,out: “path/to/css-optimized.css” || cssIn是用在命令行的类型参数，它可以单独使用来优化单个CSS文件 |
| cssPrefix: “” || 如果”out”和”cssIn”不是同一目录，并且在cssIn文件里面有url()相对目录的，用这个去设置URL前置。仅仅在优化后URL不正确的情况下使用。 |
| inlineText: true || 内联所有文本和依赖，避免多次异步请求这些依赖 |
| userStrict: false || 允许“user strict”，用来包含RequireJS文件。默认为false是因为没有多少浏览器能够准确的处理ES5的strict mode错误，并且还有很多遗留代码在strict mode里面不能运行。 |
| pragmas: {fooExclude: true} || 指定生成编译指示。如果源文件包含类似如下注释：>>excludeStart(“fooExlude”, pragmas.fooExclude);>>excludeEnd(“fooExclude”);那么以//>>开头的注释就是编译指示。excludeStart/excludeEnd和includeStart/includeEnd起作用，在includeStart或excludeStart中的编译指示值将参与计算来判断Start和End之前的编译指示是include还是exclude。如果你可以选择用”has”或编译指示，建议用”has”代替。 编译指示比较难于阅读，但是它在对代码移除上比较灵活。基于”has”的代码必须遵守JavaScript规则。编译指示还可以在未压缩的代码中删除代码，而”has”只能通过UglifyJS或者Closure Compiler来做。 |
| pragmasOnSave: {excludeCoffeeScript: true} || 和”pragmas”一样，但只能在文件保存的优化阶段应用一次。”pragmas”可以同时在依赖映射和文件保存优化阶段应用。有些”pragmas”可能不会在依赖映射时被执行，例如在CoffeeScript的loader插件中，只想CoffeeScript做依赖映射，但是一旦这个文件被保存为一个javascript文件，CoffeeScript compiler就没用了。那样的话，pragmasOnSave就会用于在保存期排除编译代码。 |
| has: {“function-bind”: true,“string-trim”: false} || 使用”has”允许trimming代码树。基于js的特征检测：https://github.com/phiggins42/has.js。代码树修饰仅仅在使用UglifyJS或Closure Compiler压缩时发生。更多请见：http://requirejs.org/docs/optimization.html#hasjs |
| hasOnSave: {“function-bind”: true,“string-trim”: false} || 和pragmasOnSave类似 |
| namespace: “foo” || 允许requirejs名称空间，使require和define换作新的名字。更多见：http://requirejs.org/docs/faq-advanced.html#rename |
| skipPragmas: false || 跳过执行pragmas |
| skipModuleInsertion: false || 如果是false，文件就不会用define()来定义模块而是用一个define()占位符插入其中。另外，require.pause/resume调用也会被插入。设置为”true”来避免。这个参数用在你不是用require()来创建项目或者写js文件，但是又想使用RquireJS的优化工具来合并模块是非常有用的。 |
| stubModules: [“text”, “bar”] || 将模块排除在优化文件之外。 |
| optimizeAllPluginResources: false || 如果不是一个文件的优化，描述输出目录的所有.js文件的插件依赖，如果这个插件支持优化成为一个单独的文件，就优化它。可能是一个比较慢的优化过程。仅仅在有些插件用了像XMLHttpRequest不支持跨域，并且生成的代码会被放在另一个域名。 |
| findNestedDependencies: false || 寻找require()里面的require或define调用的依赖。默认为false是因为这些资源应该被认为是动态加载或者实时调用的。当然，有些优化场景也需要将它们合并在一起。 |
| removeCombined: false || 如果设置为true，在输出目录将会删除掉已经合并了的文件 |
| insertRequire: [“foo/bar/bop”] || 如果目标模块在顶层级只调用了define没有调用require()，并且输出文件在data-main中使用，如果顶层没有require，就不会有任何模块被加载。定义insertRequire在文件尾部来执行其它模块，更多参见：https://github.com/jrburke/almond |
| name: “foo/bar/bop”,include: [“foo/bar/bee”],insertRequire: [“foo/bar/bop”],out: “path/to/optimized-file.js” || 如果只优化一个模块（和它的依赖项），而且是生成一个单文件，你可以在行内定义模块的选项，以代替modules参数的定义方式，”exclude”, “excludeShallow”, “include”和”insertRquire”都可以以兄弟属性的方式定义 |
| deps: [“foo/bar/bee”] || “include”的替换方案。一般用requirejs.config()来定义并用mainConfigFile引入。 |
| out: function( text, sourceMapText ) { } || 在2.0，”out”可以是一个函数， 对单个JS文件优化可以调用requirejs.optimize()， 用out函数表示优化过后的内容不会被写到磁盘，而是传递给out函数。 |
| out: “stdout” || 在2.0.12+， 设置”out”为”stdout”， 优化输出会写到STDOUT，这对于r.js整合其它命令行工具很有用。为了避免额外的输出”logLevel: 4”应该被使用。 |
| wrap: {start: “(function() {“,end: “}())”} || wrap任何东西在start和end之间，用于define/require不是全局的情况下，在end里可以暴露全局对象在文件中。 |
| wrap: true || wrap的另一种方式，默认是(function() { + content + }()) |
| wrap: {startFile: “parts/start.frag”,“endFile: “parts/end.frag”} || 用文件来wrap |
| wrap: {startFile: [“parts/startOne.frag”, “parts/startTwo.frag”],endFile: [“parts/endOne.frag”, “parts/endTwo.frag”]} || 多个文件的wrap |
| fileExclusionRegExp: /^\./ || 跳过任何以.开头的目录和文件，比如.files, .htaccess等 |
| preserveLicenseComments: true || 默认注释有授权在里面。当然，在大项目生成时，文件比较多，注释也比较多，这样可以把所有注释写在文件的顶部。 |
| logLevel: 0 || 设置logLevel。TRACE: 0,INFO: 1WARN: 2ERROR: 3SILENT: 4 |
| throwWhen: {optimize: true} || 在2.1.3，有些情况下当错误发生时不会抛出异常并停止优化，你可能想让优化器在某些错误发生时停止，就可以使用这个参数 |
| onBuildRead: function( moduleName, path, contents) {return contents.replace(/foo/g, “bar”);} || 当每个文件被读取的时候调用这个方法来改变文件内容 |
| onBuildWrite: function( moduleName, path, contents) {return contents.replace(/bar/g, “foo”);} || 允许在写入目标文件前执行方法改变内容 |
| onModuleBundleComplete: function( data) { } || 每个JS模块集完成后执行。 模块集是指一个modules数组项。 |
| rawText: {“some/id”: “define([‘another/id’], function () {} ); “} || 在2.1.3，种子raw text是模块ID的列表。这些文本内容用于代替模块的文件IO调用。用于模块ID是基于用户动态输入的情况，在网页生成工具中常用。 |
| cjsTranslate: true || 在2.0.2中。如果为true, 优化器会添加define(require, exports, module) {})；包裹每一个没有调用define()的文件。 |
| useSourceUrl: true || 在2.0.2，有点实验性质。每一个模块集最后都会添加一段//# sourceUrl的注释。 |
| waitSeconds: 7 || 定义模块的加载时间。 |
| skipSemiColonInsertion: false || 在2.1.9，通常r.js插入一个分号在文件末尾，如果没有的话。 |
| keepAmdefine: false || 在2.1.10， 如果是true，就不会删除amdefine，详情见：https://github.com/jrburke/amdefine |
| allowSourceOverwrites: false || 在2.1.11中， 作为修复BUG的一部分https://github.com/jrburke/r.js/issues/444。设置为true就允许源代码进行重写覆盖。当然，为了安全起见，请正确配置，比如你可能想设置”keepBuildDir”为true。 |
