# 使用 PHPENV 安装 PHP

## 安装 PHPENV

[php-build](https://github.com/php-build/php-build)

```shell
curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash
cd ~/.phpenv/bin
sudo ln -s $PWD/phpenv /usr/local/bin/phpenv
```

## 安装 PHP

- 安装依赖

```shell
sudo apt install libxml2-dev libssl-dev libsqlite3-dev zlib1g-dev libbz2-dev libcurl4-openssl-dev libpng-dev \
libjpeg-dev libonig-dev libedit-dev libreadline-dev libtidy-dev libxslt-dev libzip-dev autoconf pkg-config
```

- 安装PHP

```shell
phpenv install 8.0.7
```

- 修改 $PATH

接下来只需要将 `/home/user/.phpenv/versions/8.0/bin` 添加到对应的 `$PATH` 中就可以了。


