---
layout: post
title:  "HDFS's sequenceFile"
date:   2018-2-7 15:14:54
categories: hadoop
tags: hadoop hdfs
excerpt: Hadoop 处理小文件的方法:sequenceFile
mathjax: true
author: dingyun
---

* content
{:toc}


## 简介：
* SequenceFile 是一个由二进制序列化过的`key/value`的字节流组成的文本存储文件，它可以在`map/reduce`过程中的`input/output`
的format时被使用。在`map/reduce`过程中，map处理文件的临时输出就是使用SequenceFile处理过的。
* SequenceFile分别提供了读、写、排序的操作类。
* SequenceFile的操作中有三种处理方式：
    1. 不压缩数据直接存储。 //enum.NONE
    2. 压缩value值不压缩key值存储的存储方式。//enum.RECORD
    3. key/value值都压缩的方式存储。//enum.BLOCK

SequenceFile提供了若干Writer的构造静态获取。
```java
SequenceFile.createWriter()；
```

* SequenceFile.Reader使用了桥接模式，可以读取SequenceFile.Writer中的任何方式的压缩数据。

三种不同的压缩方式是共用一个数据头，流方式的读取会先读取头字节去判断是哪种方式的压缩，然后根据压缩方式去解压缩并反序列化字节流数据，得到可识别的数据。

### 流的存储头字节格式：
#### Header：
* 字节头”SEQ”, 后跟一个字节表示版本”SEQ4”,”SEQ6”.//这里有点忘了 不记得是怎么处理的了，回头补上做详细解释
* keyClass name
* valueClass name
* compression boolean型的存储标示压缩值是否转变为keys/values值了
* blockcompression boolean型的存储标示是否全压缩的方式转变为keys/values值了
* compressor 压缩处理的类型，比如我用Gzip压缩的Hadoop提供的是GzipCodec什么的..
* 元数据 这个大家可看可不看的

>所有的String类型的写操作被封装为Hadoop的IO API，Text类型writeString()搞定。

### 未压缩的和只压缩values值的方式的字节流头部是类似的：
* Header
* RecordLength记录长度
* key Length key值长度
* key 值
* 是否压缩标志 boolean
* values


### sequenceFile 文件存储有三种方式：
可以通过在程序调用 enum CompressionType { NONE , RECORD , BLOCK } 指定，或通过配置文件io.seqfile.compression.type 指定，这三种存储方式如下图：
![sequencefile.png](/image/sequencefile.png)

> 对于Record 压缩这种存储方式，RecordLen 表示的是key 和value 的占用的byte 之和，Record 压缩方式中 key 是不压缩 ，
> value 是压缩后的值，在record 和非压缩这两种方式，都会隔几条记录插入一个特殊的标号来作为一个同步点Sync ，
> 作用是当指定读取的位置不是记录首部的时候，会读取一个同步点的记录，不至于读取数据的reader “迷失”。
> 每两千个byte 就插入一个同步点，这个同步点占16 byte ，包括同步点标示符：4byte ，一个同步点的开销是20byte 。

> 对于block 这种压缩方式， key 和value 都是压缩的 ，通过设置io.seqfile.compress.blocksize 这个参数决定每一个记录块压缩的数据量，
> 默认大小是1000000 byte ，这个值具体指的是key 和value 缓存所占的空间，每要往文件写一条key/value 时，都是将key 和value 的长度以及key
> 和value 的值缓存在keyLenBuffer keyBuffer valLenBuffer valBuffer 这四个
> DataOutputStream 中，当keyBuffer.getLength() + valBuffer.getLength() 大于或等于io.seqfile.compress.blocksize 时
> ，将这些数据当做一个block 写入sequence 文件，如上图所示 每个block 之间都会插入一个同步点。

### 代码演示:
```java
package org.dingyun.hadoop;

import org.apache.commons.io.FileUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileUtil;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.compress.BZip2Codec;
import org.apache.hadoop.io.compress.GzipCodec;
import org.junit.Test;

import java.io.File;
import java.io.IOException;
import java.util.Collection;

/**
 * SequenceFile是大数据对小文件的一种解决方案
 * 减轻了master的压力,大文件适合大数据进行处理
 */
public class SequenceFileTest {
    @Test
    public void test1() throws IOException {
        Configuration configuration = new Configuration();

        SequenceFile.Writer.Option option1 = SequenceFile.Writer.file(new Path("/sequencefile"));
        SequenceFile.Writer.Option option2 = SequenceFile.Writer.keyClass(Text.class);
        SequenceFile.Writer.Option option3 = SequenceFile.Writer.valueClass(IntWritable.class);

        //压缩文件
        SequenceFile.Writer.Option option4 = SequenceFile.Writer.
                compression(SequenceFile.CompressionType.RECORD, new BZip2Codec());

        SequenceFile.Writer writer = SequenceFile.createWriter(configuration, option1, option2, option3, option4);
        for (int i = 0; i < 100; i++) {
            writer.append(new Text("it's key:  "), new IntWritable(i));
        }
        writer.hflush();
        writer.close();
    }

    @Test
    public void test2() throws IOException {
        Configuration configuration = new Configuration();
        SequenceFile.Reader.Option option1 = SequenceFile.Reader.file(new Path("/sequencefile"));
        SequenceFile.Reader reader = new SequenceFile.Reader(configuration, option1);
        Text text = new Text();
        IntWritable intWritable = new IntWritable();
        while (reader.next(text, intWritable)) {
            System.out.println(text + intWritable.toString());
        }
        reader.close();


    }

    /**
     * 解决小文件的一种解决方法:   使用SequenceFile
     * 把一个文件夹文件给变成key value 存储到    SequenceFile容器中
     */
    @Test
    public void test3() throws IOException {

        Collection<File> files =
                FileUtils.listFiles(new File("D:\\javaTools\\IdeaProjects\\DriverSelect\\src\\main\\java\\com\\student24")
                        , null, true);
        Configuration configuration = new Configuration();

        SequenceFile.Writer.Option option1 = SequenceFile.Writer.file(new Path("/LDD"));
        SequenceFile.Writer.Option option2 = SequenceFile.Writer.keyClass(Text.class);
        SequenceFile.Writer.Option option3 = SequenceFile.Writer.valueClass(BytesWritable.class);
        SequenceFile.Writer writer = SequenceFile.createWriter(configuration, option1, option2, option3);

        for (File file : files
                ) {
            String key = file.getAbsolutePath();
            byte[] bytes = FileUtils.readFileToByteArray(file);
            writer.append(new Text(key), new BytesWritable(bytes));
        }
        writer.hflush();
        writer.close();


    }

    /**
     * 读取SequenceFile文件
     */
    @Test
    public void test4() throws IOException {

        Configuration configuration = new Configuration();
        SequenceFile.Reader.Option option1 = SequenceFile.Reader.file(new Path("/LDD"));
        SequenceFile.Reader reader = new SequenceFile.Reader(configuration, option1);
        Text text = new Text();
        BytesWritable bytesWritable = new BytesWritable();
        while (reader.next(text,bytesWritable)){
            System.out.println(text+":\n\n\n"+(new String(bytesWritable.getBytes(),"utf-8")));
        }


    }


}

```
##### 下一节则是mapreduce经典程序 `wordcount` 的演示

