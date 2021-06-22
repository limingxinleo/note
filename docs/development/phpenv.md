# 使用 PHPENV 安装 PHP

## 安装 PHPENV

[php-build](https://github.com/php-build/php-build)

```shell
curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash
echo ~/.phpenv/bin
sudo ln -s $PWD/phpenv /usr/local/bin/phpenv
```

## 安装 PHP

- 安装依赖

```shell
sudo apt install libxml2-dev libssl-dev libsqlite3-dev zlib1g-dev libbz2-dev libcurl4-openssl-dev libpng-dev \
libjpeg-dev libonig-dev libedit-dev libreadline-dev libtidy-dev libxslt-dev libzip-dev
```

- 安装PHP

```shell
phpenv install 8.0.7
```


