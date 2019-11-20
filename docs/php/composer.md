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
# 阿里云
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
# 华为云
composer config -g repo.packagist composer https://repo.huaweicloud.com/repository/php
# laravel学院
composer config -g repo.packagist composer https://packagist.laravel-china.org
# 腾讯云
composer config -g repo.packagist composer https://mirrors.cloud.tencent.com/composer
# default
composer config -g repo.packagist composer https://packagist.org
# 中国镜像
composer config -g repos.packagist composer https://php.cnpkg.org
~~~

## 优化自动加载索引
~~~
composer dump-autoload --optimize
~~~


