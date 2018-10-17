1. 集群规划
   | 集群节点分配 |
   | 主机名	| 主机IP |
    master	192.168.100.100
    slave1	192.168.100.101
    slave2	192.168.100.102
    slave3	192.168.100.103
    软件版本
    软件名称	版本号
    Java	1.8.0_152
    CentOS	CentOS-7-x64-1708
    Hadoop	2.7.5
    MySQL	5.7.20
    Hive	2.3.2
    各软件安装路径
    Hadoop	/opt/SoftWare/Hadoop/
    Java	/opt/SoftWare/Java/
    Hive	/opt/SoftWare/Hive
    MySQL	/opt/SoftWare/MySQL
2.各主机基础软件安装及操作
    由于使用的是最小化安装，因此这里需要安装不少软件才能进行后续操作
    2.1 openssh安装，便于远程上传文件

1
[root@master ~]# yum -y install openssh-clients
        2.2 同步时间工具

1
#安装ntpdate工具
2
[root@master ~]# yum -y install ntp ntpdate
3
#设置与网络时间同步
4
[root@master ~]# ntpdate cn.pool.ntp.org
5
#系统时间写入硬件时间
6
[root@master ~]# hwclock --systohc
        2.3 文件上传(rz)下载(sz)工具
        可以在Xshell工具中通过rz调出上传文件的窗口进行文件上传，也可以通过sz 文件名下载某一个文件

1
[root@master ~]# yum -y install lrzsz
        2.4 安装网络下载工具 wget

1
[root@test ~]# yum -y install wget
        2.4 关闭防火墙

1
#查看防火墙开启状态
2
[root@test ~]# systemctl status firewalld
3
#关闭防火墙
4
[root@test ~]# systemctl stop firewalld
5
#禁止开机启动防火墙
6
[root@test ~]# systemctl disable firewalld
7
#开启防火墙
8
[root@test ~]# systemctl start firewalld
9
#设置开机启动防火墙
10
[root@test ~]# systemctl enable firewalld
11
#重启防火墙
12
[root@test ~]# systemctl restart firewalld
3. 配置SSH免密码登录
        3.1 四台主机均按照步骤2安装基础软件工具（这里不再过多叙述）
        3.2 修改hosts文件，添加以下内容，四台主机均进行操作

1
[root@master ~]# vi /etc/hosts
2
#127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
3
#::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
4
192.168.100.100 master
5
192.168.100.101 slave1
6
192.168.100.102 slave2
7
192.168.100.103 slave3
        3.3 配置SSH免密码登录

1
#每台机器先使用ssh执行以下，以在主目录产生一个.ssh 文件夹
2
[root@master ~]# ssh master
3
#然后输入no即可
4
#每台机器均进入~/.ssh 目录进行操作
5
[root@master ~]# cd ~/.ssh
6
#输入以下命令，一路回车，用以产生公钥和秘钥
7
[root@master .ssh]# ssh-keygen -t rsa -P ''
8
#出现以下信息说明生成成功
9
Generating public/private rsa key pair.
10
Enter file in which to save the key (/root/.ssh/id_rsa):
11
Your identification has been saved in /root/.ssh/id_rsa.
12
Your public key has been saved in /root/.ssh/id_rsa.pub.
13
The key fingerprint is:
14
SHA256:6YO1h1emM9gcWvv9OT6ftHxLnjP9u8p25x1o30oq3No root@master
15
The key's randomart image is:
16
+---[RSA 2048]----+
17
|                 |
18
|                 |
19
|                 |
20
|         .       |
21
|        S o o    |
22
|       + O *  .  |
23
|      . B.X. o.+.|
24
|         +o=+=**%|
25
|          .oEo*^^|
26
+----[SHA256]-----+
27
#将每台机器上的id_rsa.pub公钥内容复制到authorized_keys文件中
28
[root@master .ssh]# cp id_rsa.pub authorized_keys
29
#将所有的authorized_keys文件进行合并（最简单的方法是将其余三台slave主机的文件内容追加到master主机上）
30
[root@slave1 .ssh]# cat ~/.ssh/authorized_keys | ssh root@master 'cat >> ~/.ssh/authorized_keys'
31
[root@slave2 .ssh]# cat ~/.ssh/authorized_keys | ssh root@master 'cat >> ~/.ssh/authorized_keys'
32
[root@slave3 .ssh]# cat ~/.ssh/authorized_keys | ssh root@master 'cat >> ~/.ssh/authorized_keys'
33
#查看master上的authorized_keys文件内容，类似如下即可
34
[root@master .ssh]# more authorized_keys
35
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5iw8+LlLxo0d77uaTChOKKJqfMHzp2jgzqV2hFAneFXqqWmr
36
Z4/FrMUPenmdss19bP4Up9G7PGbJu29yZDvkDwlmuqnVajYyDOsCl7PPXPWXMIlxMGUHgSXLnQQi6QnWp04vJKD
37
s0EbiRTd0ZYCSQefzJcZ8jbQ7bLYt6jtil7FfUupTdHTeexKKd8Mq3K7YFZHumKvhzs6wWiM+n41jANS083ss3O
38
YmAdO2cU0w1BhLVvJhdzd6fNG3RXVCXI2v0XxCUHiqI9Oewl2qPOfKzeyy09bJxo371Ezjmt8GMrkA/Ecepkvx1
39
2qwNzC9bSPLfbnPWVo2gIxe4mMaFqCFJ root@master
40
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3CkB3Jejavt+yFphsbciktWciJmbcUBOv3ZLPVLW18ZxXGZK
41
vG50EPXo/4By7P6IRW0wCa5YuckQEW+q6kmSatxqJ8e/K9a1mAk13N4f7V7M71Nn8IkujlF3gHYjKrmnEWpGJCy
42
5YBURzywIQTRArlIac1xj2SeM6q+gTMV9WrAKJupIRHli+W0kHVaYHNdKl7KMUT4KVrSl+h4wFwAd7Tcyj7JIbU
43
cCCL6o/v/LqGFwpcJfbfUsuKJJho+tImh41j7mSXR8kRbTSZkcq5KX+iANrANwOHZ58tV5KXmMQjuVq7aJ985C1
44
6hHssB6zq/zjAxpxAyQIeE8Incc8U8ix root@slave1
45
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC//uaMbzbkYqxdgZJSdq+gdQYldzMQ7D3SxsUaNO5oVnVOszw
46
+mbNnmL8vp1EUUehabQHPCAvCmLKUPXzfcxlyJEF/pnY77u4ySwsRVEpHvsDZbrclgCOrS6hW00sSx303KHLOgX
47
T70LfrmnohfUhvTxajzLXT+C8f5ZfTZ8meKD73HKl16jRwZQ8YhW9GUyuCkgQTGtKtTKPsRUd9LpAc/7/u8xvvv
48
NvTYPxgyTJcUMzGSOHh8J3upI54ykY0FgBkjs1fCUaDalxAgsHw9B1iyx706WbcT6ymiQVMKGnnnM6k2KPvUvfD
49
0swVfUSG+4ZsYSRHRTgWuiBbHoIr7DVd root@slave2
50
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDTzTTdGRTd1zts3m7uKobcgRom4lVyF9EdNOdbBWMucYjbCs
51
BgP1ideDDQed2TyBj3Szz3Yx6h1L4McGmATY/D9qRLml26VW/x0Tod8JYkqOQpQL9knLW2cwITnhLzq5VDugOix
52
06r/uweP3Zed9CO7ld3jUxJJNZCYpsNz+eUKq9SWM5+ehUu9pfZZu9zUk7Q01js3uCHzu1AhsajgNzgB4+YLLcc
53
dHBfxGg4ix5wuaF82PlEEh70hTdfRkq8pqPMZ+FIQtTgfD5XllKTcnPItUY23hc7Umx4I3ujOd810vzffWYK07c
54
Otv1r7LEcYtYqbZ6zIvII+M775iRkzQX root@slave3
55
#将master上的authorized_keys文件分发到其他主机上
56
[root@master .ssh]# scp ~/.ssh/authorized_keys root@slave1:~/.ssh/
57
[root@master .ssh]# scp ~/.ssh/authorized_keys root@slave2:~/.ssh/
58
[root@master .ssh]# scp ~/.ssh/authorized_keys root@slave3:~/.ssh/
59
#每台机器之间进行ssh免密码登录操作，包括自己与自己
60
[root@master ~]# ssh master
61
[root@master ~]# ssh slave1
62
[root@slave1 ~]# ssh master
63
[root@master ~]# ssh slave2
64
[root@slave2 ~]# ssh master
65
[root@master ~]# ssh slave3
66
[root@slave3 ~]# ssh master
67
[root@master ~]# ssh slave1
68
[root@slave1 ~]# ssh slave1
69
[root@slave1 ~]# ssh slave2
70
[root@slave2 ~]# ssh slave1
71
[root@slave1 ~]# ssh slave3
72
[root@slave3 ~]# ssh slave1
73
[root@slave1 ~]# ssh slave2
74
[root@slave2 ~]# ssh slave2
75
[root@slave2 ~]# ssh slave3
76
[root@slave3 ~]# ssh slave2
77
[root@slave2 ~]# ssh slave3
78
[root@slave3 ~]# ssh slave2
79
[root@slave2 ~]# ssh slave3
80
[root@slave3 ~]# ssh slave3
4. 安装配置Java环境并测试
        4.1 下载jdk
        下载地址：http://www.oracle.com/technetwork/java/javase/archive-139210.html
        4.2 卸载其他jdk
        如果centos中已经安装的有jdk，则需要先卸载当前jdk，重新安装新的jdk

1
#查询当前所有安装的jdk版本
2
[root@master ~]# rpm -qa|grep jdk
3
#如果什么都没有展示说明没有已安装的jdk，则无需卸载，如果出现以下jdk，则卸载之
4
copy-jdk-configs-2.2-3.el7.noarch
5
java-1.8.0-openjdk-1.8.0.131-11.b12.el7.x86_64
6
java-1.8.0-openjdk-headless-1.8.0.131-11.b12.el7.x86_64
7
#卸载jdk，使用下面的方法卸载即可
8

[root@master ~]# yum -y remove copy-jdk-configs-2.2-3.el7.noarch

#再次查询当前所有安装的jdk版本
10
[root@master ~]# rpm -qa|grep jdk
        4.3 开始安装jdk

1
#在master主节点上创建指定目录
2
[root@master ~]# mkdir -p /opt/SoftWare/Java
3
[root@master ~]# mkdir -p /opt/SoftWare/Hadoop
4
#进入到Java目录
5
[root@master ~]# cd /opt/SoftWare/Java
6
#使用rz命令从windows主机上传jdk压缩包到master节点
7
[root@master Java]# rz
8
#解压到当前目录
9
[root@master Java]# tar -zxvf jdk-8u152-linux-x64.tar.gz
10
#配置环境变量
11
[root@master Java]# vi /etc/profile
12
#在该文件后面追加一下内容
13
export JAVA_HOME=/opt/SoftWare/Java/jdk1.8.0_152
14
export JRE_HOME=/opt/SoftWare/Java/jdk1.8.0_152/jre
15
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib/rt.jar
16
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
17
#使刚才的设置生效
18
[root@master Java]# source /etc/profile
19
#检测是否配置成功
20
[root@master Java]# java -version
21
java version "1.8.0_152"
22
Java(TM) SE Runtime Environment (build 1.8.0_152-b16)
23
Java HotSpot(TM) 64-Bit Server VM (build 25.152-b16, mixed mode)
24
#其他主机同样的操作进行即可
5. 安装配置Hadoop并配置
        5.1 下载Hadoop到本地
    下载地址：http://hadoop.apache.org/releases.html
        5.2 上传至master节点

1
#上传
2
[root@master ~]# cd /opt/SoftWare/Hadoop
3
[root@master Hadoop]# rz
4
#解压
5
[root@master Hadoop]# tar -zxvf hadoop-2.7.5.tar.gz
        5.3 创建目录

1
#进入hadoop-2.7.5主目录
2
[root@master Hadoop]# cd hadoop-2.7.5
3
#创建以下目录，以备后用
4
[root@master hadoop-2.7.5]# mkdir tmp
5
[root@master hadoop-2.7.5]# mkdir logs
6
[root@master hadoop-2.7.5]# mkdir -p hdfs/name
7
[root@master hadoop-2.7.5]# mkdir -p hdfs/data
        5.4 修改配置
        5.4.1 修改hadoop-env.sh文件

1
[root@master hadoop-2.7.5]# vi etc/hadoop/hadoop-env.sh
2
#修改JAVA_HOME为以下内容，否则容易出现Hadoop无法启动问题
3
export JAVA_HOME=/opt/SoftWare/Java/jdk1.8.0_152
        5.4.2 修改yarn-env.sh文件

1
[root@master hadoop-2.7.5]# vi etc/hadoop/yarn-env.sh
2
#修改JAVA_HOME为以下内容
3
export JAVA_HOME=/opt/SoftWare/Java/jdk1.8.0_152
        5.4.3 编辑slaves文件

1
#该文件用于记录本集群有哪些数据节点
2
[root@master hadoop-2.7.5]# vi etc/hadoop/slaves
3
#删除该文件中原来的内容，添加以下内容
4
slave1
5
slave2
6
slave3
        5.4.4 修改core-site.xml文件

1
[root@master hadoop-2.7.5]# vi etc/hadoop/core-site.xml
    该文件为Hadoop的核心配置文件，非常重要

1
<!--在<configuration></configuration>中间添加一下内容-->
2
<property>
3
    <name>fs.defaultFS</name><!--定义Hadoop Master的URI和端口-->
4
    <value>hdfs://master:9000</value>
5
</property>
6
<property>
7
    <name>hadoop.tmp.dir</name><!--hadoop的临时存储目录-->
8
    <value>file:/opt/SoftWare/Hadoop/hadoop-2.7.5/tmp</value>
9
</property>
10
<property>
11
    <name>io.file.buffer.size</name><!--用作序列化文件处理时读写buffer的大小-->
12
    <value>131702</value>
13
</property>
        5.4.5 修改hdfs-site.xml文件

1
[root@master hadoop-2.7.5]# vi etc/hadoop/hdfs-site.xml
    该文件为Hadoop的HDFS的配置文件

1
<!--在<configuration></configuration>中间添加一下内容-->
2
<property><!--namenode节点数据存储目录-->
3
    <name>dfs.namenode.name.dir</name>
4
    <value>file:/opt/SoftWare/Hadoop/hadoop-2.7.5/hdfs/name</value>
5
</property>
6
<property><!--datanode数据存储目录-->
7
    <name>dfs.datanode.data.dir</name>
8
    <value>file:/opt/SoftWare/Hadoop/hadoop-2.7.5/hdfs/data</value>
9
</property>
10
<property><!--指定DataNode存储block的副本数量,不大于DataNode的个数就行，默认为3-->
11
    <name>dfs.replication</name>
12
    <value>2</value>
13
</property>
14
<property><!--指定master的http协议访问地址-->
15
    <name>dfs.namenode.secondary.http-address</name>
16
    <value>master:50090</value>
17
</property>
18
<property><!--指定master的https协议访问地址-->
19
    <name>dfs.namenode.secondary.https-address</name>
20
    <value>192.168.10.250:50091</value>
21
</property>
22
<property><!--必须设置为true，否则就不能通过web访问hdfs上的文件信息-->
23
    <name>dfs.webhdfs.enabled</name>
24
    <value>true</value>
25
</property>
        5.4.6 修改yarn-site.xml文件

1
[root@master hadoop-2.7.5]# vi etc/hadoop/yarn-site.xml

1
<property>
2
    <name>yarn.nodemanager.aux-services</name>
3
    <value>mapreduce_shuffle</value>
4
</property>
5
<property>
6
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
7
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
8
</property>
9
<property>
10
    <name>yarn.resourcemanager.address</name>
11
    <value>master:8032</value>
12
</property>
13
<property>
14
    <name>yarn.resourcemanager.scheduler.address</name>
15
    <value>master:8030</value>
16
</property>
17
<property>
18
    <name>yarn.resourcemanager.resource-tracker.address</name>
19
    <value>master:8031</value>
20
</property>
21
<property>
22
    <name>yarn.resourcemanager.admin.address</name>
23
    <value>master:8033</value>
24
</property>
25
<property>
26
    <name>yarn.resourcemanager.webapp.address</name>
27
    <value>master:8088</value>
28
</property>
29
<property>
30
    <name>yarn.nodemanager.resource.memory-mb</name>
31
    <value>2048</value>
32
</property>
33
        5.4.7 修改mapred-site.xml文件
        但是这个文件并不存在，先复制再打开

1
#使用cp命令复制一份出来，不要自己创建
2
[root@master hadoop-2.7.5]# cp etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
3
[root@master hadoop-2.7.5]# vi etc/hadoop/mapred-site.xml

1
<property><!--使用yarn运行mapreduce程序-->
2
    <name>mapreduce.framework.name</name>
3
    <value>yarn</value>
4
</property>
5
<property><!--MapReduce JobHistory Server地址-->
6
    <name>mapreduce.jobhistory.address</name>
7
    <value>master:10020</value>
8
</property>
9
<property><!--MapReduce JobHistory Server Web界面地址-->
10
    <name>mapreduce.jobhistory.webapp.address</name>
11
    <value>master:19888</value>
12
</property>
        5.5 文件分发
        将master节点上的Hadoop目录远程拷贝到其他slave节点

1
[root@master hadoop-2.7.5]# scp -r /opt/SoftWare/Hadoop root@slave1:/opt/SoftWare/
2
[root@master hadoop-2.7.5]# scp -r /opt/SoftWare/Hadoop root@slave2:/opt/SoftWare/
3
[root@master hadoop-2.7.5]# scp -r /opt/SoftWare/Hadoop root@slave3:/opt/SoftWare/
        5.6 修改环境变量

1
#各节点均编辑/etc/profile文件
2
[root@master hadoop-2.7.5]# vi /etc/profile
3
#添加以下内容
4
export HADOOP_HOME=/opt/SoftWare/Hadoop/hadoop-2.7.5
5
export HADOOP_LOG_DIR=$HADOOP_HOME/logs
6
export YARN_LOG_DIR=$HADOOP_LOG_DIR
7
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
8
#使设置立即生效
9
[root@master hadoop-2.7.5]# source /etc/profile
        5.7 格式化Hadoop

1
#输入以下命令
2
[root@master hadoop-2.7.5]# bin/hdfs namenode -format
3
#在最后出现以下内容说明格式化成功
4
18/03/01 10:07:59 INFO namenode.FSImage: Allocated new BlockPoolId: BP-1057357071-192.168.100.100-1519870079201
5
18/03/01 10:07:59 INFO common.Storage: Storage directory /opt/SoftWare/Hadoop/hadoop-2.7.5/hdfs/name has been successfully formatted.
6
18/03/01 10:07:59 INFO namenode.FSImageFormatProtobuf: Saving image file /opt/SoftWare/Hadoop/hadoop-2.7.5/hdfs/name/current/fsimage.ckpt_0000000000000000000 using no compression
7
18/03/01 10:07:59 INFO namenode.FSImageFormatProtobuf: Image file /opt/SoftWare/Hadoop/hadoop-2.7.5/hdfs/name/current/fsimage.ckpt_0000000000000000000 of size 321 bytes saved in 0 seconds.
8
18/03/01 10:07:59 INFO namenode.NNStorageRetentionManager: Going to retain 1 images with txid >= 0
9
18/03/01 10:07:59 INFO util.ExitUtil: Exiting with status 0
10
18/03/01 10:07:59 INFO namenode.NameNode: SHUTDOWN_MSG:
11
/************************************************************
12
SHUTDOWN_MSG: Shutting down NameNode at master/192.168.100.100
13
************************************************************/
14
#注意上面的第二行最后的successfully formatted
        5.8 启动Hadoop集群

1
#先启动HDFS,按照新版要求，不建议直接使用start-all.sh命令
2
[root@master hadoop-2.7.5]# sbin/start-dfs.sh
3
#然后会在控制台打印以下信息
4
Starting namenodes on [master]
5
master: starting namenode, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/hadoop-root-namenode-master.out
6
slave1: starting datanode, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/hadoop-root-datanode-slave1.out
7
slave2: starting datanode, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/hadoop-root-datanode-slave2.out
8
slave3: starting datanode, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/hadoop-root-datanode-slave3.out
9
Starting secondary namenodes [master]
10
master: starting secondarynamenode, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/hadoop-root-secondarynamenode-master.out
11
#然后启动YARN
12
[root@master hadoop-2.7.5]# sbin/start-yarn.sh
13
#然后会在控制台打印以下信息
14
starting yarn daemons
15
starting resourcemanager, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/yarn-root-resourcemanager-master.out
16
slave2: starting nodemanager, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/yarn-root-nodemanager-slave2.out
17
slave3: starting nodemanager, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/yarn-root-nodemanager-slave3.out
18
slave1: starting nodemanager, logging to /opt/SoftWare/Hadoop/hadoop-2.7.5/logs/yarn-root-nodemanager-slave1.out
        5.9 检测集群是否搭建成功
    5.9.1 使用jps命令查看

1
#master检测
2
[root@master hadoop-2.7.5]# jps
3
44658 ResourceManager
4
44509 SecondaryNameNode
5
44318 NameNode
6
44958 Jps
7
#slave节点检测
8
[root@slave1 ~]# jps
9
2262 DataNode
10
2360 NodeManager
11
2461 Jps
    5.9.2 使用WEB界面访问
    在浏览器地址栏中输入http://192.168.100.100:50070  即可

    在浏览器地址栏中输入 http://192.168.100.100:8088   即可

6. MySQL数据库的安装
    6.1 下载YUM源rpm安装包
    下载地址：https://dev.mysql.com/downloads/repo/yum/   选择 mysql57-community-release-el7-11.noarch.rpm下载

1
#下载mysql源
2
[root@master ~]# wget http://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
3
#安装mysql源
4
[root@master ~]# yum localinstall mysql57-community-release-el7-11.noarch.rpm
5
#检测源是否安装成功，显示以下信息表示源安装成功
6
[root@master ~]# yum repolist enabled | grep "mysql.*-community.*"
7
mysql-connectors-community/x86_64        MySQL Connectors Community           45
8
mysql-tools-community/x86_64             MySQL Tools Community                57
9
mysql57-community/x86_64                 MySQL 5.7 Community Server          247
        6.2 安装MySQL

1
[root@master ~]# yum install mysql-community-server
    6.3 启动MySQL服务

1
#启动MySQL服务
2
[root@master ~]# systemctl start mysqld
3
#查看MySQL服务启动状态
4
[root@master ~]# systemctl status mysqld
5
● mysqld.service - MySQL Server
6
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
7
   Active: active (running) since 三 2018-02-28 11:15:52 CST; 14s ago
8
     Docs: man:mysqld(8)
9
           http://dev.mysql.com/doc/refman/en/using-systemd.html
10
  Process: 11568 ExecStart=/usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid $MYSQLD_OPTS (code=exited, status=0/SUCCESS)
11
  Process: 11495 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
12
 Main PID: 11572 (mysqld)
13
   CGroup: /system.slice/mysqld.service
14
           └─11572 /usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pi...
15
16
2月 28 11:15:49 test systemd[1]: Starting MySQL Server...
17
2月 28 11:15:52 test systemd[1]: Started MySQL Server.
18
#设置开机自动启动
19
[root@master ~]# systemctl enable mysqld
20
#设置后台自动运行
21
[root@master ~]# systemctl daemon-reload
        6.4 修改root默认密码

1
#在日志文件中查看mysql的root用户默认密码
2
#如下，默认密码为root@localhost:后面的内容，即：itso(d#N>0rK
3
[root@master ~]# grep 'temporary password' /var/log/mysqld.log
4
2018-02-28T03:15:49.608817Z 1 [Note] A temporary password is generated for root@localhost: itso(d#N>0rK
5
#进入mysql
6
[root@master ~]# mysql -uroot -p
7
#输入密码itso(d#N>0rK
8
#修改密码
9
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
10
#在mysql5.7中必然会出现下面的额错误，原因是因为密码策略问题，密码不能太过简单
11
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
12
#然后可以查看一下密码策略，在此之前先更改一下密码，否则无论你操作什么都会提示你修改密码
13
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '12Zhang.';
14
Query OK, 0 rows affected (0.00 sec)
15
#查看密码策略
16
mysql> show variables like '%password%';
17
+---------------------------------------+--------+
18
| Variable_name                         | Value  |
19
+---------------------------------------+--------+
20
| default_password_lifetime             | 0      |
21
| disconnect_on_expired_password        | ON     |
22
| log_builtin_as_identified_by_password | OFF    |
23
| mysql_native_password_proxy_users     | OFF    |
24
| old_passwords                         | 0      |
25
| report_password                       |        |
26
| sha256_password_proxy_users           | OFF    |
27
| validate_password_check_user_name     | OFF    | 设为 ON 时密码中不允许包含用户名
28
| validate_password_dictionary_file     |        | 用于验证密码强度的字典文件路径，策略为STRONG才需要
29
| validate_password_length              | 8      | 最小长度为8个字符
30
| validate_password_mixed_case_count    | 1      | 至少1个大小写字母（各一个）
31
| validate_password_number_count        | 1      | 至少1个数字
32
| validate_password_policy              | MEDIUM | 密码策略，默认为MEDIUM策略
33
| validate_password_special_char_count  | 1      | 至少1个特殊字符
34
+---------------------------------------+--------+
35
#取消密码策略检查
36
#修改/etc/my.cnf文件，在文件中添加以下内容以禁用密码策略
37
validate_password=off
38
[root@master ~]# vi /etc/my.cnf
39
#重新启动mysql服务
40
[root@master opt]# systemctl restart mysqld
41
#再次进入mysql，修改密码
42
[root@master ~]# mysql -uroot -p
43
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
     6.5 修改数据库编码为utf-8

1
#在/etc/my.cnf文件中的[mysqld]内添加以下内容
2
character_set_server=utf8
3
init_connect='SET NAMES utf8'
4
[root@master ~]# vi /etc/my.cnf
        6.6 添加root用户的远程登录权限
        默认只允许root帐户在本地登录，如果要在其它机器上连接mysql，必须修改root允许远程连接，或者添加一个允许远程连接的帐户

1
#进入mysql
2
[root@master ~]# mysql -uroot -p123456
3
#修改root的远程访问权限
4
#root代表用户名 , %代表任何主机都可以访问 , 123456为root访问的密码
5
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
6
#flush privileges刷新MySQL的系统权限,使其即时生效，否则就重启服务器
7
mysql> FLUSH PRIVILEGES;
8
#退出
9
mysql> exit;
7. Hive安装
    为了方便操作Hive的服务端和客户端均安装在master节点上
    7.1 下载
    下载地址：http://mirrors.hust.edu.cn/apache/hive/
        7.2 上传并解压

1
#创建Hive目录
2
[root@master ~]# mkdir /opt/SoftWare/Hive
3
#进入到Hive目录
4
[root@master ~]# cd /opt/SoftWare/Hive
5
#通过xshell工具上传至master主机
6
[root@master Hive]# rz
7
#解压
8
[root@master Hive]# tar -zxvf apache-hive-2.3.2-bin.tar.gz
9
#修改文件夹的名字
10
[root@master Hive]# mv apache-hive-2.3.2-bin hive-2.3.2
        7.3 配置环境变量

1
#打开配置文件
2
[root@master Hive]# vi /etc/profile
3
#在后面追加以下内容
4
export HIVE_HOME=/opt/SoftWare/Hive/hive-2.3.2
5
export PATH=$PATH:$HIVE_HOME/bin
6
#使设置生效
7
[root@master Hive]# source /etc/profile
    7.4 修改配置文件hive-site.xml
        该文件不存在，需要复制hive-default.xml.template来创建

1
#进入到hive-2.3.2目录
2
[root@master Hive]# cd hive-2.3.2/
3
#创建hive-site.xml文件
4
[root@master hive-2.3.2]# cp conf/hive-default.xml.template conf/hive-site.xml
5
[root@master hive-2.3.2]# vi conf/hive-site.xml
6
#创建指定目录
7
[root@master hive-2.3.2]# hadoop fs -mkdir -p /hive/tmp
8
[root@master hive-2.3.2]# hadoop fs -mkdir -p /hive/logs
9
[root@master hive-2.3.2]# hadoop fs -mkdir -p /hive/warehouse
    修改配置如下:

1
<property><!--数据库连接地址，使用MySQL存储元数据信息-->
2
    <name>javax.jdo.option.ConnectionURL</name>
3
    <value>jdbc:mysql://master:3306/metastore?createDatabaseIfNotExist=true&amp;useSSL=false</value>
4
</property>
5
  <property><!--数据库驱动-->
6
    <name>javax.jdo.option.ConnectionDriverName</name>
7
    <value>com.mysql.jdbc.Driver</value>
8
  </property>
9
  <property><!--数据库用户名-->
10
    <name>javax.jdo.option.ConnectionUserName</name>
11
    <value>root</value>
12
    <description>Username to use against metastore database</description>
13
  </property>
14
<property><!--密码-->
15
    <name>javax.jdo.option.ConnectionPassword</name>
16
    <value>123456</value>
17
    <description>password to use against metastore database</description>
18
  </property>
19
  <property><!--HDFS路径，用于存储不同 map/reduce 阶段的执行计划和这些阶段的中间输出结果。-->
20
    <name>hive.exec.local.scratchdir</name>
21
    <value>/hive/tmp</value>
22
  </property>
23
  <property><!--Hive 查询日志所在的目录，如果该值为空，将不创建查询日志。-->
24
    <name>hive.querylog.location</name>
25
    <value>/hive/logs</value>
26
  </property>
27
  <property><!--本地表的默认位置-->
28
    <name>hive.metastore.warehouse.dir</name>
29
    <value>/hive/warehouse</value>
30
  </property>
31
  <property>
32
    <name>hive.metastore.uris</name><!--Hive连接到该URI请求远程元存储的元数据-->
33
    <value>thrift://master:9083</value>
34
  </property>
35
  <property><!--关闭本地模式，此项不存在，需要自己添加-->
36
     <name>hive.metastore.local</name>
37
     <value>false</value>
38
  </property>
39
  <property>
40
    <name>hive.server2.logging.operation.log.location</name>
41
    <value>/hive/logs</value>
42
  </property>
43
<property>
44
    <name>hive.downloaded.resources.dir</name>
45
    <value>/hive/tmp/${hive.session.id}_resources</value>
46
  </property>
        7.5 修改配置文件

1
[root@master hive-2.3.2]# vi bin/hive-config.sh
2
#添加以下内容
3
export JAVA_HOME=/opt/SoftWare/Java/jdk1.8.0_152
4
export HADOOP_HOME=/opt/SoftWare/Hadoop/hadoop-2.7.5
5
export HIVE_HOME=/opt/SoftWare/Hive/hive-2.3.2
        7.6 复制MySQL的驱动jar到hive/lib目录

1
[root@master hive-2.3.2]# cd lib
2
[root@master lib]# rz
        7.7 对Hive进行初始化并启动Hive

1
[root@master lib]# cd $HIVE_HOME/bin
2
[root@master bin]# schematool -initSchema -dbType mysql
3
#出现以下信息代表初始化成功
4
SLF4J: Class path contains multiple SLF4J bindings.
5
SLF4J: Found binding in [jar:file:/opt/SoftWare/Hive/hive-2.3.2/lib/log4j-slf4j-impl-2.6.2.jar!/org/slf4j/impl/StaticLoggerBinder.class]
6
SLF4J: Found binding in [jar:file:/opt/SoftWare/Hadoop/hadoop-2.7.5/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
7
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
8
SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
9
Metastore connection URL:    jdbc:mysql://master:3306/metastore?createDatabaseIfNotExist=true
10
Metastore Connection Driver :    com.mysql.jdbc.Driver
11
Metastore connection User:   root
12
Sun Mar 04 15:30:33 CST 2018 WARN: Establishing SSL connection without server's identity verification is not recommended. According to MySQL 5.5.45+, 5.6.26+ and 5.7.6+ requirements SSL connection must be established by default if explicit option isn't set. For compliance with existing applications not using SSL the verifyServerCertificate property is set to 'false'. You need either to explicitly disable SSL by setting useSSL=false, or set useSSL=true and provide truststore for server certificate verification.
13
Starting metastore schema initialization to 2.3.0
14
Initialization script hive-schema-2.3.0.mysql.sql
15
Sun Mar 04 15:30:34 CST 2018 WARN: Establishing SSL connection without server's identity verification is not recommended. According to MySQL 5.5.45+, 5.6.26+ and 5.7.6+ requirements SSL connection must be established by default if explicit option isn't set. For compliance with existing applications not using SSL the verifyServerCertificate property is set to 'false'. You need either to explicitly disable SSL by setting useSSL=false, or set useSSL=true and provide truststore for server certificate verification.
16
Initialization script completed
17
Sun Mar 04 15:30:36 CST 2018 WARN: Establishing SSL connection without server's identity verification is not recommended. According to MySQL 5.5.45+, 5.6.26+ and 5.7.6+ requirements SSL connection must be established by default if explicit option isn't set. For compliance with existing applications not using SSL the verifyServerCertificate property is set to 'false'. You need either to explicitly disable SSL by setting useSSL=false, or set useSSL=true and provide truststore for server certificate verification.
18
schemaTool completed
19
#启动hive服务端
20
[root@master bin]# hive --service metastore
21
#启动Hive客户端
22
[root@master bin]# hive
23
#输入show tables;显示以下信息，说明Hive已经启动
24
hive> show tables;
25
OK
26
Time taken: 1.594 seconds