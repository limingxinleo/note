---
title: vue上传图片
date: 2017-08-15 15:16:46
categories: "前端之巅"
tags: '前端'
---

[vue-core-image-upload](https://github.com/Vanthink-UED/vue-core-image-upload)


| Props | Type | Example | | Description |
| ------ | ------ | ------ | | ------ |
| url | String | '/crop.php' | | 服务端上传的地址 |
| text | String | 'Upload Image' | | 你需要显示按钮的文本 |
| inputOfFile | String | 'file' | | 上传服务端对应表单 name |
| extensions | String | 'png,jpg,gif' | | 限制的图片类型 |
| crop | Boolean | true | | 是否需要裁剪 |
| cropRatio | String | '1:1' | | 限制裁剪的形状 |
| cropBtn | Object | {ok:'Save','cancel':'Give Up'} | | 按钮文本 |
| maxFileSize | Number | 10485760(10M) | | 文件大小限制 |
| maxWidth | Number | 150 | | 限制裁剪图片的最大宽度 |
| maxheight | Number | 150 | | 限制裁剪图片的最大高度 |
| inputAccept | string | 'image/*' / 'image/jpg,image/jpeg,image/png' | | 赋予上传file的接受类型 |
| isXhr | Boolean | true | | 是否需要调用系统内自己的上传功能 |
| headers | Object |  {auth: xxxxx} | | 设置xhr上传 的header |

image uploading callback
imageUploaded: 当图片上传成功后的响应处理
imageChanged: 当选择图片后
imageUploading 图片上传过程中
errorHandle图片上传中的异常处理

~~~
<vue-core-image-upload
:crop="false"
@imageuploaded="imageuploaded"
inputOfFile="image"
:max-file-size="5242880"
url="https://uat.emmars.cn/upload/image"
:isXhr=true
>
</vue-core-image-upload>
~~~

~~~
<script>
    import VueCoreImageUpload  from 'vue-core-image-upload';

    // 日志接口
    import {log, triggerEvent} from '../common/js/Api/log.js'

    export default {
        name: 'fault',
        components: {
            'vue-core-image-upload': VueCoreImageUpload,
        },
        data() {
            return {
                imgurl: ''            }
        },
        mounted() {
            
        },
        methods: {
            imageuploaded(res) {
                alert(JSON.stringify(res))
//                if (res.errcode == 0) {
//                    this.src = res.data.src;
//                }
            }

        },

    }
</script>
~~~