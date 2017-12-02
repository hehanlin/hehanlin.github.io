title: nginx配置及优化（中文）
author: hanlin
tags: []
categories: []
date: 2016-01-30 19:08:00
---
### 一、Nginx常用命令：
<!--more-->
>1. 启动 Nginx          /usr/local/nginx/sbin/nginx
poechant@ubuntu:sudo ./sbin/nginx
2. 停止 Nginx
poechant@ubuntu:sudo ./sbin/nginx -s stop
poechant@ubuntu:sudo ./sbin/nginx -s quit
-s都是采用向 Nginx 发送信号的方式。
3. Nginx 重载配置
poechant@ubuntu:sudo ./sbin/nginx -s reload
上述是采用向 Nginx 发送信号的方式，或者使用：
poechant@ubuntu:service nginx reload
4. 指定配置文件
poechant@ubuntu:sudo ./sbin/nginx -c /usr/local/nginx/conf/nginx.conf
-c表示configuration，指定配置文件。
5. 查看 Nginx 版本
有两种可以查看 Nginx 的版本信息的参数。第一种如下：
poechant@ubuntu:/usr/local/nginx ./sbin/nginx -v
nginx: nginx version: nginx/1.0.0
另一种显示的是详细的版本信息：
poechant@ubuntu:/usr/local/nginx ./sbin/nginx -V
nginx: nginx version: nginx/1.0.0
nginx: built by gcc 4.3.3 (Ubuntu 4.3.3-5ubuntu4)
nginx: TLS SNI support enabled
nginx: configure arguments: --with-http_ssl_module --with-openssl=/home/luming/openssl-1.0.0d/
6. 检查配置文件是否正确
poechant@ubuntu:/usr/local/nginx ./sbin/nginx -t
nginx: [alert] could not open error log file: open() "/usr/local/nginx/logs/error.log" failed (13: Permission denied)
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
2012/01/09 16:45:09 [emerg] 23898#0: open() "/usr/local/nginx/logs/nginx.pid" failed (13: Permission denied)
nginx: configuration file /usr/local/nginx/conf/nginx.conf test failed
如果出现如上的提示信息，表示没有访问错误日志文件和进程，可以sudo（super user do）一下：
poerchant@ubuntu:/usr/local/nginx sudo ./sbin/nginx -t
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
如果显示如上，则表示配置文件正确。否则，会有相关提示。
7. 显示帮助信息
poechant@ubuntu:/user/local/nginx ./sbin/nginx -h
或者：
poechant@ubuntu:/user/local/nginx ./sbin/nginx -?

###  二、简单的nginx 配置中文详解：

>定义Nginx运行的用户和用户组
user www www;
nginx进程数，建议设置为等于CPU总核心数。
worker_processes 8;
全局错误日志定义类型，[ debug | info | notice | warn | error | crit ]
error_log /var/log/nginx/error.log info;
进程文件
pid /var/run/nginx.pid;
一个nginx进程打开的最多文件描述符数目，理论值应该是最多打开文件数（系统的值ulimit -n）与nginx进程数相除，但是nginx分配请求并不均匀，所以建议与ulimit -n的值保持一致。
worker_rlimit_nofile 65535;
工作模式与连接数上限
events
{
参考事件模型，use [ kqueue | rtsig | epoll | /dev/poll | select | poll ]; epoll模型是Linux 2.6以上版本内核中的高性能网络I/O模型，如果跑在FreeBSD上面，就用kqueue模型。
use epoll;
单个进程最大连接数（最大连接数=连接数*进程数）
worker_connections 65535;
}
设定http服务器
http
{
include mime.types; #文件扩展名与文件类型映射表
default_type application/octet-stream; #默认文件类型
charset utf-8; #默认编码
server_names_hash_bucket_size 128; #服务器名字的hash表大小
client_header_buffer_size 32k; #上传文件大小限制
large_client_header_buffers 4 64k; #设定请求缓
client_max_body_size 8m; #设定请求缓
sendfile on; #开启高效文件传输模式，sendfile指令指定nginx是否调用sendfile函数来输出文件，对于普通应用设为 on，如果用来进行下载等应用磁盘IO重负载应用，
　　　　　　　　　#可设置为off，以平衡磁盘与网络I/O处理速度，降低系统的负载。注意：如果图片显示不正常把这个改成off。
autoindex on; #开启目录列表访问，合适下载服务器，默认关闭。
tcp_nopush on; #防止网络阻塞
tcp_nodelay on; #防止网络阻塞
keepalive_timeout 120; #长连接超时时间，单位是秒
FastCGI相关参数是为了改善网站的性能：减少资源占用，提高访问速度。下面参数看字面意思都能理解。
fastcgi_connect_timeout 300;
fastcgi_send_timeout 300;
fastcgi_read_timeout 300;
fastcgi_buffer_size 64k;
fastcgi_buffers 4 64k;
fastcgi_busy_buffers_size 128k;
fastcgi_temp_file_write_size 128k;
gzip模块设置
gzip on; #开启gzip压缩输出
gzip_min_length 1k; #最小压缩文件大小
gzip_buffers 4 16k; #压缩缓冲区
gzip_http_version 1.0; #压缩版本（默认1.1，前端如果是squid2.5请使用1.0）
gzip_comp_level 2; #压缩等级
gzip_types text/plain application/x-javascript text/css application/xml;
压缩类型，默认就已经包含text/html，所以下面就不用再写了，写上去也不会有问题，但是会有一个warn。
gzip_vary on;
limit_zone crawler binary_remote_addr 10m; #开启限制IP连接数的时候需要使用
upstream blog.ha97.com {
upstream的负载均衡，weight是权重，可以根据机器配置定义权重。weigth参数表示权值，权值越高被分配到的几率越大。
server 192.168.80.121:80 weight=3;
server 192.168.80.122:80 weight=2;
server 192.168.80.123:80 weight=3;
}
虚拟主机的配置
server
{
监听端口
listen 80;
域名可以有多个，用空格隔开
server_name www.ha97.com ha97.com;
index index.html index.htm index.php;
root /data/www/ha97;
location ~ .*\.(php|php5)?
{
fastcgi_pass 127.0.0.1:9000;
fastcgi_index index.php;
include fastcgi.conf;
}
图片缓存时间设置
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)
{
expires 10d;
}
JS和CSS缓存时间设置
location ~ .*\.(js|css)?
{
expires 1h;
}
日志格式设定
log_format access 'remote_addr - remote_user [time_local] "request" '
'status body_bytes_sent "http_referer" '
'"http_user_agent" http_x_forwarded_for';
定义本虚拟主机的访问日志
access_log /var/log/nginx/ha97access.log access;
对 "/" 启用反向代理
location / {
proxy_pass http://127.0.0.1:88;
proxy_redirect off;
proxy_set_header X-Real-IP remote_addr;
后端的Web服务器可以通过X-Forwarded-For获取用户真实IP
proxy_set_header X-Forwarded-For proxy_add_x_forwarded_for;
以下是一些反向代理的配置，可选。
proxy_set_header Host host;
client_max_body_size 10m; #允许客户端请求的最大单文件字节数
client_body_buffer_size 128k; #缓冲区代理缓冲用户端请求的最大字节数，
proxy_connect_timeout 90; #nginx跟后端服务器连接超时时间(代理连接超时)
proxy_send_timeout 90; #后端服务器数据回传时间(代理发送超时)
proxy_read_timeout 90; #连接成功后，后端服务器响应时间(代理接收超时)
proxy_buffer_size 4k; #设置代理服务器（nginx）保存用户头信息的缓冲区大小
proxy_buffers 4 32k; #proxy_buffers缓冲区，网页平均在32k以下的设置
proxy_busy_buffers_size 64k; #高负荷下缓冲大小（proxy_buffers*2）
proxy_temp_file_write_size 64k;
设定缓存文件夹大小，大于这个值，将从upstream服务器传
}
设定查看Nginx状态的地址
location /NginxStatus {
stub_status on;
access_log on;
auth_basic "NginxStatus";
auth_basic_user_file conf/htpasswd;
htpasswd文件的内容可以用apache提供的htpasswd工具来产生。
}
本地动静分离反向代理配置
所有jsp的页面均交由tomcat或resin处理
location ~ .(jsp|jspx|do)? {
proxy_set_header Host host;
proxy_set_header X-Real-IP remote_addr;
proxy_set_header X-Forwarded-For proxy_add_x_forwarded_for;
proxy_pass http://127.0.0.1:8080;
}
所有静态文件由nginx直接读取不经过tomcat或resin
location ~ .*.(htm|html|gif|jpg|jpeg|png|bmp|swf|ioc|rar|zip|txt|flv|mid|doc|ppt|pdf|xls|mp3|wma)
{ expires 15d; }
location ~ .*.(js|css)?
{ expires 1h; }
}
}

### 三、nginx 配置文件中对优化比较有作用的为以下几项：
>worker_processes 8;
nginx 进程数，建议按照cpu 数目来指定，一般为它的倍数。

>worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;
为每个进程分配cpu，上例中将8 个进程分配到8 个cpu，当然可以写多个，或者将一
个进程分配到多个cpu。

>worker_rlimit_nofile 102400;
这个指令是指当一个nginx 进程打开的最多文件描述符数目，理论值应该是最多打开文
件数（ulimit -n）与nginx 进程数相除，但是nginx 分配请求并不是那么均匀，所以最好与ulimit -n 的值保持一致。

>use epoll;
使用epoll 的I/O 模型

>worker_connections 102400;
每个进程允许的最多连接数， 理论上每台nginx 服务器的最大连接数为worker_processes*worker_connections。

>keepalive_timeout 60;
keepalive 超时时间。

>client_header_buffer_size 4k;
客户端请求头部的缓冲区大小，这个可以根据你的系统分页大小来设置，一般一个请求
头的大小不会超过1k，不过由于一般系统分页都要大于1k，所以这里设置为分页大小。分页大小可以用命令getconf PAGESIZE 取得。

>open_file_cache max=102400 inactive=20s;
这个将为打开文件指定缓存，默认是没有启用的，max 指定缓存数量，建议和打开文件数一致，inactive 是指经过多长时间文件没被请求后删除缓存。

>open_file_cache_valid 30s;
这个是指多长时间检查一次缓存的有效信息。

>open_file_cache_min_uses 1;
open_file_cache 指令中的inactive 参数时间内文件的最少使用次数，如果超过这个数字，文件描述符一直是在缓存中打开的，如上例，如果有一个文件在inactive 时间内一次没被使用，它将被移除。

#### 关于内核参数的优化：

>net.ipv4.tcp_max_tw_buckets = 6000
timewait 的数量，默认是180000。

>net.ipv4.ip_local_port_range = 1024 65000
允许系统打开的端口范围。

>net.ipv4.tcp_tw_recycle = 1
启用timewait 快速回收。

>net.ipv4.tcp_tw_reuse = 1
开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接。

>net.ipv4.tcp_syncookies = 1
开启SYN Cookies，当出现SYN 等待队列溢出时，启用cookies 来处理。

>net.core.somaxconn = 262144
web 应用中listen 函数的backlog 默认会给我们内核参数的net.core.somaxconn 限制到128，而nginx 定义的NGX_LISTEN_BACKLOG 默认为511，所以有必要调整这个值。

>net.core.netdev_max_backlog = 262144
每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目。

>net.ipv4.tcp_max_orphans = 262144
系统中最多有多少个TCP 套接字不被关联到任何一个用户文件句柄上。如果超过这个数字，孤儿连接将即刻被复位并打印出警告信息。这个限制仅仅是为了防止简单的DoS 攻击，不能过分依靠它或者人为地减小这个值，更应该增加这个值(如果增加了内存之后)。

>net.ipv4.tcp_max_syn_backlog = 262144
记录的那些尚未收到客户端确认信息的连接请求的最大值。对于有128M 内存的系统而言，缺省值是1024，小内存的系统则是128。

>net.ipv4.tcp_timestamps = 0
时间戳可以避免序列号的卷绕。一个1Gbps 的链路肯定会遇到以前用过的序列号。时间戳能够让内核接受这种“异常”的数据包。这里需要将其关掉。

>net.ipv4.tcp_synack_retries = 1
为了打开对端的连接，内核需要发送一个SYN 并附带一个回应前面一个SYN 的ACK。也就是所谓三次握手中的第二次握手。这个设置决定了内核放弃连接之前发送SYN+ACK 包的数量。

>net.ipv4.tcp_syn_retries = 1
在内核放弃建立连接之前发送SYN 包的数量。

>net.ipv4.tcp_fin_timeout = 1
如果套接字由本端要求关闭，这个参数决定了它保持在FIN-WAIT-2 状态的时间。对端可以出错并永远不关闭连接，甚至意外当机。缺省值是60
秒。2.2 内核的通常值是180 秒，3你可以按这个设置，但要记住的是，即使你的机器是一个轻载的WEB
服务器，也有因为大量的死套接字而内存溢出的风险，FIN- WAIT-2 的危险性比FIN-WAIT-1 要小，因为它最多只能吃掉1.5K
内存，但是它们的生存期长些。

>net.ipv4.tcp_keepalive_time = 30
当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时。


#### 下面贴一个完整的内核优化设置：
```
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000

```

#### 下面是一个简单的nginx 配置文件：
```
user www www;
worker_processes 8;
worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000
01000000;
error_log /www/log/nginx_error.log crit;
pid /usr/local/nginx/nginx.pid;
worker_rlimit_nofile 204800;
events
{
use epoll;
worker_connections 204800;
}
http
{
include mime.types;
default_type application/octet-stream;
charset utf-8;
server_names_hash_bucket_size 128;
client_header_buffer_size 2k;
large_client_header_buffers 4 4k;
client_max_body_size 8m;
sendfile on;
tcp_nopush on;
keepalive_timeout 60;
fastcgi_cache_path /usr/local/nginx/fastcgi_cache levels=1:2
keys_zone=TEST:10m
inactive=5m;
fastcgi_connect_timeout 300;
fastcgi_send_timeout 300;
fastcgi_read_timeout 300;
fastcgi_buffer_size 4k;
fastcgi_buffers 8 4k;
fastcgi_busy_buffers_size 8k;
fastcgi_temp_file_write_size 8k;
fastcgi_cache TEST;
fastcgi_cache_valid 200 302 1h;
fastcgi_cache_valid 301 1d;
fastcgi_cache_valid any 1m;
fastcgi_cache_min_uses 1;
fastcgi_cache_use_stale error timeout invalid_header http_500;
open_file_cache max=204800 inactive=20s;
open_file_cache_min_uses 1;
open_file_cache_valid 30s;
tcp_nodelay on;
gzip on;
gzip_min_length 1k;
gzip_buffers 4 16k;
gzip_http_version 1.0;
gzip_comp_level 2;
gzip_types text/plain application/x-javascript text/css application/xml;
gzip_vary on;
server
{
listen 8080;
server_name backup.aiju.com;
index index.php index.htm;
root /www/html/;
location /status
{
stub_status on;
}
location ~ .*\.(php|php5)?
{
fastcgi_pass 127.0.0.1:9000;
fastcgi_index index.php;
include fcgi.conf;
}
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|js|css)
{
expires 30d;
}
log_format access 'remote_addr -- remote_user [time_local] "request" '
'status body_bytes_sent "http_referer" '
'"http_user_agent" http_x_forwarded_for';
access_log /www/log/access.log access;
}
}
```
