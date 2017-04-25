## Nodejs 安装
* 终端执行
~~~
version='4.2.6'
wget https://npm.taobao.org/mirrors/node/v${version}/node-v${version}-linux-x64.tar.gz
tar xzf node-v${version}-linux-x64.tar.gz
mv node-v${version}-linux-x64 /usr/local/nodejs

echo 'export NODEJS_HOME=/usr/local/nodejs' >> ~/.bash_profile
echo 'export PATH=$PATH:$NODEJS_HOME/bin' >> ~/.bash_profile
source ~/.bash_profile

echo checking nodejs:
node -v
echo checking npm:
npm -v
~~~