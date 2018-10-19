---
layout: post
title:  "hadoop-install"
date:   2018-01-15 15:14:54
categories: linux
tags:  hadoop linux
mathjax: true
author: dingyun
---

* content
{:toc}

# 1. 集群规划

```
   | 集群节点分配 |
   | 主机名	| 主机IP |
    master1	192.168.101.3
    node1	192.168.100.101
    node2	192.168.100.102
    软件版本
    软件名称	版本号
    Java	1.8.0_152
    CentOS	CentOS-6.5-x64-1708
    Hadoop	2.7.7
    MySQL	5.7.20
    Hive	2.3.2
    各软件安装路径
    Hadoop	/opt/SoftWare/Hadoop/
    Java	/opt/SoftWare/Java/
    Hive	/opt/SoftWare/Hive
    MySQL	/opt/SoftWare/MySQL
```

## 按照安装linux步骤
[安装步骤](https://githubdingyun.github.io/2018/02/01/hadoop-hdfs-filesystemo/)
- 布置好虚拟机
- 安装好必备软件 关闭防火墙 同步时间 lrasz  rz sz工具上传下载
- 准备好软件安装包
- ssh互相通  authorized_keys (把别人的公钥放进来别人就可以免密访问你)  id_rsa  id_rsa.pub  known_hosts
- scp [file] root@node1:[file]

### 安装Hadoop
#### 卸载java

```sh
rpm -qa | grep jdk
rpm -e
```

#### 安装jdk
```sh
tar -zxvf 安装包
vim /etc/profile
编辑 java 环境变量
如下:
export JAVA_HOME=/opt/SoftWare/Java/jdk1.8.0_141
export JRE_HOME=/opt/SoftWare/Java/jdk1.8.0_141/jre
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib/rt.jar
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

source /etc/profile

```
#### 安装hadoop
```sh
解压安装包 放在自己喜欢的位置
tar -zxvf 安装包
添加环境变量
如下:
export HADOOP_HOME=/opt/SoftWare/Hadoop/hadoop-2.7.7
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_HOME=/opt/SoftWare/Hadoop/hadoop-2.7.7
export HADOOP_LOG_DIR=$HADOOP_HOME/logs
export YARN_LOG_DIR=$HADOOP_LOG_DIR
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

输入 env  $path 查看

```
### 配置hadoop使其可以运行
#### 7个文件
- 一个dns解析
>    `/etc/hosts` 文件配置域名解析

```
  127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4                                                                         
  ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
  192.168.101.3 master1
  192.168.101.4 node1
  192.168.101.5 node2
  192.168.101.6 node3

```
- 两个环境变量文件
>hadoop-env.sh    
>
>yarn-env.sh
>
>添加java环境变量:注意不能使用sh脚本,必须手写环境变量,即是绝对路径 `bug`
- 4个必要配置
  - yarn-site.xml

```
<configuration>
        <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
        </property>
        <property>
                <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
                <value>org.apache.hadoop.mapred.ShuffleHandler</value>
        </property>
        <property>
                <name>yarn.resourcemanager.address</name>
                <value>master1:8032</value>
        </property>
        <property>
                <name>yarn.resourcemanager.scheduler.address</name>
                <value>master1:8030</value>
        </property>
        <property>
                <name>yarn.resourcemanager.resource-tracker.address</name>
                <value>master1:8031</value>
        </property>
        <property>
                <name>yarn.resourcemanager.admin.address</name>
                <value>master1:8033</value>
        </property>
        <property>
                <name>yarn.resourcemanager.webapp.address</name>
                <value>master1:8088</value>
        </property>
</configuration>

```

  - core-site.xml

```
  <configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://master1:9000</value>
        </property>
        <property>
                <name>io.file.buffer.size</name>
                <value>131072</value>
        </property>
        <property>
                <name>hadoop.tmp.dir</name>
                <value>file:/usr/temp</value>
        </property>
        <property>
                <name>hadoop.proxyuser.root.hosts</name>
                <value>*</value>
        </property>
        <property>
                <name>hadoop.proxyuser.root.groups</name>
                <value>*</value>
        </property>
</configuration>
```

  - map-site-xml (此文件没有,请复制其模板类创建)

```
  <configuration>
        <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
        </property>
        <property>
                <name>mapreduce.jobhistory.address</name>
                <value>master1:10020</value>
        </property>
        <property>
                <name>mapreduce.jobhistory.webapp.address</name>
                <value>master1:19888</value>
        </property>
</configuration>
```

  - hdfs-site-xml

```
<configuration>
        <property>
                <name>dfs.namenode.secondary.http-address</name>
                <value>master1:9001</value>
        </property>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>file:/usr/dfs/name</value>
        </property>
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>file:/usr/dfs/data</value>
        </property>
        <property>
                <name>dfs.replication</name>
                <value>2</value>
        </property>
        <property>
                <name>dfs.webhdfs.enabled</name>
                <value>true</value>
        </property>
        <property>
                <name>dfs.permissions</name>
                <value>false</value>
        </property>
        <property>
                <name>dfs.web.ugi</name>
                <value> supergroup</value>
        </property>
</configuration>
```


### 启动集群
#### 1.格式化hdfs
```
hdfs namenode -format
hadoop dfs namenode -format
hdfs 产看命令 来退出安全模式
```
#### 2.启动
```
start-hdfs-start
start-env-start
or
start-all.sh
```
#### 验证
```
主节点
jps
1824 DataNode
2183 ResourceManager
2008 SecondaryNameNode
4506 Jps
1724 NameNode
2285 NodeManager

datanode
1604 DataNode
2188 Jps
1709 NodeManager
```
**访问网址**  
>主节点的50070 接口  以及8088接口
>
>当然这些也是可配置的
