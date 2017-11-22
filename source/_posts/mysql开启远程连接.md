original: false
title: mysql开启远程连接
date: 2015-08-26 11:58:48
tags:
  - mysql
---
mysql默认是不能用客户端远程连接的，阿里云提供的help.docx里面做了设置说明，mysql密码默认存放在/alidata/account.log
<!--more-->
### 首先登录
```
mysql -u root -h localhost -p;
use mysql;
```
### 设置
将host设置为%表示任何ip都能连接mysql，当然您也可以将host指定为某个ip

```
update user set host='%' where user='root' and host='localhost';
flush privileges; #刷新权限表，使配置生效
```
   
然后我们就能远程连接我们的mysql了。

### 关闭远程连接
如果您想关闭远程连接，恢复mysql的默认设置（只能本地连接），您可以通过以下步骤操作：
```
use mysql                #打开mysql数据库
#将host设置为localhost表示只能本地连接mysql
update user set host='localhost' where user='root';
flush privileges;        #刷新权限表，使配置生效
```
备注：您也可以添加一个用户名为yuancheng，密码为123456，权限为%（表示任意ip都能连接）的远程连接用户。命令参考如下：
```
grant all on *.* to 'yuancheng'@'%' identified by '123456';
flush privileges;
```
