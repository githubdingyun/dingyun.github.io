---
layout: post
title:  ""
date:   2018-02-8 13:14:24
categories: hadoop
tags: MR hadoop
excerpt:
mathjax: true
author: dingyun
---

* content
{:toc}

## MapReduce简介

>MapReduce是一种分布式计算模型，是Google提出的，主要用于搜索领域，解决海量数据的计算问题。
>MR有两个阶段组成：Map和Reduce，用户只需实现map()和reduce()两个函数，即可实现分布式计算。
>MapReduce执行流程
![MapReduce简介](/image/MapReduce原理.png)




## MapReduce原理
![MapReduce原理](/image/MapReduce执行流程.png)




## MapReduce的执行步骤：

### 1、Map任务处理

* 1.1 读取HDFS中的文件。每一行解析成一个<k,v>。每一个键值对调用一次map函数。                <0,hello you>   <10,hello me>

* 1.2 覆盖map()，接收1.1产生的<k,v>，进行处理，转换为新的<k,v>输出。 <hello,1> <you,1> <hello,1> <me,1>

* 1.3 对1.2输出的<k,v>进行分区。默认分为一个区。详见《Partitioner》

* 1.4 对不同分区中的数据进行排序（按照k）、分组。分组指的是相同key的value放到一个集合中。　排序后：<hello,1> <hello,1> <me,1> <you,1>  分组后：<hello,{1,1}><me,{1}><you,{1}>

* 1.5 （可选）对分组后的数据进行归约。详见《Combiner》

### 2、Reduce任务处理

* 2.1 多个map任务的输出，按照不同的分区，通过网络copy到不同的reduce节点上。（shuffle）详见《shuffle过程分析》

* 　　2.2 对多个map的输出进行合并、排序。覆盖reduce函数，接收的是分组后的数据，实现自己的业务逻辑，　<hello,2> <me,1> <you,1>

　　　　处理后，产生新的<k,v>输出。

* 　　2.3 对reduce输出的<k,v>写到HDFS中。
## wordcount 结果
```java
package org.dingyun.hadoop;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.junit.Test;

import java.io.IOException;

public class MRWordCount {
    public static class WordCountMAP extends Mapper<LongWritable, Text, Text, IntWritable> {

        @Override
        protected void map(LongWritable key, Text value, Mapper<LongWritable, Text, Text, IntWritable>.Context context) throws IOException, InterruptedException {
            IntWritable outputValue = new IntWritable(1);
            Text outputKey = new Text();
            String[] infos;
            infos = value.toString().split("[\\s\\.,\"]");
            for (String word : infos
                    ) {
                outputKey.set(word);
                context.write(outputKey, outputValue);
            }

        }
    }


    //定义reduce类，用来把map解析的结果，根据key值进行聚合计算
    public static class WordCountReduce extends Reducer<Text, IntWritable, Text, IntWritable> {
        private int sum = 0;
        private IntWritable outputKey = new IntWritable(0);

        //重写reduce方法把相同单词的词频数累计计算出结果值：
        @Override
        protected void reduce(Text key, Iterable<IntWritable> values,
                              Reducer<Text, IntWritable, Text, IntWritable>.Context context) throws IOException, InterruptedException {
            sum = 0;
            for (IntWritable value : values) {
                sum += 1;
            }
            outputKey.set(sum);
            context.write(key, outputKey);
        }
    }
    //创建job，组装执行过程顺序配置
    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        Configuration configuration = new Configuration();
        Job job = Job.getInstance(configuration);
        job.setJarByClass(MRWordCount.class);
        job.setJobName("wordCount");
        //设置map类和reducer类
        job.setMapperClass(WordCountMAP.class);
        job.setReducerClass(WordCountReduce.class);
        //设置recuer输出的数据类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        //设置输入文件和输出文件
        FileInputFormat.addInputPath(job, new Path("/README.txt"));
        FileOutputFormat.setOutputPath(job, new Path("/wc32output"));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }




}

```
## 解析
### map 过程
### reduce 过程
### 大数据常用变量 Writeable
![Writable子类型](/image/Writable.jpg)
### FileOutputFormat
### FileOutputFormat
### Configration
### Job
###
## 自我理解:
