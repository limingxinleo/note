# RTorrent

## 安装
~~~
sudo apt-get install rtorrent
~~~

## 使用
配置文件 ~/.rtorrent.rc
~~~
#最小允许peer数
min_peers = 3
#最大允许peer数
max_peers = 100
#最大同时上传用户数
max_uploads = 10
#最大下载950k/s 光纤用户使用,adsl请酌情修改
download_rate = 950
#最大上传200k/s 光纤用户使用,adsl请酌情修改
upload_rate = 200
# !! 下载目录
directory = /home/xulei/filedownload/downloads
# !! 下载历史目录（此目录中包括下载进度信息和DHT节点缓存）
session = /home/xulei/filedownload/session
# Keeps session data files even if torrent has finished
# session_on_completion = yes
# Not really required, but recommended - see rtorrent(1) man page
# session_lock = yes
# Setup A: Run through CRON
# Save session data every 5 mins, with a 4 min offset
schedule = session_save,240,300,session_save=
# !!（配置自动监视,把bt种子扔进～/universe目录就自动下载）
schedule = watch_directory,5,5,load_start=/home/xulei/filedownload/torrent

#硬盘空间低于100M就自动停止一切下载）
schedule = low_diskspace,5,60,close_low_diskspace=100M
#（在总上传量达到200M的情况下上传/下载率达到200%,或者在总上传量不足200M情况下上传/下载率达到2000%,则停止上传）
schedule = ratio,60,60,"stop_on_ratio=200,200M,2000"
# Enable the default ratio group.
# ratio.enable=
# Change the limits, the defaults should be sufficient.
#ratio.min.set=100
#ratio.max.set=300
#ratio.upload.set=50M
# Changing the command triggered when the ratio is reached.
#system.method.set = group.seeding.ratio.command, d.close=, d.erase=
#bt监听端口
port_range = 9400-9500
#随机从上面范围内选择端口
port_random = yes
# 是否使用UDP trackers，建议选yes
use_udp_trackers = yes
######开启DHT######
dht = on
#DHT所用的UDP端口
dht_port = 9501
#种子交换功能
peer_exchange = yes
#（上传缓存,每个种子10M,小内存用户请酌情修改）
# send_buffer_size = 10M
#（下载缓存,每个种子20M,小内存用户请酌情修改）
# receive_buffer_size = 20M
#(修改编码以避免中文乱码）
encoding_list=UTF-8
~~~