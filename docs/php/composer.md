## Composer 国内镜像
~~~
"repositories": {
    "packagist": {
        "type": "composer",
        "url": "https://mirrors.aliyun.com/composer"
    }
}
~~~
## Composer 配置国内镜像
~~~
# 阿里云
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer
# 华为云
composer config -g repo.packagist composer https://repo.huaweicloud.com/repository/php
# 腾讯云
composer config -g repo.packagist composer https://mirrors.cloud.tencent.com/composer
# default
composer config -g repo.packagist composer https://packagist.org
# 中国镜像
composer config -g repos.packagist composer https://php.cnpkg.org
# 交通大学
composer config -g repos.packagist composer https://packagist.mirrors.sjtug.sjtu.edu.cn
~~~

## 优化自动加载索引
~~~
composer dump-autoload --optimize
~~~


