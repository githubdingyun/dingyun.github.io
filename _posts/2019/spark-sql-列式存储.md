---
layout: post
title:  "新一代列式存储格式Parquet以及spark-sql"
date:   2019-07-17 09:00
categories: Parquet spark hadoop
tags: Parquet
excerpt: 本文主要介绍使用列式存储的优点以及parquet在spark中的使用
mathjax: true
author: dingyun
---
* content
{:toc}
<p>http://yizhibi.6chemical.com/lucyBlog/xianrendege.mp3</p>

---

## 列存储还是行存储

[列存储还是行存储 ](https://www.infoq.cn/article/bigdata-store-choose/)的选择和介绍 

---

## hbase列簇数据库:

[hbase的存储方式:列簇存储](https://www.iteblog.com/archives/2498.html)

### hbase是列式数据库吗?

  其实**HBase 不是列式存储数据库**！不管是存储在内存的 MemStore，还是存储在 HDFS 上的 HFile，其都是基于 LSM（Log-Structured Merge-Tree）结构存储的。(一整行数据在磁盘结构上是在一起的,更新时可能不在一起),而列式数据库在磁盘结构上是一列一列列存储的,一整行数据在磁盘结构上一般不在一起.

### hbase存储结构

​     Hbase不是列示存储的数据库,因为在物理结构上 为LSM（Log-Structured Merge-Tree）结构存储,它更倾向于一个强化版本的key-value数据库===>{row key, column(= + ), version}.

​    每次对数据的某一个值的更新并不会删除原来版本的数据,而是会插入一个更新的版本.

###  [hbase的物理结构](https://www.cnblogs.com/gaopeng527/p/4967186.html)

---

## Parquet

[新一代列式存储格式Parquet](https://blog.csdn.net/yu616568/article/details/50993491)

Parquet：

1. 与ORC类似，基于Google dremel
2. Schema 存储在footer
3. 列式存储
4. 高度压缩比并包含索引
5. 相比ORC的局限性，parquet支持的大数据组件范围更广

## ORC

[高压缩比并支持索引的存储格式ORC](https://www.cnblogs.com/ITtangtang/p/7677912.html)

- 面向列的存储格式
- 由Hadoop中RC files 发展而来，比RC file更大的压缩比，和更快的查询速度
- Schema 存储在footer中
- 不支持schema evolution
- 支持事务(ACID)
- 为hive而生，在许多non-hive MapReduce的大数据组件中不支持使用
- 高度压缩比并包含索引

---

## AVRO

[使用数据存储格式的选择因素](https://blog.csdn.net/dylanzr/article/details/84553434)

1. 主要为行存储
2. 设计的主要目标是为了满足[schema evolution](https://martin.kleppmann.com/2012/12/05/schema-evolution-in-avro-protocol-buffers-thrift.html)
3. )
4. schema和数据保存在一起

---

## [速度比较](https://yq.aliyun.com/articles/71180)

![613c363d25eac16b4a86924c2b02725dc4e5b16c](https://yqfile.alicdn.com/613c363d25eac16b4a86924c2b02725dc4e5b16c.png)

---

## hive SerDe包括内置类型以及spark读取

Avro
ORC
RegEx
Thrift
Parquet
CSV
JsonSerDe

## 内存列式数据库的思考

[PowerDrill2012列式存储设计和思考 ](https://zhuanlan.zhihu.com/p/38224411)





---

## [Druid](https://my.oschina.net/weiweiblog/blog/1928955)

Druid功能介于*PowerDrill*和Dremel之间，它几乎*实现*了Dremel的所有功能，并且从*PowerDrill*吸收一些有趣的数据格式。

[小米实践](https://zhuanlan.zhihu.com/p/25593670)

[快手实践](https://www.infoq.cn/article/IWfHmTig_KNAeEJKF8eS)

[druid为什么好用](http://www.sohu.com/a/283270105_463994)

[OLAP和OLTP](https://baijiahao.baidu.com/s?id=1611554859260686629&wfr=spider&for=pc)



![preview](https://pic2.zhimg.com/v2-e4c0d006d8ccb2a92a8730b8906cdf5d_r.jpg)

---

