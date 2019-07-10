---
layout: post
title:  "kafka的介绍以及和其它消息队列的区别"
date:   2019-07-01 10:11:11
categories: kafka
tags: kafka hadoop
excerpt: 本文主要介绍了kafka的介绍以及和其它消息队列的区别
mathjax: true
author: dingyun
---

* content
{:toc}

## broker集群：

### kafka内部实现原理

![img](https://img2018.cnblogs.com/blog/1606721/201903/1606721-20190319150122451-727526976.png)

### 结构： broker—id ， paration （leader）， （sagement） offset



### 日志结构：

>  存储位置可以通过参数进行设置
>
> ​    日志文件下有多个topic-partition0文件，文件下有多个segment分段，一个segment分段包括log文件和index文件
>
> ​    log文件存储消息，文件名表示最后的offset值，index存储文件的索引，方便找到某个offset消息

### broker的负载均衡保证：  

![img](https://img2018.cnblogs.com/blog/1606721/201903/1606721-20190319150638198-1995552153.png)

* 分区选择策略=>数据生产放入哪个partation的算法

```
分区选择策略：
        （1）若指定分区则直接使用
        （2）若有指定key则求key的hash值对分区数取模运算
        （3）否则使用轮询的方式选择分区
```



* 生产者的分区分配算法（决定leader 的选举和broker 的架构）

```
触发条件：新增broker或减少broker，新增分区或者减少分区，每一个操作对全局重新执行该算法
分区的分配：
        （1）将所有的broker和待分配的partition排序
        （2）第i个分区分配到（i%n）个broker上（这个分区就是leader）
        （3）将第i个分区的第j个备份分配到第（(i+j)%n）个broker上
```



* 消费者的分区分配算法（决定那个消费者消费谁）

```
  2. 分区分配算法（分配原则：同组内多个消费者不可以消费同一个分区,同组内的消费者可以消费不同的topic） ：
        （1）range：
                    同一组内的消费者按名称字典序排序，平均分配同一topic中的分区，若不能整除，多余部分一一分配给其中一部分消费者。
                特殊状态下：
                        若同一组内的消费者同时消费多个topic，例如：
                        同一组两个消费者c0和c1，两个topic t0和t1，每个topic有三个分区，t0p0,t0p1,t0p2,t1p0,t1p1,t1p2;
                        分配情况如下：
                        c0: top0, t0p1, t1p0, t1p1
                        c1: t0p2, t1p2
          (2) roundrobin(轮询):
                与前面的方法最大的不同就是不再局限于某个topic
                对于上述的情况分配结果如下：
                c0: t0p0, t0p2, t1p1
                c1: t0p1, t1p0, t1p2
                特殊情况下会有问题：
                    3个topic t0(p0), t1(p0, p1), t2(p0, p1, p2),同组2个消费者c0消费（t0），c1消费（t0，t1），c2消费（t0，t1，t2）
                    按照轮询的方法分配如下：
                    c0: t0p0
                    c1: t1p0
                    c2: t1p1, t2p0, t2p1, t2p2
             (3)手动指定分区
```



* **Consumer Rebalance**算法  ：

```
触发条件：（1）Consumer增加或删除会触发 Consumer Group的Rebalance
		（2）Broker的增加或者减少都会触发 Consumer Rebalance
触发结果：
具体算法：
```

### leader选举： 1.正常2.当leader宕机后

### kafkaController核心组件和意义

### 存储地址和数据结构：

### 日志持久化时长：

> kafka生成每个主题时默认日志保存是7天，可以在生成topic时进行调整。
>
> 命令：  kafka-topics.sh --zookeeper node1:2181 -topic xxxx --alter --config retention.ms=259200000
>
> 也可以手动删除日志:步骤如下：
>
> ​                              1.停止Kafka运行；2、删除Kafka消息日志；3、修改ZK的偏移量；4、重启Kafka;



### 数据写入过程：

生产者生产消息先由序列化器序列化，如果未选择分区则交由分区器选择分区放进相应的分区队列中（分区选择策略：）   hash   轮询   指定  3种

### 数据拉取过程：

### 拉取或者推送：





# 生产者流程：

### 数据生产流程和api：

### 数据磁盘位置和数据结构：

### ack：

* retires次数表示什么
* 0，1，all   

### 启用幂等producer：

[关于Kafka幂等producer的讨论](https://www.cnblogs.com/huxi2b/p/7717775.html)

> Kafka 0.11.0.0版本正式支持精确一次处理语义(exactly once semantics，下称EOS)。Kafka的EOS主要体现在3个方面：
>
> - 幂等producer：保证发送单个分区的消息只会发送一次，不会出现重复消息
> - 事务(transaction)：保证原子性地写入到多个分区，即写入到多个分区的消息要么全部成功，要么全部回滚
> - 流处理EOS：流处理本质上可看成是“读取-处理-写入”的管道。此EOS保证整个过程的操作是原子性。注意，这只适用于Kafka Streams
>
> 上面3种EOS语义有着不同的应用范围，幂等producr只能保证**单分区**上无重复消息；事务可以保证**多分区**写入消息的完整性；而流处理EOS保证的是**端到端**(E2E)消息处理的EOS。用户在使用过程中需要根据自己的需求选择不同的EOS。以下是启用方法：
>
> - 启用幂等producer：在producer程序中设置属性enable.idempotence=true，但不要设置transactional.id。注意是不要设置，而不是设置成空字符串或"null"
> - 启用事务支持：在producer程序中设置属性transcational.id为一个指定字符串(你可以认为这是你的事务名称，故最好起个有意义的名字)，同时设置enable.idempotence=true
> - 启用流处理EOS：在Kafka Streams程序中设置processing.guarantee=exactly_once

### 数据持久化：

### 数据落地磁盘条件：时间和大小

### 同步发送和异步发送：

## 消费者流程：

### group_id消费者组    分区分配

> offsets.topic.replication.factor要大于1才行，否则一挂，偏移量维护就失败了。

### api: 1.指定分区，位置消费2.指定消费模式

### 偏移量维护：手动，自动

### 偏移量存储位置：

### linux命令：  

*  主题备份数
*  分区数 的修改     
*  主题的删除和假删除（修改参数）  

>  需要把delete.topic.enable 参数设置为true才是实际删除
>
> 是controller中的一个参数

*  查看主题信息    查看某一个主题的偏移量

```
bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server 127.0.0.1:9292 --list   group列表
bin/kafka-topics.sh --zookeeper 127.0.0.1:2181 --topic lx_test_topic --describe
bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server 127.0.0.1:9292 --group lx_test --describe  指定group


```



### reblance：









## 集群维护：

### kafka的启动日志内容以及各个日志的含义











## zk

### zk选举

### zk节点

》Znode有两种类型，短暂的（ephemeral)和持久的（persistent)
》Znode的类型在创建时确定并且之后不能再修改
》短暂znode的客户端会话结束时，zookeeper会将该短暂znode删除，短暂znode不可以有子节点
》持久znode不依赖于客户端会话，只有当客户端明确要删除该持久znode

》节点可以写内容，但是临时节点不能存储数据

## zk和kafka的关系

### [数据层面](https://www.jianshu.com/p/a036405f989c)

> - Broker注册  Broker服务器列表记录  为临时节点，当宕机会删除宕机节点
> - Topic注册  同一个Topic的消息会被分成多个分区并将其分布在多个Broker上，这些分区信息及与Broker的对应关系也都是由Zookeeper在维护，由专门的节点来记录
> - 生产者负载均衡  由于每个Broker启动时，都会完成Broker注册过程，生产者会通过该节点的变化来动态地感知到Broker服务器列表的变更，这样就可以实现动态的负载均衡机制。
> - 消费者负载均衡  每个消费者分组包含若干消费者，每条消息都只会发送给分组中的一个 消费者，不同的消费者分组消费自己特定的Topic下面的消息，
> - 分区与消费者的关系 对于每个消费者组 (Consumer Group)，Kafka都会为其分配一个全局唯一的Group ID，Group 内部的所有消费者共享该 ID。
> - 对消费者，broker进行注册监听，发生变化触发负载均衡
> - [cortroller选举](https://www.cnblogs.com/smartloli/p/9826923.html)
>
> 在Kafka集群中，每个Broker在启动时会实例化一个KafkaController类。该类会执行一系列业务逻辑，选举出主题分区的Leader节点，步骤如下：
>
> - 第一个启动的代理节点，会在Zookeeper系统里面创建一个临时节点/controller，并写入该节点的注册信息，使该节点成为控制器；
> - 其他的代理节点陆续启动时，也会尝试在Zookeeper系统中创建/controller节点，但是由于/controller节点已经存在，所以会抛出“创建/controller节点失败异常”的信息。创建失败的代理节点会根据返回的结果，判断出在Kafka集群中已经有一个控制器被成功创建了，所以放弃创建/controller节点，这样就确保了Kafka集群控制器的唯一性；
> - 其他的代理节点，会在控制器上注册相应的监听器，各个监听器负责监听各自代理节点的状态变化。当监听到节点状态发生变化时，会触发相应的监听函数进行处理。

![img](https://upload-images.jianshu.io/upload_images/3149801-0d2ed2bd8b7bec25.png?imageMogr2/auto-orient/)

## 消息传递保障

> At most once：最多一次，消息可能会丢失，但不会重复      消息读取=>offset保存=>消息处理
>
> At least once：最少一次，消息不会丢失，可能 会重复     消息读取=>消息处理成功=>offset保存
>
> Exactly once：只且消费一次，消息不丢失不重复，  消息读取=>offset保存=>消息处理  整个过程具有事务性

#### 保证exactly once 的方法：

* 生产者设置幂等属性：

  >配置项：把enable.idempotence 为true，此时会默认把acks设置为all
  >
  >幂等实现原则：每个生产者维护一个<Topic, Partition>pid，同时broker维护一个bid，放入zk的/brokers下的seq
  >
  >当req_seq==b_seq+1  broker接受消息
  >
  >当req_seq<b_seq+1   证明现在发的消息已保存，不接受
  >
  >当req_seq>b_seq+1   漏消费，一些数据没写入，顺序错乱

* 消费者端恰好一次：

  >1.下游数据保证幂等性，即数据处理重复数据不会导致多条记录（采用at least once方式）
  >
  >或
  >
  >2.把offset提交和业务处理绑定为一个事务  （手动提交+事务）

* 事务性伪代码

  > void  kakfa_in_tranction(){
  >   // 1.kafa的操作：读取消息或者生产消息
  >  kafkaOperation（）；
  >    // 2.db操作
  >   dbOperation()
  > }

  >```
  >void  kakfa_in_tranction(){
  >  // 1.kafa的操作：读取消息或者生产消息
  > kafkaOperation（）；
  >   // 2.db操作
  >  dbOperation()
  >}
  >```

* api

```java
  //producer提供的事务方法
   /**
     * 初始化事务。需要注意的有：
     * 1、前提
     * 需要保证transation.id属性被配置。
     * 2、这个方法执行逻辑是：
     *   （1）Ensures any transactions initiated by previous instances of the producer with the same
     *      transactional.id are completed. If the previous instance had failed with a transaction in
     *      progress, it will be aborted. If the last transaction had begun completion,
     *      but not yet finished, this method awaits its completion.
     *    （2）Gets the internal producer id and epoch, used in all future transactional
     *      messages issued by the producer.
     *
     */
    public void initTransactions();

    /**
     * 开启事务
     */
    public void beginTransaction() throws ProducerFencedException ;

    /**
     * 为消费者提供的在事务内提交偏移量的操作
     */
    public void sendOffsetsToTransaction(Map<TopicPartition, OffsetAndMetadata> offsets,
                                         String consumerGroupId) throws ProducerFencedException ;

    /**
     * 提交事务
     */
    public void commitTransaction() throws ProducerFencedException;

    /**
     * 放弃事务，类似回滚事务的操作
     */
    public void abortTransaction() throws ProducerFencedException ;
```



kafka启动流程：
1.读取外部配置信息和默认配置并加载
2.启动内部状态监控
3.定义broker状态为starting
4.启动kafka定时器，利用参数zk信息启动zk客户端建立联系
5.启动文件管理器，读取zk配置，把所有及记录写入文本文件，防止文件丢失。
6.下一步，获取brokerId
7.启动一个NIO socket服务
8.启动复制管理器：启动ISR超时处理线程
9.启动kafka控制器：注册session过期监听器，同时启动控制器leader选举
10.启动协调器
11.权限认证
12.开启线程，开始处理请求
13.开启配置监听，主要是监听zk节点数据变化，然后广播到所有机器
14.开启健康检查：目前只是把broker节点注册到zk上，注册成功就是活的，否则就是dead
15.注册启动数据信息
16.启动成功



1.kafka整个的流程图和一些算法，从生产到消费    =》思维导图画出来
/////kafka启动日志
2.kafka 在zk存储了那些内容，怎么起作用
3.zk存储结构，节点的特性和实验
4.常见配置，算法启动时间等
5.监控
6.kafka存储的实际位置  ，并和其它内容相对应
7.kafka的启动日志内容以及各个日志的含义
8.日志保存时间总结： https://www.cnblogs.com/angellst/p/9368493.html
