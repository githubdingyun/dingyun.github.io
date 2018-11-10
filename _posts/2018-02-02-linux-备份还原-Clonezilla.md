---
layout: post
title:  '利用Clonezilla备份还原Linux系统'
date:   2018-02-05 15:14:54
categories: linux
tags:  Clonezilla linux
mathjax: true
author: dingyun
---
* content
{:toc}

## 制作U盘启动盘
* 工具UltraISO
* Clonezilla.iso

## 在虚拟机上挂载硬盘,f2进入boot修改启动
* 虚拟机编辑
* 添加硬盘   一直默认
* f2进入boot,修改第二个硬盘进去 再生龙


## 把一个linux系统克隆为镜像
* 一路默认
* 选择中文
* ssh协议,挂载到我们想要的位置
* 高级选项
* dd制作镜像



## 把一个linux系统镜像还原出来
* 一路默认
* ssh选择文件路径是我们(上面保存)的路径
* 一路默认
* 还原成功


## 虚拟机删除以后,主机磁盘空间没有还原.
### 这个是个问题
* 设置镜像
* 一开始就把虚拟机硬盘大小变小,反正可以扩容
* 使用工具  ~  我觉得一开始就别给他那么大 40就足够了
* df -h查看当前文件状态


## 详细教程  [利用Clonezilla备份还原Linux系统](http://www.knowsky.com/1054087.html)
