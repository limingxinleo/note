# 如何使用 Swoole Compiler

Hyperf项目线上运行时，务必开启 `SCAN_CACHEABLE`，这样在项目启动时，只要缓存存在时，就不会实例化 `BetterReflection` 并扫描所有注解。

所以，在我们要加密代码时，务必按照以下步骤进行：

- 开启 `SCAN_CACHEABLE`
- 执行 `composer dump-autoload -o` 优化索引的同时删除 `runtime/container` 目录
- 执行 `php bin/hyperf.php` 生成 `runtime/container`
- 修改 `compiler.config`，配置以下参数

```
# PHP版本
php_version=7.2

# 需要加密的PHP 文件/文件夹 路径
php_files_path=/opt/www/compiler

# 生成的加密文件打包路径
compiled_archived_path=/opt/www/compiler/dst.tar

# 设置加密文件黑名单的示例
exclude_list=("/opt/www/compiler/vendor" "/opt/www/compiler/test" "/opt/www/compiler/config")

# 是否保留注释
# 此选项留空或者0代表不保留，1代表保留注释，有的框架会用注释做路由配置，这种情况下需要保留注释
# 在加密器2.1.3以后的版本loader2.1.3版本以后并且php7.1以上 设置此参数为1 除了保留注释 还会保留文件的命名空间、use信息、以及声明的类，在loader端可以通过api获取，具体用法可以联系客服
save_doc=1
```

- 执行 `swoole-compiler` 生成加密代码
- 复制 `dst.tar` 给客户，并提供对应的 `swoole_loader.so`
- 客户配置扩展，并解压缩代码，然后运行
