---
layout: post
title:  "hadoop的所有组件的jps,启停指令"
date:   2018-02-08 13:14:24
categories: hadoop
tags: jps hadoop
excerpt:hadoop的所有组件的jps,启停指令,zk,kafka脚本,storm脚本(他没用一键启用)
mathjax: true
author: dingyun
---

* content
{:toc}

ZooKeeper是一个分布式的，开放源码的分布式应用程序协调服务

zk副产品 管理hbase  dfs(qjm,nfs)  yarn 主从架构  主的高可用

storm不是主从架构,但它的高可用由zk管理

kafka 的元数据由zk管理

hive   输入sql就能在在海量数据中做查询的数据仓库工具   mr
外表 (元数据) 和  内表   




dfs
NameNode
SecondaryNameNode
DataNode

mr
resourcemanager
nodemanager

hive
hiveserver2

habse
HMaster主
HRegionServer从节点

kafka
Kafka

zk
QuorumPeerMain

flume

strom
nimbus主
core
Supervisor从


1.启停命令
Zookeeper
zkServer.sh start
zkServer.sh stop/status/restart
zkCli.sh -server IP:Port

Hadoop(hdfs,yarn)
start-dfs.sh
start-yarn.sh
hadoop-daemon.sh stop zkfc
mr-jobhistory-daemon.sh start historyserver

Storm
storm nimbus >nimbusInit.log 2>&1 &
storm ui >uiCoreInit.log 2>&1 &
storm supervisor > superInit.log 2>&1 &
storm drpc > drpc.log 2>&1 &

Solr
./solr start
./solr stop
/home/solr/solr-5.5.2/ranger_audit_server/scripts/start_solr.sh
/home/solr/solr-5.5.2/ranger_audit_server/scripts/stop_solr.sh

Hbase
start-hbase.sh
stop-hbase.sh

Hive
hive --service metastore > metastore.log 2>&1 &
hive --service hiveserver2 > hiveserver2.log 2>&1 &

Kylin
kylin.sh start
kylin.sh stop

Ranger (Ranger Admin WebUI)
/home/ranger/ranger-0.6.0-admin
ranger-admin start
/home/usersync/ranger-0.6.0-usersync
ranger-usersync start

MySQL
/etc/init.d/mysqld start

2.页面和服务链接
Zookeeper   使用脚本
10.43.159.237: 2181
10.43.159.238: 2181
10.43.159.239: 2181

Hadoop WebUI
http://10.43.159.7:50070
http://10.43.159.9:50070

Hdfs
hdfs://10.43.159.7:9000
hdfs://10.43.159.9:9000

Yarn
http://10.43.159.7:8188
http://10.43.159.9:8188

Storm
WebUI :
http://10.43.159.237:18080
Nimbus:
10.43.159.237:6627

Solr
10.43.159.7:8983

Hbase
http://10.43.159.7:60010/

Kylin
http://zdh-9:7070/kylin

Rnger Admin
http://10.43.159.245:6080
admin/admin keyadmin/keyadmin

Atlas:
http://10.43.182.242:21000
