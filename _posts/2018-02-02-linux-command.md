---
layout: post
title:  "2018-02-02-linux-command"
date:   2018-02-02 15:14:54
categories: linux
tags:  hadoop linux
mathjax: true
author: dingyun
---
* content
{:toc}

## linux命令格式:
* [软件名] [命令参数] 操作参数[arg,文件名什么的]
### 常用命令:
##### service [服务名] [命令]
##### chkconfig [服务名] [off/on]
    * network
    * mysql
##### htop
基础: linux
连接工具 : secure crt
配置文件: hosts:   
用来让本机主机名来对应相应的主机地址   hosts=本地dns  dns解析就是如此
		:/etc/profile     环境变量  shell的变量
		: /etc/sysconfig/network-scripts  下的ifcfg-eth0  来配置网卡,ip属性等信息



Linux历史:
自用:   unbturn  redhat   
centos7源于redhat
debian   运维
kt    黑客
auto   linux 极致使用者
linux的表示:     shell   人机交互  脚本  
├──linux的架构
└── hardware  ->  linux kernel  -> gnusheels windowsx hnome ->datapross java ide wordproess
├──
└──  1.bios
└──  2.init.  文件位置: /etc/initab
└──  3.
├──常见指令:所有指令实际上是一个程序,命名大多为缩写



├──网络使用  
└── route  查看当前网关  getaway
└── 防火墙:        service iptables status stop start
       永久关闭  chkconfig iptables off on
└── 关机  sync  把内存数据保存到磁盘上然后关机 shutdown reboot halt
			所以: 不管重启还是关闭系统  先sync把数据写到内存里
└── alias a= ‘ll  –a ’ 给一个命令起一个别名   unalias   删除别名
└── source 重新加载资源文件  一般是 /etc/profile
└── 默认644file权限755目录权限   
		└── 用户所有者  o  rwx    chmod 777 [file]
		└── group       g   rwx    chmod g+x
		└── other        u  rwx    cjmod 0-x

└── 特殊属性
		└── lsattr   列出文件特殊属性
		└── chattr   改变文件属性
rpm -ivh *.rpm
├──查找命令:
		└── 名字:    $ find / -name dir1
/var/tmp/dir1
		└── 软连接:  find / -l
					得到了所有的软连接


├──用户/etc/passwd
 		└──  



Sudoers必须要有某一个用户,这个用户才能够使用sudo来执行一些操作,而不是说sudo是使用了管理员权限.
文件位置:/etc/sudoers     su切换用户  sudo do something  是使用su做一些事情





├──vim


├──文件上传
└── Lrzsz
└── xftp6
├──站内通信:
		└── nc  telnet
├──运维软件:
└── htop  top  监控cpu          w
监控文件
└── pv
pv命令简介
可以使用pv命令度量执行命令的具体信息：时间，进度等。可以是管道的过程进度对用户透明，可以监控长时间操作的执行情况。
在迁移新nas的时候遇到这个问题，无法监控上百G数据的迁移。幸好找到pv工具。
网络管理:
Route  查看网关


:

Cron表达式
El表达式
