title: socket--实现
author: hanlin
tags:
  - python
categories: []
date: 2017-06-15 15:34:00
---
### 实现
Socket 作为一种通用的技术规范，首次是由 Berkeley 大学在 1983 为 4.2BSD Unix 提供的，后来逐渐演化为 POSIX 标准。Socket API 是由操作系统提供的一个编程接口，让应用程序可以控制使用 socket 技术。Unix 哲学中有一条一切皆为文件，所以 socket 和 file 的 API 使用很类似：可以进行read、write、open、close等操作。

<!--more-->

现在的网络系统是分层的，理论上有OSI模型，工业界有TCP/IP协议簇。其对比如下：

![upload successful](/images/imagesocketq1.png)
每层上都有其相应的协议，socket API 不属于TCP/IP协议簇，只是操作系统提供的一个用于网络编程的接口，工作在应用层与传输层之间：

![upload successful](/images/imagesocketq2.png)
我们平常浏览网站所使用的http协议，收发邮件用的smtp与imap，都是基于 socket API 构建的。

一个 socket，包含两个必要组成部分：

1. 地址，由 ip 与 端口组成，像192.168.0.1:80。
2. 协议，socket 所是用的传输协议，目前有三种：TCP、UDP、raw IP。

地址与协议可以确定一个socket；一台机器上，只允许存在一个同样的socket。TCP 端口 53 的 socket 与 UDP 端口 53 的 socket 是两个不同的 socket。

根据 socket 传输数据方式的不同（使用协议不同），可以分为以下三种：

Stream sockets，也称为“面向连接”的 socket，使用 TCP 协议。实际通信前需要进行连接，传输的数据没有特定的结构，所以高层协议需要自己去界定数据的分隔符，但其优势是数据是可靠的。
Datagram sockets，也称为“无连接”的 socket，使用 UDP 协议。实际通信前不需要连接，一个优势时 UDP 的数据包自身是可分割的（self-delimiting），也就是说每个数据包就标示了数据的开始与结束，其劣势是数据不可靠。

Raw sockets，通常用在路由器或其他网络设备中，这种 socket 不经过TCP/IP协议簇中的传输层（transport layer），直接由网络层（Internet layer）通向应用层（Application layer），所以这时的数据包就不会包含 tcp 或 udp 头信息。

![upload successful](/images/imagesocketq3.png)
### Python socket API
Python 里面用(ip, port)的元组来表示 socket 的地址属性，用AF_*来表示协议类型。
数据通信有两组动词可供选择：send/recv 或 read/write。
>read/write 操作的具有 buffer 的“文件”，所以在进行读写后需要调用flush方法去真正发送或读取数据，否则数据会一直停留在缓冲区内。
#### TCP socket
TCP socket 由于在通向前需要建立连接，所以其模式较 UDP socket 负责些。具体如下：

![upload successful](/images/imagesocketq4.png)
每个API 的具体含义这里不在赘述，可以查看手册，这里给出 Python 语言的实现的 echo server。
```python
# echo_server.py
# coding=utf8
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 设置 SO_REUSEADDR 后,可以立即使用 TIME_WAIT 状态的 socket
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind(('', 5500))
sock.listen(5)

def handler(client_sock, addr):
    print('new client from %s:%s' % addr)
    msg = client_sock.recv(1024)
    client_sock.send(msg)
    client_sock.close()
    print('client[%s:%s] socket closed' % addr)

if __name__ == '__main__':
    while 1:
        client_sock, addr = sock.accept()
        handler(client_sock, addr)

```

```python
# echo_client.py
# coding=utf8
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('', 5500))
sock.send('hello socket world')
print sock.recv(1024)

```
上面简单的echo server 代码中有一点需要注意的是：server 端的 socket 设置了SO_REUSEADDR为1，目的是可以立即使用处于TIME_WAIT状态的socket，那么TIME_WAIT又是什么意思呢？后面在讲解 tcp 状态变更图时再做详细介绍。
#### UDP socket

![upload successful](/images/imagesocketq5.png)
UDP socket server 端代码在进行bind后，无需调用listen方法。
```python
# udp_echo_server.py
# coding=utf8
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# 设置 SO_REUSEADDR 后,可以立即使用 TIME_WAIT 状态的 socket
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind(('', 5500))
# 没有调用 listen

if __name__ == '__main__':
    while 1:
        data, addr = sock.recvfrom(1024)

        print('new client from %s:%s' % addr)
        sock.sendto(data, addr)

# udp_echo_client.py
# coding=utf8
import socket

udp_server_addr = ('', 5500)

if __name__ == '__main__':
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    data_to_sent = 'hello udp socket'
    try:
        sent = sock.sendto(data_to_sent, udp_server_addr)
        data, server = sock.recvfrom(1024)
        print('receive data:[%s] from %s:%s' % ((data,) + server))
    finally:
        sock.close()

```
#### 常见陷阱
##### 忽略返回值
本文中的 echo server 示例因为篇幅限制，也忽略了返回值。网络通信是个非常复杂的问题，通常无法保障通信双方的网络状态，很有可能在发送/接收数据时失败或部分失败。所以有必要对发送/接收函数的返回值进行检查。本文中的 tcp echo client 发送数据时，正确写法应该如下：
```python
total_send = 0
content_length = len(data_to_sent)
while total_send < content_length:
    sent = sock.send(data_to_sent[total_send:])
    if sent == 0:
        raise RuntimeError("socket connection broken")
    total_send += total_send + sent
```
send/recv操作的是网络缓冲区的数据，它们不必处理传入的所有数据。
>一般来说，当网络缓冲区填满时，send函数就返回了；当网络缓冲区被清空时，recv 函数就返回。
当 recv 函数返回0时，意味着对端已经关闭。

可以通过下面的方式设置缓冲区大小。
```python
s.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, buffer_size)

```
##### 认为 TCP 具有 framing
TCP 不提供 framing，这使得其很适合于传输数据流。这是其与 UDP 的重要区别之一。UDP 是一个面向消息的协议，能保持一条消息在发送者与接受者之间的完备性。

![upload successful](/images/imagesocketq6.png)
#### TCP 的状态机
在前面echo server 的示例中，提到了TIME_WAIT状态，为了正式介绍其概念，需要了解下 TCP 从生成到结束的状态机器。

![upload successful](/images/imagesocketq7.png)
这个状图转移图非常非常关键，也比较复杂，我自己为了方便记忆，对这个图进行了拆解，仔细分析这个图，可以得出这样一个结论，连接的打开与关闭都有被动（passive）与主动（active）两种，主动关闭时，涉及到的状态转移最多，包括FIN_WAIT_1、FIN_WAIT_2、CLOSING、TIME_WAIT。

此外，由于 TCP 是可靠的传输协议，所以每次发送一个数据包后，都需要得到对方的确认（ACK），有了上面这两个知识后，再来看下面的图：

![upload successful](/images/imagesocketq8.png)
1. 在主动关闭连接的 socket 调用 close方法的同时，会向被动关闭端发送一个 FIN
2. 对端收到FIN后，会向主动关闭端发送ACK进行确认，这时被动关闭端处于 CLOSE_WAIT 状态
3. 当被动关闭端调用close方法进行关闭的同时向主动关闭端发送 FIN 信号，接收到 FIN 的主动关闭端这时就处于 TIME_WAIT 状态
4. 这时主动关闭端不会立刻转为 CLOSED 状态，而是需要等待 2MSL（max segment life，一个数据包在网络传输中最大的生命周期），以确保被动关闭端能够收到最后发出的 ACK。如果被动关闭端没有收到最后的 ACK，那么被动关闭端就会重新发送 FIN，所以处于TIME_WAIT的主动关闭端会再次发送一个 ACK 信号，这么一来（FIN来）一回（ACK），正好是两个 MSL 的时间。如果等待的时间小于 2MSL，那么新的socket就可以收到之前连接的数据。

前面 echo server 的示例也说明了，处于 TIME_WAIT 并不是说一定不能使用，可以通过设置 socket 的 SO_REUSEADDR 属性以达到不用等待 2MSL 的时间就可以复用socket 的目的，当然，这仅仅适用于测试环境，正常情况下不要修改这个属性。
#### demo
##### HTTP UA
http 协议是如今万维网的基石，可以通过 socket API 来简单模拟一个浏览器（UA）是如何解析 HTTP 协议数据的。
```python
#coding=utf8
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
baidu_ip = socket.gethostbyname('baidu.com')
sock.connect((baidu_ip, 80))
print('connected to %s' % baidu_ip)

req_msg = [
    'GET / HTTP/1.1',
    'User-Agent: curl/7.37.1',
    'Host: baidu.com',
    'Accept: */*',
]
delimiter = '\r\n'

sock.send(delimiter.join(req_msg))
sock.send(delimiter)
sock.send(delimiter)

print('%sreceived%s' % ('-'*20, '-'*20))
http_response = sock.recv(4096)
print(http_response)
```
运行上面的代码可以得到下面的输出
```python
--------------------received--------------------
HTTP/1.1 200 OK
Server: Apache
ETag: "51-47cf7e6ee8400"
Accept-Ranges: bytes
Content-Length: 81
Cache-Control: max-age=86400
Connection: Keep-Alive
Content-Type: text/html

<html>
<meta http-equiv="refresh" content="0;url=http://www.baidu.com/">
</html>
```
http_response是通过直接调用recv(4096)得到的，万一真正的返回大于这个值怎么办？我们前面知道了 TCP 协议是面向流的，它本身并不关心消息的内容，需要应用程序自己去界定消息的边界，对于应用层的 HTTP 协议来说，有几种情况，最简单的一种时通过解析返回值头部的Content-Length属性，这样就知道body的大小了，对于 HTTP 1.1版本，支持Transfer-Encoding: chunked传输，对于这种格式，这里不在展开讲解，大家只需要知道， TCP 协议本身无法区分消息体就可以了。
##### Unix_domain_socket
UDS 用于同一机器上不同进程通信的一种机制，其API适用与 network socket 很类似。只是其连接地址为本地文件而已。

##### ping
ping 命令作为检测网络联通性最常用的工具，其适用的传输协议既不是TCP，也不是 UDP，而是 ICMP，利用 raw sockets，我们可以适用纯 Python 代码来实现其功能。