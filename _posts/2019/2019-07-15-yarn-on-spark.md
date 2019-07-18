---
layout: post
title:  "yarn的结构和基本概念以及spark依赖yarn执行的两种方式"
date:   2019-07-15 09:00
categories: yarn spark hadoop
tags: yarn spark
excerpt: 本文主要介绍yarn中的基本概念以及一个application在yarn执行的流程,包括spark使用yarn来执行任务的方式
mathjax: true
author: dingyun
---
* content
{:toc}
<p>http://yizhibi.6chemical.com/lucyBlog/xianrendege.mp3</p>

### 1.[yarn的各个组件](https://www.cnblogs.com/tgzhu/p/5818374.html)

1. resourcemanager(RM): RM对NM上的资源进行统一管理和调度,主要包括两个部分组件:

* Scheduler:交到集群的应用程序分配资源，并且对可用的资源和运行的队列进行限制。该组件完全插拔式的,用户可以根据自己的需求实现不同的调度器，目前YARN提供了FIFO、容量以及公平调度ApplicationsManager (AsM):这个组件用于管理整个集群应用程序的AM，负责接收应用程序的提交；为application master启动提供资源；监控应用程序的运行进度以及在应用程序出现故障时重启它。

2. NodeManager(NM):每个节点上的任务和资源管理器,功能包括:

* 定时向RM回报本节点上的内存,硬盘,CPU等资源的使用情况.
* 各个container的运行状态,还有接收并处理来自AM的container启动或停止等各种请求.

3. ApplicationMaster(AM):它是应用程序级别的，每个ApplicationMaster管理运行在YARN上的应用程序。

* YARN 将 ApplicationMaster看做是第三方组件，ApplicationMaster负责和ResourceManager scheduler协商资源，并且和NodeManager通信来运行相应的task。
* ResourceManager 为 ApplicationMaster 分配容器，这些容器将会用来运行task。
* ApplicationMaster 也会追踪应用程序的状态，监控容器的运行进度.
* 整个作业运行完成，其也会向 ResourceManager 注销自己.

4. Container:由 ResourceManager scheduler 服务动态分配的资源构成。

* 容器授予 ApplicationMaster 使用特定主机的特定数量资源的权限。
* ApplicationMaster 在容器中运行的，其在应用程序分配的第一个容器中运行。
* 在合适的容器中运行maptask和reducetask,并监控task运行

![img](https://upload-images.jianshu.io/upload_images/12698200-120c12c12f645c75.png?imageMogr2/auto-orient/)

### 2.一个app提交后的执行过程:

#### 2.1 一个MR的执行过程:

1. client向yarn提交job，ResourceManager开始分配资源(遵循Scheduler)，先开启一个Container,在Container中运行一个Application manager.
2. Application manager先找一台nodemanager启动Application master，计算任务所需的计算
3. Application master向Application manager（Yarn）申请运行任务所需的资源,Resource scheduler将资源封装发给Application master
4. Application master将获取到的资源分配给各个nodemanager,各个nodemanager得到任务和资源开始执行map task
5. map task执行结束后，开始执行reduce task,map task和 reduce task将执行结果反馈给Application master
6. Application master将任务执行的结果反馈pplication manager

#### 2.2 在yarn上启动的两种不同:

* -cluster:客户端生成作业信息提交给ResourceManager(RM),生成的AM位于NM,AM负责向YARN申请资源，并监督作业的运行状况。
* -client: AM仅仅向YARN请求Executor，Client会和请求的Container通信来调度他们工作，Client不能离开

### 3.spark-sql 和hive整合启动

#### 3.1 更改hive配置文件:

```xml
<configuration>
        <property>
                <name>javax.jdo.option.ConnectionURL</name>
                <value>jdbc:mysql://xxxxx:3306/hive? createDatabaseIfNotExist=true&amp;useSSL=false</value>
                <description>JDBC connect string for a JDBC metastore</description>
        </property>

        <property>
                <name>javax.jdo.option.ConnectionDriverName</name>
                <value>com.mysql.cj.jdbc.Driver</value>
                <description>Driver class name for a JDBC metastore</description>
        </property>
        <property>
                <name>javax.jdo.option.ConnectionPassword</name>
                <value>xxxxxx</value>
                <description>password to use against metastore database</description>
        </property>

        <property>
                <name>hive.server2.thrift.port</name>
                <value>10000</value>
                <description>password to use against metastore database</description>
        </property>
        <property>
                <name>hive.metastore.schema.verification</name>
                <value>false</value>
        </property>
    <property>
                <name>datanucleus.autoCreateSchema</name>
                <value>true</value>
                <description>password to use against metastore database</description>
    </property>
    <property>
                <name>datanucleus.metadata.validate</name>
                <value>false</value>
                <description>password to use against metastore database</description>
    </property>


</configuration>
```

#### 3.2启动spark-sql

```shell
./spark-sql --master local[2] --driver-class-path ~/software/mysql-connector-java-5.1.27.jar 执行

提交jar包实例:

./bin/spark-submit \
  --class com.myCompany.Main \
  --master yarn-cluster \
  --num-executors 3 \
  --driver-memory 1g \
  --executor-memory 11g \
  --executor-cores 1 \
  --files /etc/hive/conf/hive-site.xml \
  --jars lib/datanucleus-api-jdo-3.2.6.jar,lib/datanucleus-rdbms-3.2.9.jar,lib/datanucleus-core-3.2.10.jar \<br>  /home/spark/apps/YarnClusterTest.jar
```

