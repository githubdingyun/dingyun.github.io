---
layout: post
title:  "hdfs!"
date:   2018-10-16 15:14:54
categories: hadoop
tags: hdfs
excerpt: hdfs文件系统解决方案以及如何使用
mathjax: true
author: dingyun
---

* content
{:toc}
# 本文介绍hdfs是什么,以及hdfs使用方式及常见命令

## namenode:
### namenode的作用:
1.
### namenode的问题:

1. 高并发问题
2. 存储元数据有上限
    * 联邦机制(NFS Federation): (配置hdfs namenode的联邦机制来解决单个节点的存储和效率瓶颈问题)
    ![多nn节点机制]()
3. 单节点故障问题
高可用配置:HIgh Availablity



