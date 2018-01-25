---
title: gulp
date: 2017-09-07 15:36:46
categories: "前端之巅"
tags: '前端'
---

## gulp打包

gulp是前端开发过程中对代码进行构建的工具，是自动化项目的构建利器；她不仅能对网站资源进行优化，而且在开发过程中很多重复的任务能够使用正确的工具自动完成；使用她，我们不仅可以很愉快的编写代码，而且大大提高我们的工作效率。

### 安装 Gulp

~~~
cnpm install --global gulp
~~~

### 作为项目的开发依赖（devDependencies）安装

~~~
npm install --save-dev gulp
~~~


### gulp

[下载地址](http://oni42o7kl.bkt.clouddn.com/gulpfile.js)

~~~
var gulp        = require('gulp'),
    sass        = require('gulp-sass'),
    minifyCss   = require('gulp-minify-css'),
    plumber     = require('gulp-plumber'),
    babel       = require('gulp-babel'),
    uglify      = require('gulp-uglify'),
    clearnHtml  = require("gulp-cleanhtml"),
    imagemin    = require('gulp-imagemin'),
    copy        = require('gulp-contrib-copy'),
    browserSync = require('browser-sync').create(),
    reload      = browserSync.reload;
    
// 定义源代码的目录和编译压缩后的目录
var src='tpl_src',
    dist='tpl';

// 编译全部scss 并压缩
gulp.task('css', function(){
    gulp.src(src+'/**/*.scss')
        .pipe(sass())
        .pipe(minifyCss())
        .pipe(gulp.dest(dist))
})

// 编译全部js 并压缩
gulp.task('js', function() {
  gulp.src(src+'/**/*.js')
    .pipe(plumber())
    .pipe(babel({
      presets: ['es2015']
    }))
    .pipe(uglify())
    .pipe(gulp.dest(dist));
});

// 压缩全部html
gulp.task('html', function () {
    gulp.src(src+'/**/*.+(html)')
    .pipe(clearnHtml())
    .pipe(gulp.dest(dist));
});

// 压缩全部image
gulp.task('image', function () {
    gulp.src([src+'/**/*.+(jpg|jpeg|png|gif|bmp)'])
    .pipe(imagemin())
    .pipe(gulp.dest(dist));
});

// 其他不编译的文件直接copy
gulp.task('copy', function () {
    gulp.src(src+'/**/*.!(jpg|jpeg|png|gif|bmp|scss|js|html)')
    .pipe(copy())
    .pipe(gulp.dest(dist));
});

// 自动刷新
gulp.task('server', function() {
    browserSync.init({
        proxy: "tbjyadmin.com", // 指定代理url
        notify: false, // 刷新不弹出提示
    });
    // 监听scss文件编译
    gulp.watch(src+'/**/*.scss', ['css']);

    // 监听其他不编译的文件 有变化直接copy
    gulp.watch(src+'/**/*.!(jpg|jpeg|png|gif|bmp|scss|js|html)', ['copy']);   

    // 监听html文件变化后刷新页面
    gulp.watch(src+"/**/*.js", ['js']).on("change", reload);

    // 监听html文件变化后刷新页面
    gulp.watch(src+"/**/*.+(html|tpl)", ['html']).on("change", reload);

    // 监听css文件变化后刷新页面
    gulp.watch(dist+"/**/*.css").on("change", reload);
});

// 监听事件
gulp.task('default', ['css', 'js', 'image', 'html', 'copy'])

~~~