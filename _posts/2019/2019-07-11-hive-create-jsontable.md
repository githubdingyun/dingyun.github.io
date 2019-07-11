---
layout: post
title:  "对excel进行操作的工具类"
date:   2019-07-08 12:12:12
categories: excel util
tags: excel util
excerpt: 本文主要介绍了对excel进行简单操作的工具类以及常见使用方法
mathjax: true
author: dingyun
---
* content
{:toc}

<p>http://antiserver.kuwo.cn/anti.s?format=mp3|aac&rid=69662809&type=convert_url&response=res#.mp3</p>

##hive基于json格式创建hive表

###1.导入json解析包
首先需要引入json的hive解析包。
hive-hcatalog-core下载地址
hive里是使用命令添加jar包
add jar hdfs:////examples/lsg/hive-hcatalog-core-1.1.0-cdh5.13.3.jar;
###基于json的内容建表
```js
单条json文本的内容
{
	"platformId": 0,
	"shopId": 23,
	"tid": "AT201506010001",
	"tradeStatus": 30,
	"tradeTime": "2015-06-01 18:17:29.0",
	"payTime": "2015-06-01 18:17:29.0",
	"receiverProvince": 520000,
	"receiverCity": 522700,
	"receiverDistrict": 522728,
	"paid": 0.0000,
	"buyerNick": "d20b79ef6114fd4eff5c10177a00234b",
	"receiverMobile": "829FAA3E2EEBF8003F0BE8712E2EAC34",
	"receiverTelno": "d41d8cd98f00b204e9800998ecf8427e",
	"modified": "2018-11-02 17:28:41.0",
	"recId": 2
}
```

###hive建表语句:

```sql
--api_trade_beijiajia设计
drop table if exists api_trade_beijiajia;
create  table if not exists api_trade_beijiajia(
platformId string,
 shopId string,
 tid string COMMENT '平台订单编号',
 tradeStatus string COMMENT '处理状态10待递交20已递交30部分发货40已发货50部分结算60已完成70已取消',
 tradeTime string,
 payTime string,
 receiverProvince string,
 receiverCity  string  COMMENT '城市id',
 receiverDistrict  string COMMENT '地区ID',
 paid   string  COMMENT '买家已付金额，售前退款会变化',
 buyerNick string   COMMENT '买家帐号ID',
 receiverMobile  string  COMMENT '收件人手机',
 receiverTelno  string COMMENT '收件人电话',
 modified string ,
 recId string
)comment "订单数据测试表"
--partitioned by (partition_day string)
row format serde 'org.apache.hive.hcatalog.data.JsonSerDe';
--SHOW PARTITIONS api_trade_beijiajia;
load data inpath '/examples/lsg/testutf' overwrite into table api_trade_beijiajia;
--partitione (partition_day);
select * from api_trade_beijiajia;

```

###数据导入固定位置

`hadoop dfs -cp /user/hive/warehouse/lsgdb.db/api_trade_beijiajia2/partition_day=1/testutf  /examples/lsg`

###loda data 

实际上是把text放到表下,解析实际是解析文本内容,而不是真正的查询sql
load data inpath '/examples/lsg/testutf' overwrite into table `api_trade_beijiajia2`；
select  from `api_trade_beijiajia2`;

##静态分区和如何使用动态分区
### 设置参数：

>  使用动态分区表必须配置的参数 ：
>
>    set hive.exec.dynamic.partition =true（默认false）,表示开启动态分区功能
>    set hive.exec.dynamic.partition.mode = nonstrict(默认strict),表示允许所有分区都是动态的，否则必须有静态分区字段
>
>  动态分区相关的调优参数：
>
>  set  hive.exec.max.dynamic.partitions.pernode=100 （默认100，一般可以设置大一点，比如1000）
>
>   表示每个maper或reducer可以允许创建的最大动态分区个数，默认是100，超出则会报错。
>
>   set hive.exec.max.dynamic.partitions =1000(默认值)  表示一个动态分区语句可以创建的最大动态分区个数，超出报错
>
> set hive.exec.max.created.files =10000(默认) 全局可以创建的最大文件个数，超出报错。

执行如下命令：

```shell
--SET hive.exec.dynamic.partition=true;    #开启动态分区，默认是false
--SET hive.exec.dynamic.partition.mode=nonstrict;   #开启允许所有分区都是动态的，否则必须要有静态分区才能使用。
--SET hive.exec.max.dynamic.partitions.pernode = 1000;  
--SET hive.exec.max.dynamic.partitions=1000;
```

###创建表

```

```













create external table if not exists plc_data
(
PRIMS map<string,string> comment "plc基础信息",
PARAMS map<string,string> comment "plc明细信息"
)comment "plc数据汇总表"
partitioned by (partition_day string)
row format serde 'org.apache.hive.hcatalog.data.JsonSerDe'
LOCATION
  'hdfs:///data/flink/plc_data/';

serde格式注意是 org.apache.hive.hcatalog.data.JsonSerDe
将数据放置到相应的hdfs目录下面：
/data/flink/plc_data/partition_day=20181101

这里注意文件目录名称是partition_day=20181101
这个名称根据你的数据分区而定，使用命令挂在分区目录
alter table plc_data add partition (partition_day=20181101);

查询数据看下结果：
hive> select prims['PLCOrderCode'],params from plc_data;
OK
6ES7 313-5BF03-0AB0     {"A1_LL_P_Alarm":"ON"}
Time taken: 1.177 seconds, Fetched: 1 row(s)

```

```