---
layout: post
title:  "hbase集群安装以及zk安装"
date:   2018-03-18 20:14:54
categories: hbase  zk
tags: hbase zk
---
* content
{:toc}


# 1.课程目标

Hbase shell语句

Zookeeper

Hbase集权搭建

Hbase的API

# 2.Hbase的shell操作

Create  &#39;表名&#39;,&quot;列簇名&quot;

Create &#39;u1&#39;,&#39;info&#39;,&#39;data&#39;   这种创建方式，没有历史数据；

## 2.1.创建有历史版本的表：

Create &quot;表名&quot;，{NAME=\&gt;&#39;列簇名&#39;，VERSIONS=\&gt;n }

N是一个数子   3 ，有3个历史版本

1. 5，有5个历史版本

创建了一个由3个历史版本的person表

hbase(main):003:0\&gt; create &#39;person&#39;,{NAME=\&gt;&#39;info&#39;,VERSIONS=\&gt;3}

Created table person

Took 1.5436 seconds

=\&gt; Hbase::Table - person

hbase(main):004:0\&gt;



## 2.2.获取数据：

Get  &#39;表名&#39;，&#39;rk&#39;,{CLOUMN=\&gt;&#39;列簇：列名&#39;，VERSIONS=\&gt;xxx}

Scan &#39;表名&#39;，{COLUMNS=\&gt;&#39;列簇：列名&#39;，VERSIONS=\&gt;xxx}



hbase(main):002:0\&gt; create &#39;person&#39;,{NAME=\&gt;&#39;info&#39;,VERSIONS=3}

SyntaxError: (hbase):2: syntax error, unexpected tRCURLY

create &#39;person&#39;,{NAME=\&gt;&#39;info&#39;,VERSIONS=3}

hbase(main):003:0\&gt; create &#39;person&#39;,{NAME=\&gt;&#39;info&#39;,VERSIONS=\&gt;3}

Created table person

Took 1.5436 seconds

=\&gt; Hbase::Table - person

hbase(main):004:0\&gt; put &#39;person&#39;,&#39;rk0001&#39;,&#39;info:name&#39;,&#39;x&#39;

Took 0.6678 seconds

hbase(main):005:0\&gt; get &#39;person&#39;,&#39;rk0001&#39;,&#39;info:name&#39;

COLUMN                          CELL

 info:name                      timestamp=1541382383101, value=x

1 row(s)

Took 0.2410 seconds

hbase(main):006:0\&gt; scan &#39;person&#39;

ROW                             COLUMN+CELL

 rk0001                         column=info:name, timestamp=1541382383101, value=x

1 row(s)

Took 0.0568 seconds

hbase(main):007:0\&gt; put &#39;person&#39;,&#39;rk0001&#39;,&#39;info:name&#39;,&#39;y&#39;

Took 0.0273 seconds

hbase(main):008:0\&gt; scan &#39;person&#39;

ROW                             COLUMN+CELL

 rk0001                         column=info:name, timestamp=1541382496866, value=y

1 row(s)

Took 0.0292 seconds

hbase(main):009:0\&gt; get &#39;person&#39;,&#39;rk0001&#39;,{COLUMN=\&gt;&#39;info:name&#39;,VERSIONS=\&gt;1}

COLUMN                          CELL

 info:name                      timestamp=1541382496866, value=y

1 row(s)

Took 0.0440 seconds

hbase(main):010:0\&gt; get &#39;person&#39;,&#39;rk0001&#39;,{COLUMN=\&gt;&#39;info:name&#39;,VERSIONS=\&gt;2}

COLUMN                          CELL

 info:name                      timestamp=1541382496866, value=y

 info:name                      timestamp=1541382383101, value=x

1 row(s)

Took 0.0809 seconds

hbase(main):011:0\&gt; get &#39;person&#39;,&#39;rk0001&#39;,{COLUMN=\&gt;&#39;info:name&#39;,VERSIONS=\&gt;5}

COLUMN                          CELL

 info:name                      timestamp=1541382496866, value=y

 info:name                      timestamp=1541382383101, value=x

1 row(s)

Took 0.0403 seconds

hbase(main):012:0\&gt; scan &#39;person&#39;,{COLUMNS=\&gt;&#39;info:name&#39;,VERSIONS=\&gt;3}

ROW                             COLUMN+CELL

 rk0001                         column=info:name, timestamp=1541382496866, value=y

 rk0001                         column=info:name, timestamp=1541382383101, value=x

1 row(s)

Took 0.0277 seconds

# 4.ZOOKEEPER

参考课件PPT






# 5.Zookeeper的投票机制（选举机制）



# 6.Zookeeper集群的搭建

## 6.1.上传  /use/zookeeper


## 6.2.解压

[root@zhiyou01 zookeeper]# tar -zxvf zookeeper-3.4.12.tar.gz

## 6.3.配置准备工作（3台）

1. jdk安装好
2. Hosts配置好
3. Ssh免密
4. 防火墙关闭

首先在一台电脑上配置好，然后发送到其他的电脑上；

## 6.4.配置

### 6.4.1.需要把conf目录下的zoo\_sample.cfg，改名为zoo.cfg

[root@zhiyou01 conf]# mv zoo\_sample.cfg  zoo.cfg


## 6.5.配置zoo.cfg

zookeeper的默认配置文件为zookeeper/conf/zoo\_sample.cfg，需要将其修改为zoo.cfg。其中各配置项的含义，解释如下：

1.tickTime：CS通信心跳时间

Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个tickTime 时间就会发送一个心跳。tickTime以毫秒为单位。

tickTime=2000

2.initLimit：LF初始通信时限

集群中的follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数（tickTime的数量）。

initLimit=5

3.syncLimit：LF同步通信时限

集群中的follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数（tickTime的数量）。

syncLimit=2

4.dataDir：数据文件目录

Zookeeper保存数据的目录，默认情况下，Zookeeper将写数据的日志文件也保存在这个目录里。

dataDir=/home/michael/opt/zookeeper/data

5.clientPort：客户端连接端口

客户端连接Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求。

clientPort=2181

6.服务器名称与地址：集群信息（服务器编号，服务器地址，LF通信端口，选举端口）

这个配置项的书写格式比较特殊，规则如下：

server.N=YYY:A:B

### 6.5.1.修改1 dataDir


### 6.5.2.在文件的最后追加

   server.1=192.168.64.100:2888:3888

 server.2=192.168.64.101:2888:3888

server.3=192.168.64.102:2888:3888




### 6.5.3.创建/usr/zookeeper/data目录


### 6.5.4.在data目录里面创建一个myid文件，文件的内容是server.xxx  ,就是xxx;比如过server.1  ,myid里面就是1


## 6.6.把zookeeper目录分发到其他电脑上

[root@zhiyou01 data]# scp /usr/zookeeper/  root@zhiyou02:/usr/zookeeper/

[root@zhiyou01 data]# scp -r /usr/zookeeper/ root@zhiyou03:/usr/zookeeper/

## 6.7.修改其他电脑上的myid



## 6.8.启动zk(3台)

/bin/.     ./zkServer.sh start




## 6.9.Jps查看（3台都有）


## 6.10.查看状态



# 7.Hbase集群的搭建

## 7.1.上传：

## 7.2.解压

[root@zhiyou01 hbase]# tar -zxvf hbase-2.0.0-bin.tar.gz

## 7.3.hadoop的hdfs-site.xml和core-site.xml 拷贝到hbase/conf下

[root@zhiyou01 hadoop]# cp hdfs-site.xml  /usr/hbase/hbase-2.0.0/conf/

[root@zhiyou01 hadoop]# cp core-site.xml /usr/hbase/hbase-2.0.0/conf/

## 7.4.修改hbase-env.sh

[root@zhiyou01 hadoop]# cd /usr/hbase/hbase-2.0.0/conf/

1.修改java\_home


2.修改zookeeper


## 7.5.修改hbase-site.xml

\&lt;!-- 指定hbase在HDFS上存储的路径--\&gt;

        \&lt;property\&gt;

                \&lt;name\&gt;hbase.rootdir\&lt;/name\&gt;

                \&lt;value\&gt;hdfs://zhiyou01:9000/hbase\&lt;/value\&gt;

        \&lt;/property\&gt;

                \&lt;!-- 指定hbase是分布式的--\&gt;

        \&lt;property\&gt;

                \&lt;name\&gt;hbase.cluster.distributed\&lt;/name\&gt;

                \&lt;value\&gt;true\&lt;/value\&gt;

        \&lt;/property\&gt;

                \&lt;!-- 指定zk的地址，多个用&quot;,&quot;分割--\&gt;

        \&lt;property\&gt;

                \&lt;name\&gt;hbase.zookeeper.quorum\&lt;/name\&gt;

                \&lt;value\&gt;zhiyou01:2181,zhiyou02:2181,zhiyou03:2181\&lt;/value\&gt;

        \&lt;/property\&gt;

        \&lt;property\&gt;

                \&lt;name\&gt;hbase.master.maxclockskew\&lt;/name\&gt;

                \&lt;value\&gt;150000\&lt;/value\&gt;

        \&lt;/property\&gt;

        \&lt;property\&gt;

                \&lt;name\&gt;hbase.master.info.port\&lt;/name\&gt;

                \&lt;value\&gt;60010\&lt;/value\&gt;

        \&lt;/property\&gt;

## 7.6.修改 regionservers

## 7.7.


## 7.8.拷贝到其他节点下

[root@zhiyou01 conf]# scp -r /usr/hbase/ root@zhiyou02:/usr/hbase/

[root@zhiyou01 conf]# scp -r /usr/hbase/ root@zhiyou03:/usr/hbase/

## 7.9.同步时间（3台都要执行）

centos 安装ntpdate 并同步时间

在命令行中做如下操作，来安装ntpdate

yum install -y ntp

继续在命令行中操作，进行同步时间

ntpdate 210.72.145.44

## 7.10.启动：

### 7.10.1.启动ZK

### 7.10.2.启动hdfs

### 7.10.3.启动hBase

[root@zhiyou01 conf]# cd /usr/hbase/hbase-2.0.0/bin/

[root@zhiyou01 bin]# ./start-hbase.sh

### 7.10.4.jps查看



### 7.10.5.浏览器查看：


# 8.注意：

Hbase在哪里启动，哪里就是HMaster

# 9.Zookeeper在HBase中的作用

1. Hbase的regionserver向zookeeper注册，提供hbase的regionserver的状态（是否在线）
2. Hmaster在启动的时候会将HBase的系统表-root,加载到zookeper里面，通过zookeeper获取到对应的表的元数据，以及所对应的hregionserver的信息；

1. 用户访问的时候首先访问的是zookeeper,然后访问到root表，然后访问到元数据（hregionserver），然后获取对应的数据；





# 10.HbaseAPI

## 10.1.准备工作：

1. 新建java项目
2. 导包：  hbase/lib下的所有的jar包

### 10.2.1.创建表

**package** com.zhiyou100.hbase;

**import** java.io.IOException;

**import** org.apache.hadoop.conf.Configuration;

**import** org.apache.hadoop.hbase.HBaseConfiguration;

**import** org.apache.hadoop.hbase.HColumnDescriptor;

**import** org.apache.hadoop.hbase.HTableDescriptor;

**import** org.apache.hadoop.hbase.TableName;

**import** org.apache.hadoop.hbase.client.Admin;

**import** org.apache.hadoop.hbase.client.Connection;

**import** org.apache.hadoop.hbase.client.ConnectionFactory;

**public**** class** HbaseAPI {

        //创建表

        **public**** static ****void** main(String[] args) **throws** IOException {

                //1.连接hbase  通过zookeeper来连接

                Configurationconf=HBaseConfiguration._create_();

                conf.set(&quot;hbase.zookeeper.quorum&quot;, &quot;192.168.64.100:2181,192.168.64.101:2181,192.168.64.102:2181&quot;);

                //2.建立连接

                Connection conn=ConnectionFactory._createConnection_(conf);

                //3.获取表的管理类

                Admin admin=conn.getAdmin();

                //建表操作  1.新建表  2.列簇   create &#39;stu&#39;,&#39;info&#39;

                //4.定义表

                HTableDescriptorhTableDescriptor= **new** HTableDescriptor(TableName._valueOf_(&quot;stu&quot;));

                //5.定义列簇

                HColumnDescriptorhColumnDescriptor= **new** HColumnDescriptor(&quot;info&quot;);

                //6.将列簇添加到表里面

                hTableDescriptor.addFamily(hColumnDescriptor);

                //7.执行建表操作

                admin.createTable(hTableDescriptor);

                admin.close();

                conn.close();







        }

}



### 10.2.2.查询表（get,scan）

### 10.2.3.修改表（put,delete）

# 11.Hbase在项目里面怎么使用

Hbase充当了一个数据库的角色；和mysql一样；

比如我要做这样一样操作：

统计出每一小时的交易额；



怎么设计这个数据库：

Mysql这么设计数据库；

Id    当前交易的时间   交易金额

1. 1        2018-11-05 17  100
2. 2    2018-11-05 17  50

Hbase数据库怎么设计：

Create &#39;t1&#39;,&#39;info&#39;

把rk设置成当前的时间，值是交易额

Put &#39;t1&#39;, &#39;2018115\_17&#39;,&#39;info:money:100&#39;;

Put
