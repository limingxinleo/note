## Nodejs 安装
* 终端执行
~~~
#!/usr/bin/env bash
version='7.9.0'
wget https://npm.taobao.org/mirrors/node/v${version}/node-v${version}-linux-x64.tar.gz
tar xzf node-v${version}-linux-x64.tar.gz
mkdir -p /usr/local/nodejs/${version}
cp -rf node-v${version}-linux-x64/* /usr/local/nodejs/${version}

ln -sf /usr/local/nodejs/${version}/bin/node /usr/local/bin/node
ln -sf /usr/local/nodejs/${version}/bin/npm /usr/local/bin/npm

echo checking nodejs:
node -v
echo checking npm:
npm -v
# 设置镜像源
npm config set registry=http://registry.npm.taobao.org
~~~