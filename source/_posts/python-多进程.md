title: python--多进程
author: hanlin
tags:
  - python
categories: []
date: 2017-05-02 17:35:00
---
上节说到由于GIL（全局解释锁）的问题，多线程并不能充分利用多核处理器，如果是一个CPU计算型的任务，应该使用多进程模块 multiprocessing 。它的工作方式与线程库完全不同，但是两种库的语法却非常相似。multiprocessing给每个进程赋予单独的Python解释器，这样就规避了全局解释锁所带来的问题。但是也别高兴的太早，因为你会遇到接下来说到的一些多进程之间通信的问题。

<!--more-->
我们首先把上节的例子改成单进程和多进程的方式来对比下性能：
```python
import time
import multiprocessing

def profile(func):
    def wrapper(*args, **kwargs):
        import time
        start = time.time()
        func(*args, **kwargs)
        end   = time.time()
        print 'COST: {}'.format(end - start)
    return wrapper
    
def fib(n):
    if n<= 2:
        return 1
    return fib(n-1) + fib(n-2)
    
@profile
def nomultiprocess():
    fib(35)
    fib(35)
    
@profile
def hasmultiprocess():
    jobs = []
    for i in range(2):
        p = multiprocessing.Process(target=fib, args=(35,))
        p.start()
        jobs.append(p)
    for p in jobs:
        p.join()
        
nomultiprocess()
hasmultiprocess()
```
运行的结果还不错：
```shell
❯ python profile_process.py
COST: 4.66861510277
COST: 2.5424861908
```
虽然多进程让效率差不多翻了倍，但是需要注意，其实这个时间就是2个执行fib(35)，最慢的那个进程的执行时间而已。不管怎么说，GIL的问题算是极大的缓解了。

### 进程池
有一点要强调：任务的执行周期决定于CPU核数和任务分配算法。上面例子中hasmultiprocess函数的用法非常中规中矩且常见，但是我认为更好的写法是使用Pool，也就是对应线程池的进程池:
```python
from multiprocessing import Pool
pool = Pool(2)
pool.map(fib, [35] * 2)
```
其中map方法用起来和内置的map函数一样，却有多进程的支持。

### 进程同步
multiprocessing的Lock、Condition、Event、RLock、Semaphore等同步原语和threading模块的机制是一样的，用法也类似。


### 进程通信

进程通信主要有以下几种方式：
- 共享内存
- 管道（pipe, fifo）
- 消息队列（queue）
- socket（TCP/IP）
- 远程过程调用（rpc）
- 此外，python也有对以上方式的高级封装manger模块，可用于简单的代理模式，以及分布式进程通信。

以下一一阐述：
#### 共享内存
主要通过Value或者Array来实现。常见的共享的有以下几种：
```shell
In : from multiprocessing.sharedctypes import typecode_to_type
In : typecode_to_type
Out:
{'B': ctypes.c_ubyte,
 'H': ctypes.c_ushort,
 'I': ctypes.c_uint,
 'L': ctypes.c_ulong,
 'b': ctypes.c_byte,
 'c': ctypes.c_char,
 'd': ctypes.c_double,
 'f': ctypes.c_float,
 'h': ctypes.c_short,
 'i': ctypes.c_int,
 'l': ctypes.c_long,
 'u': ctypes.c_wchar}
```
而且共享的时候还可以给Value或者Array传递lock参数来决定是否带锁，如果不指定默认为RLock。

我们看一个例子：
```python
from multiprocessing import Process, Lock
from multiprocessing.sharedctypes import Value, Array
from ctypes import Structure, c_bool, c_double
lock = Lock()
class Point(Structure):
    _fields_ = [('x', c_double), ('y', c_double)]
def modify(n, b, s, arr, A):
    n.value **= 2
    b.value = True
    s.value = s.value.upper()
    arr[0] = 10
    for a in A:
        a.x **= 2
        a.y **= 2
n = Value('i', 7)
b = Value(c_bool, False, lock=False)
s = Array('c', 'hello world', lock=lock)
arr = Array('i', range(5), lock=True)
A = Array(Point, [(1.875, -6.25), (-5.75, 2.0)], lock=lock)
p = Process(target=modify, args=(n, b, s, arr, A))
p.start()
p.join()
print n.value
print b.value
print s.value
print arr[:]
print [(a.x, a.y) for a in A]
```
有2点需要注意：
- 并不是只支持typecode_to_type中指定那些类型，只要在ctypes里面的类型就可以。
- arr是一个int的数组，但是和array模块生成的数组以及list是不一样的，它是一个SynchronizedArray对象，支持的方法很有限，比如append/extend等方法是没有的。
输出结果如下：

```shell
❯ python shared_memory.py
49
True
HELLO WORLD
[10, 1, 2, 3, 4]
[(3.515625, 39.0625), (33.0625, 4.0)]

```

#### 管道（pipe, fifo）
##### 1. pipe无名管道
管道是Linux中很重要的一种通信方式，是把一个程序的输出直接连接到另一个程序的输入，无名管道只能用于具有亲缘关系的进程之间，这是它与有名管道的最大区别。管道是Linux支持的最初Unix IPC形式之一，具有以下特点

1. 管道是半双工的，数据只能向一个方向流动; 需要双方通信时，需要建立起两个管道  
2. 只能用于父子进程或者兄弟进程之间(具有亲缘关系的进程)
3. 单独构成一种独立的文件系统: 管道对于管道两端的进程而言，就是一个文件，但它不是普通的文件，它不属于某种文件系统，而是自立门户，单独构成一种文件系统，并且只存在与内存中 
4. 数据的读出和写入: 一个进程向管道中写的内容被管道另一端的进程读出。写入的内容每次都添加在管道缓冲区的末尾，并且每次都是从缓冲区的头部读出数据 

```python
from multiprocessing import Process, Pipe

def f(conn):
    conn.send(['hello'])
    conn.close()
    
parent_conn, child_conn = Pipe()
p = Process(target=f, args=(child_conn,))
p.start()
print parent_conn.recv()
p.join()
```
其中Pipe返回的是管道2边的对象：「父连接」和「子连接」。当子连接发送一个带有hello字符串的列表，父连接就会收到，所以parent_conn.recv()就会打印出来。这样就可以简单的实现在多进程之间传输Python内置的数据结构了。
##### 2. fifo命名管道
命名管道使用文件系统，由mkfifo()方法创建。一旦创建了，两个独立的进程都可以访问它，一个读，另外一个写。

命名管道支持阻塞读和阻塞写操作： 如果一个进程打开文件读，它会阻塞直到另外一个进程写。 但是我们可以指定O_NONBLOCK选项来启用非阻塞模式。

命名管道必须以只读或者只写的模式打开，它不能以读+写的模式打开，因为它时单向通信。如果要实现双向通信，必须打开两个命名管道。
看下面例子：

*pipe_test_1.py*
```python
#!/usr/bin/python
import cPickle
import os

#communicate with another process through named pipe
#one for receive command, the other for send command

wfPath = "./p1"
rfPath = "./p2"

wp = open(wfPath, 'w')
wp.write("P1: How are you?")        
wp.close()

rp = open(rfPath, 'r')
response = rp.read()
print "P1 hear %s" % response
rp.close()

wp = open(wfPath, 'w')
wp.write("P1: I'm fine too.")       
wp.close()
```
*pipe_test_2.py*
```python
#!/usr/bin/python
import cPickle
import os

#communicate with another process through named pipe
#one for receive command, the other for send command

rfPath = "./p1"
wfPath = "./p2"

try:
    os.mkfifo(wfPath)
    os.mkfifo(rfPath)
except OSError:
    pass

rp = open(rfPath, 'r')
response = rp.read()
print "P2 hear %s" % response
rp.close()

wp = open(wfPath, 'w')
wp.write("P2: I'm fine, thank you! And you?")       
wp.close()

rp = open(rfPath, 'r')
response = rp.read()
print "P2 hear %s" % response
rp.close()
```
运行上面的例子代码需要：

1. 打开一个终端, 运行 pipe_test_2.py
2. 启动另一个终端，运行pipe_test_1.py

需要注意要先执行pipe_test_2.py 否则会报错，打不开管道。

#### 消息队列（queue）
多线程有Queue模块实现队列，多进程模块也包含了Queue类，它是线程和进程安全的。现在我们给下面的生产者/消费者的例子添加点难度，也就是用2个队列：一个队列用于存储待完成的任务，另外一个用于存储任务完成后的结果：
```python
import time
from multiprocessing import Process, JoinableQueue, Queue
from random import random

tasks_queue = JoinableQueue()
results_queue = Queue()

def double(n):
    return n * 2
    
def producer(in_queue):
    while 1:
        wt = random()
        time.sleep(wt)
        in_queue.put((double, wt))
        if wt > 0.9:
            in_queue.put(None)
            print 'stop producer'
            break
            
def consumer(in_queue, out_queue):
    while 1:
        task = in_queue.get()
        if task is None:
            break
        func, arg = task
        result = func(arg)
        in_queue.task_done()
        out_queue.put(result)
        
processes = []
p = Process(target=producer, args=(tasks_queue,))
p.start()
processes.append(p)

p = Process(target=consumer, args=(tasks_queue, results_queue))
p.start()
processes.append(p)

tasks_queue.join()
for p in processes:
    p.join()
    
while 1:
    if results_queue.empty():
        break
    result = results_queue.get()
    print 'Result:', result
```
咋眼看去，和线程的那个队列例子已经变化很多了：

- 生产者已经不会持续的生产任务了，如果随机到的结果大于0.9就会给任务队列tasks_queue put一个None，然后把循环结束掉
- 消费者如果收到一个值为None的任务，就结束，否则执行从tasks_queue获取的任务，并把结果put进results_queue
- 生产者和消费者都结束后（又join方法保证），从results_queue挨个获取执行结果并打印出来

进程的Queue类并不支持task_done和join方法，需要使用特别的JoinableQueue，而搜集结果的队列results_queue使用Queue就足够了。

#### socket（TCP/IP）
我会专门列一个关于socket的专题出来整理，此处不在阐述。

#### 远程过程调用（rpc）
RPC是一个应用层的协议，分为client端和server端，server端写好了具体的函数实现，client端远程调用该函数，返回函数的结果。
其实底层依旧是socket。
看以下例子：

*Server code*
```python
from xmlrpc.server import SimpleXMLRPCServer
from xmlrpc.server import SimpleXMLRPCRequestHandler

# Restrict to a particular path.
class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2',)

# Create server
with SimpleXMLRPCServer(("localhost", 8000),
                        requestHandler=RequestHandler) as server:
    server.register_introspection_functions()

    # Register pow() function; this will use the value of
    # pow.__name__ as the name, which is just 'pow'.
    server.register_function(pow)

    # Register a function under a different name
    def adder_function(x,y):
        return x + y
    server.register_function(adder_function, 'add')

    # Register an instance; all the methods of the instance are
    # published as XML-RPC methods (in this case, just 'mul').
    class MyFuncs:
        def mul(self, x, y):
            return x * y

    server.register_instance(MyFuncs())

    # Run the server's main loop
    server.serve_forever()
```
*client code*
```python
import xmlrpc.client

s = xmlrpc.client.ServerProxy('http://localhost:8000')
print(s.pow(2,3))  # Returns 2**3 = 8
print(s.add(2,3))  # Returns 5
print(s.mul(5,2))  # Returns 5*2 = 10

# Print list of available methods
print(s.system.listMethods())
```

#### manager 模块
manger是进程间通信的高级封装模块，主要有以下：
1. Namespace。创建一个可分享的命名空间。
2. Value/Array。和上面共享ctypes对象的方式一样。
3. dict/list。创建一个可分享的dict/list，支持对应数据结构的方法。
4. Condition/Event/Lock/Queue/Semaphore。创建一个可分享的对应同步原语的对象。

```python
from multiprocessing import Manager, Process

def modify(ns, lproxy, dproxy):
    ns.a **= 2
    lproxy.extend(['b', 'c'])
    dproxy['b'] = 0
    
manager = Manager()
ns = manager.Namespace()
ns.a = 1
lproxy = manager.list()
lproxy.append('a')
dproxy = manager.dict()
dproxy['b'] = 2

p = Process(target=modify, args=(ns, lproxy, dproxy))
p.start()

print 'PID:', p.pid
p.join()

print ns.a
print lproxy
print dproxy
```
在id为8341的进程中就可以修改共享状态了：
```shell
❯ python manager.py
PID: 8341
1
['a', 'b', 'c']
{'b': 0}
```

### 分布式进程
有时候没有必要舍近求远的选择更复杂的方案，其实使用Manager和Queue就可以实现简单的分布式的不同服务器的不同进程间的通信（C/S模式）。

首先在远程服务器上写如下的一个程序：
```python
from multiprocessing.managers import BaseManager

host = '127.0.0.1'
port = 9030
authkey = 'secret'

shared_list = []

class RemoteManager(BaseManager):
    pass
    
RemoteManager.register('get_list', callable=lambda: shared_list)
mgr = RemoteManager(address=(host, port), authkey=authkey)

server = mgr.get_server()
server.serve_forever()
```
现在希望其他代理可以修改和获取到shared_list的值，那么写这么一个客户端程序：
```python
from multiprocessing.managers import BaseManager

host = '127.0.0.1'
port = 9030
authkey = 'secret'

class RemoteManager(BaseManager):
    pass
    
RemoteManager.register('get_list')
mgr = RemoteManager(address=(host, port), authkey=authkey)
mgr.connect()

l = mgr.get_list()
print l
l.append(1)
print mgr.get_list()
```
注意，在client上的注册没有添加callable参数。
此处有一个利用分布式进程实现的百科爬虫的小demo。
(https://github.com/hehanlin/baikeSpiderDistributed)