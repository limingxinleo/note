## Composer 国内镜像
~~~
"repositories": {
    "packagist": {
        "type": "composer",
        "url": "https://packagist.phpcomposer.com"
    }
}
~~~
## Composer 配置国内镜像
~~~
# 华为云
composer config -g repo.packagist composer https://repo.huaweicloud.com/repository/php
# laravel学院
composer config -g repo.packagist composer https://packagist.laravel-china.org
# default
composer config -g repo.packagist composer https://packagist.org
~~~

## 优化自动加载索引
~~~
composer dump-autoload --optimize
~~~