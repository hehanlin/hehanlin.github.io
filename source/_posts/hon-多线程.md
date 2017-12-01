title: python--多线程
author: hanlin
tags:
  - python
categories: []
date: 2017-04-15 14:23:00
---
多进程和多线程都可以执行多个任务，我们先介绍多线程。
线程是进程的一部分。线程的特点是线程之间可以共享内存和变量，资源消耗少（不过在Unix环境中，多进程和多线程资源调度消耗差距不明显，Unix调度较快）。python使用操作系统提供的内核级线程一比一模型，但是有一把GIL.
<!--more-->
### GIL
Python（特指CPython）的多线程的代码并不能利用多核的优势，而是通过著名的全局解释锁（GIL）来进行处理的。如果是一个计算型的任务，使用多线程GIL就会让多线程变慢。我们举个计算斐波那契数列的例子：
```python
# coding=utf-8
import time
import threading
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
def nothread():
    fib(35)
    fib(35)
    
@profile
def hasthread():
    for i in range(2):
        t = threading.Thread(target=fib, args=(35,))
        t.start()
        
    main_thread = threading.currentThread()
    
    for t in threading.enumerate():
        if t is main_thread:
            continue
        t.join()
        
nothread()
hasthread()
```
运行的结果你猜猜会怎么样：
```shell
❯ python profile_thread.py
COST: 5.05716490746
COST: 6.75599503517
```
这种情况还不如不用多线程！

GIL是必须的，这是Python设计的问题：Python解释器是非线程安全的。这意味着当从线程内尝试安全的访问Python对象的时候将有一个全局的强制锁。 在任何时候，仅仅一个单一的线程能够获取Python对象或者C API。每100个字节的Python指令解释器将重新获取锁，这（潜在的）阻塞了I/O操作。因为锁，CPU密集型的代码使用线程库时，不会获得性能的提高（但是当它使用之后介绍的多进程库时，性能可以获得提高）。

那是不是由于GIL的存在，多线程库就是个「鸡肋」呢？当然不是。事实上我们平时会接触非常多的和网络通信或者数据输入/输出相关的程序，比如网络爬虫、文本处理等等。这时候由于网络情况和I/O的性能的限制，Python解释器会等待读写数据的函数调用返回，这个时候就可以利用多线程库提高并发效率了。
### 同步机制
如果多个线程共同对某个数据修改，则可能出现不可预料的结果，为了保证数据的正确性，需要对多个线程进行同步。
#### (1)Lock
Lock也可以叫做互斥锁，其实相当于信号量为1。我们先看一个不加锁的例子：
```python
import time
from threading import Thread
value = 0

def getlock():
    global value
    new = value + 1
    time.sleep(0.001)  # 使用sleep让线程有机会切换
    value = new
    
threads = []

for i in range(100):
    t = Thread(target=getlock)
    t.start()
    threads.append(t)
    
for t in threads:
    t.join()
    
print value
```
执行一下：
```shell
❯ python nolock.py
16
```
不加锁的情况下，结果会远远的小于100。很明显是错的，那我们加上互斥锁看看：
```python
import time
from threading import Thread, Lock
value = 0
lock = Lock()

def getlock():
    global value
    with lock:
        new = value + 1
        time.sleep(0.001)
        value = new
        
threads = []

for i in range(100):
    t = Thread(target=getlock)
    t.start()
    threads.append(t)
    
for t in threads:
    t.join()
    
print value
```
我们对value的自增加了锁，就可以保证了结果了：
```shell
❯ python lock.py
100
```

#### (2)RLock
RLock是可重入锁（自旋锁），提供和lock对象相同的方法，可重入锁的特点是：
- 记录锁住自己的线程 t ，这样 t 可以多次调用 acquire() 方法而不会被阻塞，比如 t 可以多次声明自己对某个资源的需求。
- 可重入锁必须由锁住自己的线程释放（rl.release()）
- rlock内部有一个计数器，只有锁住自己的线程 t 调用的 release() 方法和之前调用 acquire() 方法的次数相同时，才会真正解锁一个rlock。

#### (3)Semaphore（信号量）
信号量同步基于内部计数器，每调用一次acquire()，计数器减1；每调用一次release()，计数器加1.当计数器为0时，acquire()调用被阻塞。所以信号量可以对资源数量进行控制。
```python
import time
from random import random
from threading import Thread, Semaphore

sema = Semaphore(3)

def foo(tid):
    with sema:
        print '{} acquire sema'.format(tid)
        wt = random() * 2
        time.sleep(wt)
    print '{} release sema'.format(tid)
    
threads = []

for i in range(5):
    t = Thread(target=foo, args=(i,))
    threads.append(t)
    t.start()
    
for t in threads:
    t.join()
```
这个例子中，我们限制了同时能访问资源的数量为3。看一下执行的效果：
```shell
❯ python semaphore.py
0 acquire sema
1 acquire sema
 2 acquire sema
2 release sema
 3 acquire sema
1 release sema
 4 acquire sema
0 release sema
3 release sema
4 release sema
```

#### (4)Condition（条件）
一个线程等待特定条件，而另一个线程发出特定条件满足的信号。最好说明的例子就是「生产者/消费者」模型：
```python
import time
import threading

def consumer(cond):
    t = threading.currentThread()
    with cond:
        cond.wait()  # wait()方法创建了一个名为waiter的锁，并且设置锁的状态为locked。这个waiter锁用于线程间的通讯
        print '{}: Resource is available to consumer'.format(t.name)
        
def producer(cond):
    t = threading.currentThread()
    with cond:
        print '{}: Making resource available'.format(t.name)
        cond.notifyAll()  # 释放waiter锁，唤醒消费者
        
condition = threading.Condition()
c1 = threading.Thread(name='c1', target=consumer, args=(condition,))
c2 = threading.Thread(name='c2', target=consumer, args=(condition,))
p = threading.Thread(name='p', target=producer, args=(condition,))
c1.start()
time.sleep(1)
c2.start()
time.sleep(1)
p.start()

```
执行一下：

```shell
❯ python condition.py
p: Making resource available
c2: Resource is available to consumer
c1: Resource is available to consumer
```
可以看到生产者发送通知之后，消费者都收到了。

#### (5)Event
Event对象可以让任何数量的线程暂停和等待，event 对象对应一个 True 或 False 的状态（flag），刚创建的event对象的状态为False。
```python
# coding=utf-8
import time
import threading
from random import randint

TIMEOUT = 2

def consumer(event, l):
    t = threading.currentThread()
    while 1:
        event_is_set = event.wait(TIMEOUT)
        if event_is_set:
            try:
                integer = l.pop()
                print '{} popped from list by {}'.format(integer, t.name)
                event.clear()  # 重置事件状态
            except IndexError:  # 为了让刚启动时容错
                pass
                
def producer(event, l):
    t = threading.currentThread()
    while 1:
        integer = randint(10, 100)
        l.append(integer)
        print '{} appended to list by {}'.format(integer, t.name)
        event.set()	 # 设置事件
        time.sleep(1)
        
event = threading.Event()
l = []
threads = []
for name in ('consumer1', 'consumer2'):
    t = threading.Thread(name=name, target=consumer, args=(event, l))
    t.start()
    threads.append(t)
    
p = threading.Thread(name='producer1', target=producer, args=(event, l))
p.start()
threads.append(p)
for t in threads:
    t.join()
```
执行的效果是这样的：
```shell
77 appended to list by producer1
77 popped from list by consumer1
46 appended to list by producer1
46 popped from list by consumer2
43 appended to list by producer1
43 popped from list by consumer2
37 appended to list by producer1
37 popped from list by consumer2
33 appended to list by producer1
33 popped from list by consumer2
57 appended to list by producer1
57 popped from list by consumer1

```
可以看到事件被2个消费者比较平均的接收并处理了。如果使用了wait方法，线程就会等待我们设置事件，这也有助于保证任务的完成。

#### (6)Queue（线程通信的常用手段）
队列在并发开发中最常用的。我们借助「生产者/消费者」模式来理解：生产者把生产的「消息」放入队列，消费者从这个队列中对去对应的消息执行。

大家主要关心如下4个方法就好了：

- put: 向队列中添加一个项。
- get: 从队列中删除并返回一个项。
- task_done: 当某一项任务完成时调用。
- join: 阻塞直到所有的项目都被处理完。

```python
# coding=utf-8
import time
import threading
from random import random
from Queue import Queue

q = Queue()

def double(n):
    return n * 2
    
def producer():
    while 1:
        wt = random()
        time.sleep(wt)
        q.put((double, wt))
        
def consumer():
    while 1:
        task, arg = q.get()
        print arg, task(arg)
        q.task_done()
        
for target in(producer, consumer):
    t = threading.Thread(target=target)
    t.start()
```
这就是最简化的队列架构。

Queue模块还自带了PriorityQueue（带有优先级）和LifoQueue（后进先出）2种特殊队列。我们这里展示下线程安全的优先级队列的用法，
PriorityQueue要求我们put的数据的格式是(priority_number, data)，我们看看下面的例子：
```python
import time
import threading
from random import randint
from Queue import PriorityQueue
q = PriorityQueue()

def double(n):
    return n * 2
    
def producer():
    count = 0
    while 1:
        if count > 5:
            break
        pri = randint(0, 100)
        print 'put :{}'.format(pri)
        q.put((pri, double, pri))  # (priority, func, args)
        count += 1
        
def consumer():
    while 1:
        if q.empty():
            break
        pri, task, arg = q.get()
        print '[PRI:{}] {} * 2 = {}'.format(pri, arg, task(arg))
        q.task_done()
        time.sleep(0.1)
        
t = threading.Thread(target=producer)
t.start()
time.sleep(1)
t = threading.Thread(target=consumer)
t.start()
```
其中消费者是故意让它执行的比生产者慢很多，为了节省篇幅，只随机产生5次随机结果。我们看下执行的效果：
```shell
❯ python priority_queue.py
put :84
put :86
put :16
put :93
put :14
put :93
[PRI:14] 14 * 2 = 28
[PRI:16] 16 * 2 = 32
[PRI:84] 84 * 2 = 168
[PRI:86] 86 * 2 = 172
[PRI:93] 93 * 2 = 186
[PRI:93] 93 * 2 = 186
```
可以看到put时的数字是随机的，但是get的时候先从优先级更高（数字小表示优先级高）开始获取的。
### 线程池
面向对象开发中，大家知道创建和销毁对象是很费时间的，因为创建一个对象要获取内存资源或者其它更多资源。无节制的创建和销毁线程是一种极大的浪费。那我们可不可以把执行完任务的线程不销毁而重复利用呢？仿佛就是把这些线程放进一个池子，一方面我们可以控制同时工作的线程数量，一方面也避免了创建和销毁产生的开销。

线程池在标准库中其实是有体现的，只是在官方文章中基本没有被提及：
```shell
In : from multiprocessing.dummy import Pool as ThreadPool
In : pool = ThreadPool(5)
In : pool.map(lambda x: x**2, range(5))
Out: [0, 1, 4, 9, 16]
```
当然我们也可以自己实现一个：
```python
# coding=utf-8
import time
import threading
from random import random
from Queue import Queue

def double(n):
    return n * 2
    
class Worker(threading.Thread):
    def __init__(self, queue):
        super(Worker, self).__init__()
        self._q = queue
        self.daemon = True
        self.start()
        
    def run(self):
        while 1:
            f, args, kwargs = self._q.get()
            try:
                print 'USE: {}'.format(self.name)  # 线程名字
                print f(*args, **kwargs)
            except Exception as e:
                print e
            self._q.task_done()
            
class ThreadPool(object):
    def __init__(self, num_t=5):
        self._q = Queue(num_t)
        # Create Worker Thread
        for _ in range(num_t):
            Worker(self._q)
            
    def add_task(self, f, *args, **kwargs):
        self._q.put((f, args, kwargs))
        
    def wait_complete(self):
        self._q.join()
        
pool = ThreadPool()

for _ in range(8):
    wt = random()
    pool.add_task(double, wt)
    time.sleep(wt)
    
pool.wait_complete()
```
执行一下:
```shell
USE: Thread-1
1.58762376489
USE: Thread-2
0.0652918738849
USE: Thread-3
0.997407997138
USE: Thread-4
1.69333900685
USE: Thread-5
0.726900613676
USE: Thread-1
1.69110052253
USE: Thread-2
1.89039743989
USE: Thread-3
0.96281118122
```
线程池会保证同时提供5个线程工作，但是我们有8个待完成的任务，可以看到线程按顺序被循环利用了。

### 

### ThreadLocal
当不想将变量共享给其他线程时，可以使用局部变量，但在函数中定义局部变量会使得在函数之间传递特别麻烦。ThreadLocal是非常牛逼的东西，它解决了全局变量需要枷锁，局部变量传递麻烦的两个问题。通过在线程中定义：
local_school = threading.local()
此时这个local_school就变成了一个全局变量，但这个全局变量只在该线程中为全局变量，对于其他线程来说是局部变量，别的线程不可更改。 def process_thread(name):# 绑定ThreadLocal的student: local_school.student = name

这个student属性只有本线程可以修改，别的线程不可以。代码：
```python
local = threading.local()
def func(name):
    print 'current thread:%s' % threading.currentThread().name
    local.name = name
    print "%s in %s" % (local.name,threading.currentThread().name)
    
t1 = threading.Thread(target=func,args=('haibo',))
t2 = threading.Thread(target=func,args=('lina',))

t1.start()
t2.start()
t1.join()
t2.join()
```
从代码中也可以看到，可以将ThreadLocal理解成一个dict,可以绑定不同变量。
ThreadLocal用的最多的地方就是每一个线程处理一个HTTP请求，在Flask框架中利用的就是该原理，它使用的是基于Werkzeug的LocalStack。
end！！！