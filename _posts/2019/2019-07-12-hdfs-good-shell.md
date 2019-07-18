---
layout: post
title:  "链接hive数据库的正确方式"
date:   2019-07-13 11:34
categories: hive hadoop hdfs
tags: hadoop hive nohup
excerpt: 本文主要介绍了关于hive权限的配置文件,使用hive连接,使用hiveserver2后天启动,beeline和squi客户端链接hive
mathjax: true
author: dingyun
---
* content
{:toc}
<p>http://yizhibi.6chemical.com/lucyBlog/xianrendege.mp3</p>


要查看一个hive表文件总大小时，我们可以通过一行脚本快速实现，其命令如下：

 hadoop dfs -ls /user/hive/warehouse/lsgdb.db/p_api_trade_beijiajia|awk -F ' ' '{print $5}'|awk '{a+=$1}END{print a}'

32347122009



这样可以省去自己相加，下面命令是列出该表的详细文件列表

hadoop fs -ls  /user/hive/warehouse/test_table/ds=20151111



方法二：查看该表总容量大小，单位为Ｇ

 hadoop dfs -du /user/hive/warehouse/lsgdb.db/p_api_trade_beijiajia|awk ' { SUM += $1 } END { print SUM/(1024*1024*1024) }'
 hadoop dfs -du /user/hive/warehouse/hxwdb.db/test2|awk ' { SUM += $1 } END { print SUM/(1024*1024*1024) }'
 hadoop dfs -du  /examples/lsg/api_trade_beijiajia_withtime|awk ' { SUM += $1 } END { print SUM/(1024*1024*1024) }'

 /examples/lsg/api_trade_beijiajia_withtime

 /user/hive/warehouse/hxwdb.db/test2
