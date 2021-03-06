---
layout: post
title:  "avro在大数据中的使用"
date:   2018-02-25 13:14:24
categories: hadoop
tags: MR hadoop avro
excerpt:
mathjax: true
author: dingyun
---

* content
{:toc}


# 什么是avro
## 优点
### 多语言支持对接
>Avro是apache Avro的简称，其实是一个独立于编程语言的数据序列化系统，设计用于支持大批量数据交换的应用。
干过大数据都知道，hadoop自身提供了一个轻量级的序列化的系统Writable.虽然这个Writable相比Java提供的系
列化Serializable更加轻便简洁好用.

>**但是Writable类型也有很多不足，比如缺乏语言的可移植性，不能让
Writable类型处理的数据在java，C, C++,python等多种语言之前相互转换.**而Avro正好解决了这个问题。

>当然市面上序列化系统也不止Avro一家，比如Apache旗下还有一个Thrift也是序列化系统，
Google也自己开发一个Protocol Buffer系统。但是相比用的多的，好用的还是Avro.它的主要特点有：

>**支持二进制序列化方式，可以便捷，快速地处理大量数据；动态语言友好，Avro提供的机制使动态语言可以方便地处理Avro数据。**

### 关于Avro:数据序列化/反序列化(data serialization/deserialization)
>Avro支持两种序列化编码方式：二进制编码和JSON编码。使用二进制编码会高效序列化，并且序列化后得到的结果会比较小；
而JSON一般用于调试系统或是基于WEB的应用。对Avro数据序列化/反序列化时都需要对模式以深度优先(Depth-First)，从左到右
(Left-to-Right)的遍历顺序来执行。

>Avro依赖模式(Schema)来实现数据结构定义。可以把模式理解为Java的类，它定义每个实例的结构，可以包含哪些属性。
可以根据类来产生任意多个实例对象。对实例序列化操作时必须需要知道它的基本结构，也就需要参考类的信息。
这里，根据模式产生的Avro对象类似于类的实例对象。每次序列化/反序列化时都需要知道模式的具体结构。
所以，在Avro可用的一些场景下，如文件存储或是网络通信，都需要模式与数据同时存在。Avro数据以模式来读和写(文件或是网络)，
并且写入的数据都不需要加入其它标识，这样序列化时速度快且结果内容少。由于程序可以直接根据模式来处理数据，
所以Avro更适合于脚本语言的发挥。


## 大数据使用它的原因
* 支持多语言对接
* 更快的序列化,并且速度快     avro>Writable>Serializable
* 另外Avro数据文件支持压缩，并且是可切分的（对于MapReduce的输入格式至关重要）,同时我们大数据常用的数据处理框架，
 比如Pig,Hive,Crunch,Spark等都能读写Avro文件。
* 更适合脚本文件
* 好用,可以使用插件自动生成序列化好的modle
## 使用  ---   ---[官方文档](http://avro.apache.org/docs/1.8.2/gettingstartedjava.html)
### 入门
## 详细观看官方文档
### Defining a schema     从它生成java  model  (被avro序列化好的)

```json
{"namespace": "example.avro",
 "type": "record",
 "name": "User",
 "fields": [
     {"name": "name", "type": "string"},
     {"name": "favorite_number",  "type": ["int", "null"]},
     {"name": "favorite_color", "type": ["string", "null"]}
 ]
}
```
>这里的数据类型可参看官网   [数据格式参看  http://avro.apache.org/docs/1.8.2/](http://avro.apache.org/docs/1.8.2/spec.html#schema_record)

>record是像数据库一样的包含多种类型的记录类型,在反序列化是它的值可直接被取出,当为"`string`"时,则反序列化只能得到一个字符串



### Creating Users and Serializing

```java
User user1 = new User();
user1.setName("Alyssa");
user1.setFavoriteNumber(256);
// Leave favorite color null

// Alternate constructor
User user2 = new User("Ben", 7, "red");

// Construct via builder
User user3 = User.newBuilder()
             .setName("Charlie")
             .setFavoriteColor("blue")
             .setFavoriteNumber(null)
             .build();

             DatumWriter<User> userDatumWriter = new SpecificDatumWriter<User>(User.class);
             DataFileWriter<User> dataFileWriter = new DataFileWriter<User>(userDatumWriter);
             dataFileWriter.create(user1.getSchema(), new File("users.avro"));
             dataFileWriter.append(user1);
             dataFileWriter.append(user2);
             dataFileWriter.append(user3);
             dataFileWriter.close();


```

### Deserializing

```java
// Deserialize users from disk
DatumReader<GenericRecord> datumReader = new GenericDatumReader<GenericRecord>(schema);
DataFileReader<GenericRecord> dataFileReader = new DataFileReader<GenericRecord>(file, datumReader);
GenericRecord user = null;
while (dataFileReader.hasNext()) {
// Reuse user object by passing it to next(). This saves us from
// allocating and garbage collecting many objects for files with
// many items.
user = dataFileReader.next(user);
System.out.println(user);
```

### Compiling and running the example code

```sh
$ mvn compile
$ mvn -q exec:java -Dexec.mainClass=example.GenericMain
```
## 在 hdfs mapreduce 上使用
### hdfs把文件写到hdfs上
>思路:   获取filesystem的outputstream ,使用dataFileWriter.create直接写入

```java
/**
    * 把文件写到hdfs上
    * @author dingyun
    * @throws IOException
    */
   @Test
   public void test2() throws IOException {
       Configuration configuration = new Configuration();
       configuration.set("fs.defaultFS", "hdfs://master1:9000");
       FileSystem fileSystem = FileSystem.newInstance(configuration);
       FSDataOutputStream outputStream = fileSystem.create(new Path("/student.avro"));


       DatumWriter<Student> userDatumWriter = new SpecificDatumWriter<Student>(Student.class);
       DataFileWriter<Student> dataFileWriter = new DataFileWriter<Student>(userDatumWriter);
       dataFileWriter.create(Student.getClassSchema(), outputStream);
       Student student1 = new Student("1", "李四", "33", "女");
       Student student2 = new Student("2", "张五", "22", "女");
       Student student3 = Student.newBuilder().setSage("18").setSid("3").setSname("lsg").setSsex("男").build();
       dataFileWriter.append(student1);
       dataFileWriter.append(student2);
       dataFileWriter.append(student3);
       dataFileWriter.flush();
       dataFileWriter.close();
       outputStream.flush();
       outputStream.close();

   }
```

### mr
> mr上默认有sequence容器:可以将小文件聚合成大文件处理,也可以自动解压压缩读取,但序列化方面没有avro效率高,语言支持化多
#### [**org.apache.avro.hadoop.file使用官方文档说明**](http://avro.apache.org/docs/1.8.2/api/java/index.html)
>A SortedKeyValueFile is an indexed Avro container file of KeyValue records sorted by key.
The SortedKeyValueFile is a directory with two files, named 'data' and 'index'.
The 'data' file is an ordinary Avro container file with records. Each record has exactly two fields,
'key' and 'value'. The keys are sorted lexicographically. The 'index' file is a small Avro container
 file mapping keys in the 'data' file to their byte positions. The index file is intended to fit in
  memory, so it should remain small. There is one entry in the index file for each data block in the
  Avro container file.
>
>SortedKeyValueFile is to Avro container file as MapFile is to SequenceFile.

翻译
>SortedKeyValueFile是按键排序的KeyValue记录的索引Avro容器文件。 SortedKeyValueFile是一个包含两个文件的目录，
名为“data”和“index”。 'data'文件是带有记录的普通Avro容器文件。每条记录都有两个字段，'key'和'value'。键按字典顺序排序。
 'index'文件是一个小的Avro容器文件，它将'data'文件中的键映射到它们的字节位置。索引文件旨在适合内存，因此它应该保持很小。
 索引文件中有一个条目用于Avro容器文件中的每个数据块。 SortedKeyValueFile是Avro容器文件，像SequenceFile一样的MapFile。


#### 比较sequence的使用

```java
/**
    * 向sequencefile文件里写东西,keyvalue 分别时text和int类型
    * 设置文件的压缩格式
    * 注意这种文件读取是会自动解压的
    * @throws IOException
    */
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
```
#### 使用record这种类型代替单一的keyvalue字段序列化(把文件字段改为bytes[])

```java
/**
   * 使用avro来序列化文件  文件保存为bytes字段  其他字段为  String String
   * 用于替代sequencefile 的keyvalue格式
   *
   * @throws IOException
   */
  @Test
  public void SmallFileMerag() throws IOException {
      File file = new File("D:\\Desktop_dingyun\\大数据svn同步wc\\onclass\\hadoop\\reindexfiles");
      File[] files = file.listFiles();

      DatumWriter<MergedFile> mergedFileDatumWriter = new SpecificDatumWriter<MergedFile>(MergedFile.class);
      DataFileWriter<MergedFile> mergedFileDataFileWriter = new DataFileWriter<MergedFile>(mergedFileDatumWriter);
      DataFileWriter<MergedFile> writer = mergedFileDataFileWriter.
              create(MergedFile.getClassSchema(), new File("mergedFile.avro"));
      MergedFile mergedFile = new MergedFile();
      for (File f :
              files) {
          mergedFile.setFilename(f.getPath());
          FileInputStream fileInputStream = new FileInputStream(f);
          byte[] bytes = new byte[(int) f.length()];
          fileInputStream.read(bytes);
          mergedFile.setMd5(DigestUtils.md5Hex(bytes));
          mergedFile.setContent(ByteBuffer.wrap(bytes));
          writer.append(mergedFile);
      }
      writer.flush();
      writer.close();


  }

```
#### 反序列化meragefile

```java
/**
     * merged file反序列化
     * 读取被avro序列化的record格式的字段
     */
    @Test
    public void readMeargTOFile() throws IOException {

        DatumReader<MergedFile> mergedFileDatumReader = new SpecificDatumReader<MergedFile>(MergedFile.class);
        DataFileReader<MergedFile> dataFileReader =
                new DataFileReader<MergedFile>(new File("mergedFile.avro"), mergedFileDatumReader);
        MergedFile mergedFile = null;
        while (dataFileReader.hasNext()) {
            // Reuse mergedFile object by passing it to next(). This saves us from
            // allocating and garbage collecting many objects for files with
            // many items.

            mergedFile = dataFileReader.next(mergedFile);
            System.out.println(mergedFile.toString());
        }


    }
```

### avro在hadoop上的使用(比单一的sequence文件好用,因为文本类型丰富)
#### map段 使用实例

```java
package com.zhiyou.bd23.avroMR;

import com.zhiyou.bd23.avroschema.MergedFile;
import org.apache.avro.mapred.AvroKey;
import org.apache.avro.mapreduce.AvroJob;
import org.apache.avro.mapreduce.AvroKeyInputFormat;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.JobID;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;

/**
 * @program: avrotest
 * @description: 使用avro来调用mr
 * @author: dingyun
 * @create: 2018-10-24 15:51
 */
public class AvroMRTest {

    public static class AvroMRTestMap extends Mapper<AvroKey<MergedFile>, NullWritable, Text, IntWritable> {
        private String text;
        private Text outputkey = new Text();
        private IntWritable outputvalue = new IntWritable(1);

        @Override
        protected void map(AvroKey<MergedFile> key, NullWritable value, Context context) throws IOException, InterruptedException {
            byte[] array = key.datum().getContent().array();
            text = new String(array, "utf-8");
            String[] strings = text.toString().split("[\\s\\,.]");
            for (String s : strings
                    ) {
                outputkey.set(s);
                context.write(outputkey, outputvalue);

            }


        }
    }

    public static class AvroMRTestRe extends Reducer<Text, IntWritable, Text, IntWritable> {
        private int sum;
        private IntWritable outputvalue = new IntWritable();
        private Text ouputkey = new Text();

        @Override
        protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
            sum = 0;
            for (IntWritable value : values
                    ) {
                sum++;
            }
            ouputkey.set(key);
            outputvalue.set(sum);
            context.write(ouputkey, outputvalue);

        }
    }


    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

        Configuration configuration = new Configuration();
        configuration.set("fs.defaultFS", "hdfs://master1:9000");
        Job job = Job.getInstance(configuration);

        job.setJarByClass(AvroMRTest.class);

//        FileInputFormat.addInputPath(job, new Path("/avro/mergedFile.avro"));
        AvroJob.setInputKeySchema(job, MergedFile.getClassSchema());
        job.setInputFormatClass(AvroKeyInputFormat.class);
        AvroKeyInputFormat.setInputPaths(job, new Path("/avro/mergedFile.avro"));
        job.setJobName("avro");
        job.setJobID(new JobID());


        //mapper阶段
        job.setMapperClass(AvroMRTestMap.class);

        //redurce阶段
        //1.设置类型
        job.setReducerClass(AvroMRTestRe.class);
        //设置输出
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        //3.文件输出阶段,如果有路径就删除路径!!!
        Path outputpath = new Path("/avro/MRTest");
        outputpath.getFileSystem(configuration).delete(outputpath, true);
        FileOutputFormat.setOutputPath(job, outputpath);


        //启动job
        System.exit(job.waitForCompletion(true) ? 0 : 1);


    }

}
```

#### Reducer输出格式为 avrokeyoutputformat<>

```java
package com.zhiyou.bd23.avroMR;

import com.zhiyou.bd23.avroschema.MergedFile;
import com.zhiyou.bd23.avroschema.Subject;
import org.apache.avro.mapred.AvroKey;
import org.apache.avro.mapreduce.AvroJob;
import org.apache.avro.mapreduce.AvroKeyInputFormat;
import org.apache.avro.mapreduce.AvroKeyOutputFormat;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.JobID;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;

/**
 * @program: avrotest
 * @description: 统计平均分, 输出为avro文件格式
 * @author: dingyun
 * @create: 2018-10-24 17:08
 */
public class AvroReduce {


    public static class AvroReduceMap extends Mapper<LongWritable, Text, Text, Text> {
        private Text ouyputkey = new Text();
        private Text outputvalue = new Text();

        @Override
        protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

            String[] split = value.toString().split("[\\s\\.,\"]");
            String[] forage = split[2].split("/");
            int sex = 2018 - Integer.valueOf(forage[0]);
            ouyputkey.set(split[5]);
            outputvalue.set(value.toString());
            context.write(ouyputkey, outputvalue);


        }
    }


    public static class AvroReduceRe extends Reducer<Text, Text, AvroKey<Subject>, NullWritable> {
        private double sum = 0;
        private int num = 0;
        private boolean flag;
        private Subject outputkey = new Subject();
        private NullWritable outputvalue = NullWritable.get();

        @Override
        protected void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {


            sum = 0;
            num = 0;
            for (Text value :
                    values) {
                String[] split = value.toString().split("[\\s\\.,\"]");
                sum += Double.valueOf(split[4]);
                num++;
            }
            outputkey.setAllScore(sum);
            sum /= num;
            outputkey.setCourse(key.toString());
            outputkey.setStudentNumber(num);
            outputkey.setTheAverageScore(sum);

            context.write(new AvroKey<Subject>(outputkey), outputvalue);
        }
    }


    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        Configuration configuration = new Configuration();
        configuration.set("fs.defaultFS", "hdfs://master1:9000");
        Job job = Job.getInstance(configuration);

        job.setJarByClass(AvroReduce.class);

        FileInputFormat.addInputPath(job, new Path("/sort2/stuMessage"));
        job.setJobName("avroreduce to avro");
        job.setJobID(new JobID());


        //mapper阶段
        job.setMapperClass(AvroReduceMap.class);

        //redurce阶段
        //1.设置类型
        job.setReducerClass(AvroReduceRe.class);
        //设置输出
        AvroJob.setOutputKeySchema(job, Subject.getClassSchema());

        job.setOutputKeyClass(Subject.class);
        job.setOutputValueClass(NullWritable.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(Text.class);
        //3.文件输出阶段,如果有路径就删除路径!!!
        job.setOutputFormatClass(AvroKeyOutputFormat.class);
        Path outputpath = new Path("/avro/reduceResult.avro");
        outputpath.getFileSystem(configuration).delete(outputpath, true);
        AvroKeyOutputFormat.setOutputPath(job, outputpath);


        //启动job
        System.exit(job.waitForCompletion(true) ? 0 : 1);

    }


}

```
