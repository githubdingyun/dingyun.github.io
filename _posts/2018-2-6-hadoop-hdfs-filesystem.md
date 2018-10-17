---
layout: post
title:  "hadoop-hdfs-filesystem"
date:   2018-02-06 15:14:54
categories: hadoop
tags: hdfs io
excerpt: 当年创建 jekyll 时默认的一篇文章，没什么意义，我也一直没删除，留个纪念吧。
mathjax: true
author: dingyun
---

* content
{:toc}

## 我们一起来看看如何使用java来操作hdfs吧
### 官方api地址(2.7.6)
[hadoop官方api地址2.7.6](https://hadoop.apache.org/docs/r2.7.6)  **因为我使用的是hadoop2.7.7,发现没有,那就找它上一个版本**
找到导航栏 Reference(参考),点击api来参看api文档
![FileSystem](/image/FileSystem.jpg)
### 如何查看api
1. 看接口,继承了谁,又有什么子类
2. 看构造方法,静态方法和方法工厂
3. 看如何使用,完成我们想要的操作

### 准备工作
pom文件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.dingyun</groupId>
    <artifactId>DriverSelect</artifactId>
    <packaging>pom</packaging>
    <version>1.0-SNAPSHOT</version>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>8</source>
                    <target>8</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <configuration>
                    <descriptors>
                        <descriptor>assembly.xml</descriptor><!-- 指定assembly配置文件路径 -->
                    </descriptors>
                </configuration>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>

    </build>


    <repositories>
        <repository>
            <id>apache</id>
            <url>http://maven.apache.org</url>
        </repository>
    </repositories>

    <dependencies>

        <!-- https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-client -->
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client</artifactId>
            <version>2.7.7</version>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>compile</scope>
        </dependency>

    </dependencies>



</project>

```
#### Configuration官网上说回默认找两个文件:
![hdfs-conf.jpg](/image/hdfs-conf.jpg)
##### 配置如下
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://master1:9000</value>
    </property>
    <!--下面配置可写可不写-->
    <!--<property>-->
    <!--<name>io.file.buffer.size</name>-->
    <!--<value>131072</value>-->
    <!--</property>-->
    <!--<property>-->
    <!--<name>hadoop.tmp.dir</name>-->
    <!--<value>file:/usr/temp</value>-->
    <!--</property>-->
    <!--<property>-->
    <!--最大化访问hdfs权限,方便学习,在原虚拟机上已有配置,不必写入-->
    <!--<name>hadoop.proxyuser.root.hosts</name>-->
    <!--<value>*</value>-->
    <!--</property>-->
    <!--<property>-->
    <!--<name>hadoop.proxyuser.root.groups</name>-->
    <!--<value>*</value>-->
    <!--</property>-->

</configuration>


```
### 一个filesystem类对hdfs文件存储的基本实现
```java
package org.dingyun.hadoop;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.*;
import org.junit.Test;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class HdfsTest1 {

    @Test
    public void test1() throws IOException {
        FileSystem fileSystem = FileSystem.get(new Configuration());
        FSDataOutputStream fsDataOutputStream = fileSystem.create(new Path("/writefromjava.txt"));
        fsDataOutputStream.writeUTF("我是小埋我是仙女\n");
        fsDataOutputStream.writeUTF("我是小埋我是仙女\n");
        fsDataOutputStream.writeUTF("我是小埋我是仙女\n");
        fsDataOutputStream.writeUTF("我是小埋我是仙女\n");
        fsDataOutputStream.writeUTF("我是小埋我是仙女\n");

        fsDataOutputStream.flush();
        fsDataOutputStream.close();
        System.out.println("书写成功");
    }

    /**
     * 判断一个目录是否存在,
     *
     * @throws IOException
     */
    @Test
    public void test2() throws IOException {
        FileSystem fileSystem = FileSystem.get(new Configuration());
        if (fileSystem.exists(new Path("/LD"))) {
            System.out.println("文件已经LD已存在");
        } else {
            System.out.print("文件已经LD不存在,将创建");
            fileSystem.mkdirs(new Path("/LD"));
        }
        if (fileSystem.isDirectory(new Path("/LD")))
            System.out.println("这是一个目录");
        else {
            System.out.println("这是一个文件");
        }
    }

    @Test
    public void test3() throws IOException {
        FileSystem fileSystem = FileSystem.get(new Configuration());
        f(fileSystem, new Path("/"));
    }

    /**
     * 文件复制实验
     *
     * @throws IOException
     */
    @Test
    public void test4() throws IOException {
        FileSystem fileSystem = FileSystem.get(new Configuration());
        FileInputStream fileInputStream = new FileInputStream("C:\\Users\\dingyun\\Desktop\\add.txt");
        FSDataOutputStream out = fileSystem.create(new Path("/bbb.txt"));

        byte[] buffer = new byte[1024];
        int b = 0;
        while ((b = fileInputStream.read(buffer)) != -1) {
            out.write(buffer, 0, b);
        }

    }

    void f(FileSystem fileSystem, Path path) throws IOException {
        FileStatus[] fileStatuses = fileSystem.listStatus(path);
        for (FileStatus fileStatus : fileStatuses
                ) {
            if (fileStatus.isDirectory()) {
                System.out.println("这是dir:" + fileStatus.getPath());
                f(fileSystem, fileStatus.getPath());

            } else {
                System.out.println("这是file:" + fileStatus.getPath());
            }
        }


    }


    /**
     * 读取hdfs文件内容
     *
     * @throws IOException
     */
    @Test
    public void test5() throws IOException {
        FileSystem fileSystem = FileSystem.get(new Configuration());
        FSDataInputStream in = fileSystem.open(new Path("/bbb.txt"));

        byte[] buffer = new byte[1024];
        while ((in.read(buffer, 0, 1024)) != -1) {
            String s = new String(buffer, "UTF-8");
            System.out.print(s);
        }
        in.close();

    }

    /**
     * 向文件后追加内容
     *
     * @throws IOException
     */
    @Test
    public void test6() throws IOException {
        FileSystem fileSystem = FileSystem.get(new Configuration());
        FSDataOutputStream append = fileSystem.append(new Path("/bbb.txt"));
        append.writeUTF("我叫小埋我是仙女");
        append.flush();
        append.close();
    }



}


```
### hdfs文件已经能存取自如,那么都知道大数据不适合处理小文件,下篇将讲诉解决方案