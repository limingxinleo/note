# Sphinx
## 简介
> Sphinx由俄罗斯人Andrew Aksyonoff 开发的高性能全文搜索软件包，在GPL与商业协议双许可协议下发行。全文检索是指以文档的全部文本信息作为检索对象的一种信息检索技术。检索的对象有可能是文章的标题，也有可能是文章的作者，也有可能是文章摘要或内容。


### 写在前面
> sphinx本身是可以支持中文搜索的，只是不支持中文分词，需要安装中文分词插件，coreseek就是一个打包了mmseg中文分词插件和sphinx源码的安装包。
> 目前coreseek已经很久不更新了，稳定版3.2.14内带的的sphinx还是 0.9.9 release版本的；而sphinx可以通过设置为“一元切分模式”来支持搜索中文。
> 在实际使用中，搜索非中文的话，sphinx比coreseek要快；搜索短中文字符串的话，开启了“一元切分模式”的sphinx比coreseek要快；只有在搜索长中文字串时，coreseek的分词优势才能显现，比sphinx要快
> 所以根据你的应用场景来选择用哪个，如果是索引英文、数字、字符较多的数据，就用源生sphinx；如果是索引中文非常多非常长的数据，还是用coreseek吧。


### 特性
* 高速索引 (在新款CPU上,近10 MB/秒);
* 高速搜索 (2-4G的文本量中平均查询速度不到0.1秒);
* 高可用性 (单CPU上最大可支持100 GB的文本,100M文档);
* 提供良好的相关性排名
* 支持分布式搜索;
* 提供文档摘要生成;
* 提供从MySQL内部的插件式存储引擎上搜索
* 支持布尔,短语, 和近义词查询;
* 支持每个文档多个全文检索域(默认最大32个);
* 支持每个文档多属性;
* 支持断词;
* 支持单字节编码与UTF-8编码;

## 使用
### 安装
~~~
brew install --env=std --with-mysql sphinx
~~~

### 复制sphinx配置到自己的文件夹
* 我在mac环境下使用brew安装的sphinx，他的默认目录为/usr/local/Cellar/sphinx/2.2.11/etc。
* 我在~/Applications/php文件夹下新建了.sphinx目录存放其配置
故使用如下命令。
~~~
cp -r /usr/local/Cellar/sphinx/2.2.11/etc ~/Applications/php/.sphinx
~~~

### Sphinx配置
1. sphinx配置文件结构介绍（Source和Index都可以配置多个。）
~~~
Source 源名称1{     
    #添加数据源，这里会设置一些连接数据库的参数比如数据库的IP、用户名、密码等
    #设置sql_query、设置sql_query_pre、设置sql_query_range等后面会结合例子做详细介绍
    ……
}
Index 索引名称1{
     Source=源名称1
    #设置全文索引
     ……
}
Indexer{
    #设置Indexer程序配置选项，如内存限制等
    ……
}
Searchd{  
    #设置Searchd守护进程本身的一些参数
    ……
}
~~~

2. spinx配置案例详细解释
~~~
#定义一个数据源
source search_main
{
    #定义数据库类型
    type                 = mysql
    #定义数据库的IP或者计算机名
    sql_host             = localhost
    #定义连接数据库的帐号
    sql_user             = root
    #定义链接数据库的密码
    sql_pass             = test123
    #定义数据库名称
    sql_db               = test
    #定义连接数据库后取数据之前执行的SQL语句
    sql_query_pre        = SET NAMES utf8
    sql_query_pre        = SET SESSION query_cache_type=OFF
    #创建一个sph_counter用于增量索引
    sql_query_pre        = CREATE TABLE IF NOT EXISTS sph_counter \
                        ( counter_id INTEGER PRIMARY KEY NOTNULL,max_doc_id INTEGER NOT NULL)
    #取数据之前将表的最大id记录到sph_counter表中
    sql_query_pre        = REPLACEINTO sph_counter SELECT 1, MAX(searchid) FROM v9_search
    #定义取数据的SQL，第一列ID列必须为唯一的正整数值
    sql_query            = SELECT searchid,typeid,id,adddate,data FROM v9_search where \
                        searchid<(SELECT max_doc_id FROM sph_counter WHERE counter_id=1 ) \
                        andsearchid>=$start AND searchid<=$end
    #sql_attr_uint和sql_attr_timestamp用于定义用于api过滤或者排序，写多行制定多列
    sql_attr_uint        = typeid
    sql_attr_uint        = id
    sql_attr_timestamp   = adddate
    #分区查询设置
    sql_query_range      = SELECTMIN(searchid),MAX(searchid) FROM v9_search
    #分区查询的步长
    sql_range_step       = 1000
    #设置分区查询的时间间隔
    sql_ranged_throttle  = 0
    #用于CLI的调试
    sql_query_info       = SELECT *FROM v9_search WHERE searchid=$id
}
#定义一个增量的源
source search_main_delta : search_main
{
    sql_query_pre        = set names utf8
    #增量源只查询上次主索引生成后新增加的数据
    #如果新增加的searchid比主索引建立时的searchid还小那么会漏掉
    sql_query            = SELECT searchid,typeid,id,adddate,data FROM v9_search where  \
                        searchid>(SELECT max_doc_id FROM sph_counter WHERE counter_id=1 ) \
                        andsearchid>=$start AND searchid<=$end
    sql_query_range      = SELECT MIN(searchid),MAX(searchid) FROM v9_search where \
                        searchid>(SELECT max_doc_id FROM sph_counter WHERE counter_id=1 )
}
 
#定义一个index_search_main索引
index index_search_main
{
    #设置索引的源
    source               = search_main
    #设置生成的索引存放路径
    path                 =/usr/local/coreseek/var/data/index_search_main
    #定义文档信息的存储模式，extern表示文档信息和文档id分开存储
    docinfo              = extern
    #设置已缓存数据的内存锁定，为0表示不锁定
    mlock                = 0
    #设置词形处理器列表，设置为none表示不使用任何词形处理器
    morphology           = none
    #定义最小索引词的长度
    min_word_len         = 1
    #设置字符集编码类型，我这里采用的utf8编码和数据库的一致
    charset_type         = zh_cn.utf-8
    #指定分词读取词典文件的位置
    charset_dictpath     =/usr/local/mmseg3/etc
    #不被搜索的词文件里表。
    stopwords            =/usr/local/coreseek/var/data/stopwords.txt
    #定义是否从输入全文数据中取出HTML标记
    html_strip           = 0
}
#定义增量索引
index index_search_main_delta : index_search_main
{
    source               = search_main_delta
    path                 =/usr/local/coreseek/var/data/index_search_main_delta
}
 
#定义indexer配置选项
indexer
{
    #定义生成索引过程使用索引的限制
    mem_limit            = 512M
}
 
#定义searchd守护进程的相关选项
searchd
{
    #定义监听的IP和端口
    #listen              = 127.0.0.1
    #listen              =172.16.88.100:3312
    listen               = 3312
    listen               = /var/run/searchd.sock
    #定义log的位置
    log                  =/usr/local/coreseek/var/log/searchd.log
    #定义查询log的位置
    query_log            =/usr/local/coreseek/var/log/query.log
    #定义网络客户端请求的读超时时间
    read_timeout         = 5
    #定义子进程的最大数量
    max_children         = 300
    #设置searchd进程pid文件名
    pid_file             =/usr/local/coreseek/var/log/searchd.pid
    #定义守护进程在内存中为每个索引所保持并返回给客户端的匹配数目的最大值
    max_matches          = 100000
    #启用无缝seamless轮转，防止searchd轮转在需要预取大量数据的索引时停止响应
    #也就是说在任何时刻查询都可用，或者使用旧索引，或者使用新索引
    seamless_rotate      = 1
    #配置在启动时强制重新打开所有索引文件
    preopen_indexes      = 1
    #设置索引轮转成功以后删除以.old为扩展名的索引拷贝
    unlink_old           = 1
    # MVA更新池大小，这个参数不太明白
    mva_updates_pool     = 1M
    #最大允许的包大小
    max_packet_size      = 32M
    #最大允许的过滤器数
    max_filters          = 256
    #每个过滤器最大允许的值的个数
    max_filter_values    = 4096
}
~~~

3. 设置一个简单配置
新建 ~/Applications/php/.sphinx/etc/phalcon.conf
~~~
#
# Minimal Sphinx configuration sample (clean, simple, functional)
#

source phalcon
{
	type			= mysql

	sql_host		= localhost
	sql_user		= root
	sql_pass		= 910123
	sql_db			= phalcon
	sql_port		= 3306	# optional, default is 3306

	sql_query		= \
		SELECT id,user_nicename,signature \
		FROM test_sphinx 

	sql_attr_uint		= id
}


index phalcon_test_sphinx
{
	source			= phalcon
	path			= /Users/limx/Applications/php/.sphinx/data/phalcon
	#表示使用一元字符切分模式，从而得以对单个中文字符进行索引
	ngram_len       = 1 
	#表示要进行一元字符切分模式的字符集
    ngram_chars     = U+3000..U+2FA1F, U+FF41..U+FF5A->a..z, U+FF21..U+FF3A->a..z, A..Z->a..z, a..z 
}


indexer
{
	mem_limit		= 128M
}


searchd
{
	listen			= 9312
	#listen			= 9306:mysql41
	log				= /Users/limx/Applications/php/.sphinx/log/searchd.log
	query_log		= /Users/limx/Applications/php/.sphinx/log/query.log
	read_timeout	= 5
	max_children	= 30
	pid_file		= /Users/limx/Applications/php/.sphinx/run/searchd.pid
	seamless_rotate	= 1
	preopen_indexes	= 1
	unlink_old		= 1
	workers			= threads # for RT to work
	binlog_path		= /usr/local/var/data
}

~~~

### 使用
这样配置就完成了，接下来要生成索引和开启守护进程
~~~
indexer -c ~/Applications/php/.sphinx/etc/phalcon.conf --all
searchd -c ~/Applications/php/.sphinx/etc/phalcon.conf
~~~

1. 如果在建立索引的过程中出现”No fields in schema”的错误，原因是：sphinx对于sql数据源需要至少一个sql_field_string，当没有指定sql_field_string时会将数据源中没有明确指定为sql_attr_string的字符串字段用来做sql_field_string。当全部字符串字段设为sql_attr_string时不能建立索引，而随便注释一条sql_attr_string，或者选择一条sql_attr_string变为sql_field_string，就可以了
2. 如果数据库更新了，需要重新建立索引，重输一遍上面简历索引的指令就行
3. 如果重建索引时守护进程正在运行，会报错，需要运行下面的指令，会重建索引并且重开守护进程
~~~
indexer -c ~/Applications/php/.sphinx/etc/phalcon.conf --all --rotate
~~~