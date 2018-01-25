---
title: PhotoClip裁剪图片
date: 2017-03-29 9:16:46
categories: "前端之巅"
tags: 'php'
---

### PhotoClip裁剪图片

下载地址[PhotoClip裁剪图片](https://github.com/baijunjie/PhotoClip.js)

使用当然很简单照着文档中的提示就可以实现了(AMD模块化引入我就不多说了大家按照我之前的[require](https://missxiaolin.github.io/2017/03/11/require/)写法就可以了)

~~~
<div id="clipArea"></div>
<input type="file" id="file">
<button id="clipBtn">截取</button>
<div id="view"></div>
<script src="js/jquery.min.js"></script>
<script src="js/iscroll-zoom.js"></script>
<script src="js/hammer.min.js"></script>
<script src="js/lrz.all.bundle.js"></script>
<script src="js/PhotoClip.js"></script>
<script>
	$("#view").mouseup(function(){
		alert(1);
	})
	var pc = new PhotoClip('#clipArea', {
		size: [200, 200],
		outputSize: 640,
		//adaptive: ['60%', '80%'],

		file: '#file',
		view: '#view',
		ok: '#clipBtn',
		//img: 'img/mm.jpg',
		loadStart: function() {
			console.log('开始读取照片');

		},
		loadComplete: function() {
			console.log('照片读取完成');
		},
		done: function(dataURL) {
			console.log(dataURL);
		},
		fail: function(msg) {
			alert(msg);
		}
	});

	// 加载的图片必须要与本程序同源，否则无法截图
	pc.load('donations.jpg');
</script>
~~~

### 通过npm引入

- 安装

~~~
$ npm install photoclip
~~~

- 引入

~~~
// ES6
import PhotoClip from 'photoclip'
// CommonJS
var PhotoClip = require('photoclip')
~~~

### 下面进入重点

截图好发现编码是base64编码如何上传到七牛呢？

1. 用js内置对象XMLHttpRequest 来用ajax

2. xhr.setRequestHeader("Authorization", "UpToken 填写你从服务端获取的上传token"); 这里的UpToken与后面的字符串保留一个空格。后面跟上你在服务端请求的token的字符串。具体你通过什么样子的请求方式获得是客户自己要关心的事情。

3. var url = "http://upload.qiniu.com/putb64/20264"; 中可以扩展为以下方式：http://upload.qiniu.com/putb64/Fsize/key/EncodedKey/mimeType/EncodedMimeType/x:user-var/EncodedUserVarVal

- Fsize 文件大小，必选。支持传入 -1 表示文件大小以 http request body 为准。获取文件大小的时候，切记要通过文件流的方式获取。而不是通过图片标签然后转换后获取。
- EncodedKey: 可选，如果没有指定则：如果 uptoken.SaveKey 存在则基于 SaveKey 生产 key，否则用 hash 值作 key。
- 整个EncodedKey需要经过base64编码！！

如：
~~~
var key = uuid();
key = base64encode(key);
var url = 'http://upload.qiniu.com/putb64/-1/key/'+key
~~~

具体参照：[官方文档](https://developer.qiniu.com/kodo/manual/appendix#urlsafe-base64)

### 下面就是我自己写的一个方法

~~~
function putb64(logo_base64, token) {
    var picBase = logo_base64.substring(23); //大家可以先打印看看截图好的编码要把头部的data:image/png;base64,去掉。（注意：base64后面的逗号也去掉）
    var pic = picBase;
    var url = "http://upload.qiniu.com/putb64/-1";
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        // console.log(xhr.readyState);
        if (xhr.readyState == 4) {
        	console.log(xhr.responseText);
        }
    }
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/octet-stream");
    xhr.setRequestHeader("Authorization", "UpToken " + token);
    xhr.send(pic);
}
~~~

### 当然文件大小也可以自己计算出来

~~~
function fileSize(str)
{
    var fileSize;
    if(str.indexOf('=')>0)
    {
        var indexOf=str.indexOf('=');
        str=str.substring(0,indexOf);//把末尾的’=‘号去掉
    }

    fileSize=parseInt(str.length-(str.length/8)*2);
    return fileSize;
}
~~~

### yii 保存base64编码图片

~~~
public function actionLogoUrl()
{
    $data = [];
    Yii::$app->response->format = Response::FORMAT_JSON;
    $base64 = Yii::$app->request->post('接收base64');
    if (preg_match('/^(data:\s*image\/(\w+);base64,)/', $base64, $result)){
        if (!is_dir(Yii::$app->basePath.'目录')){
            mkdir(Yii::$app->basePath.'目录');
        }
        $type = $result[2];
        $new_file = Yii::$app->basePath.'目录'.uniqid().".{$type}";
        file_put_contents($new_file, base64_decode(str_replace($result[1], '', $base64)));
    }
    return $data;
}
~~~




