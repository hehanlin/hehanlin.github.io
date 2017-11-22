title: 开发用ubuntu初始化
author: hanlin
tags: []
categories: []
date: 2016-01-23 01:21:00
---
### 1. 更换国内源
<!--more-->
```
deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
##测试版源
deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
# 源码
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
##测试版源
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
# Canonical 合作伙伴和附加
deb http://archive.canonical.com/ubuntu/ xenial partner
deb http://extras.ubuntu.com/ubuntu/ xenial main
```

### 2. samba磁盘映射
备份Samba的配置文件：sudo cp  /etc/samba/smb.conf  /etc/samba/smb.conf.bak
```
#我在/etc/samba/smb.conf文件的末尾之添加如下字段：
[hehanlin]
comment = hehanlin
path = yourpath
writable = yes
```
然后执行 sudo smbpasswd  -a   hehanlin

####对待iptables

```
普通青年：直接在命令行敲…
sudo service  iptables stop。
文艺青年：依次在命令行敲…
sudo iptables -I RH-Firewall-1-INPUT 5 -m state --state NEW -m tcp -p tcp --dport 139 -j ACCEPT
sudo iptables -I RH-Firewall-1-INPUT 5 -m state --state NEW -m tcp -p tcp --dport 445 -j ACCEPT
sudo iptables -I RH-Firewall-1-INPUT 5 -p udp -m udp --dport 137 -j ACCEPT
sudo iptables -I RH-Firewall-1-INPUT 5 -p udp -m udp --dport 138-j ACCEPT
sudo iptables-save
sudo service iptables  restart
```
#### 同样，在对在selinux的问题上：

```
普通青年：直接在命令行敲…
sudo setenforce 0
sudo vi /etc/selinux/config
将SELINUX=enforcing改为SELINUX=disabled为开机重启后不再执行setenfore节约光阴。
文艺青年：依次在命令行敲…
sudo setsebool -Psamba_enable_home_dirs on
sudo setsebool -Psamba_export_all_rw on
完事儿之后再：getsebool  -a  | grep  samba一把，你懂得…
```

### 3. 安装需要的一切环境
```
sudo apt-get install python python-mysql nginx mysql-server php
```

### 4. pip源
```
#linux下运行命令sudo vi ~/.pip/pip.conf然后写入如下内容并保存
[global]
trusted-host = mirrors.aliyun.com
index-url = http://mirrors.aliyun.com/pypi/simple
```