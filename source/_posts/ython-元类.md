title: python--元类
author: hanlin
tags: []
categories: []
date: 2016-09-15 15:45:00
---
### 什么是元类？

理解元类（metaclass）之前，我们先了解下Python中的OOP和类（Class）。

面向对象全称 Object Oriented Programming 简称OOP，这种编程思想被大家所熟知。它是把对象作为一个程序的基本单元，把数据和功能封装在里面，能够实现很好的复用性，灵活性和扩展性。OOP中有2个基本概念：类和对象：

1. 类是描述如何创建一个对象的代码段，用来描述具有相同的属性和方法的对象的集合，它定义了该集合中每个对象所共有的属性和方法
2. 对象是类的实例（Instance）。我们举个例子：
```
In : class ObjectCreator(object):
...:     pass
...:
In : my_object = ObjectCreator()
In : my_object
Out: <__main__.ObjectCreator at 0x1082bbef0>
```
而Python中的类并不是仅限于此：
```
In : print(ObjectCreator)
<class '__main__.ObjectCreator'>
```
ObjectCreator竟然可以被print，所以它的类也是对象！既然类是对象，你就能动态地创建它们，就像创建任何对象那样。我在日常工作里面就会有这种动态创建类的需求，比如在mock数据的时候，现在有个函数func接收一个参数：
```
In : def func(instance):
...:     print(instance.a, instance.b)
...:     print(instance.method_a(10))
...:
```
正常使用起来传入的instance是符合需求的（有a、b属性和method_a方法），但是当我想单独调试func的时候，需要「造」一个，假如不用元类，应该是这样写:
```
In : def generate_cls(a, b):
...:     class Fake(object):
...:         def method_a(self, n):
...:             return n
...:     Fake.a = a
...:     Fake.b = b
...:     return Fake
...:
In : ins = generate_cls(1, 2)()
In : ins.a, ins.b, ins.method_a(10)
Out: (1, 2, 10)
```
你会发现这不算算是「动态创建」的：

1. 类名（Fake）不方便改变
2. 要创建的类需要的属性和方法越多，就要对应的加码，不灵活。
我平时怎么做呢：
```
In : def method_a(self, n):
...:     return n
...: 
In : ins = type('Fake', (), {'a': 1, 'b': 2, 'method_a': method_a})()
In : ins.a, ins.b, ins.method_a(10)
Out: (1, 2, 10)
```
到了这里，引出了type函数。本来它用来能让你了解一个对象的类型：
```
In : type(1)
Out: int
In : type('1')
Out: str
In : type(ObjectCreator)
Out: type
In : type(ObjectCreator())
Out: __main__.ObjectCreator
```
另外，type如上所说还可以动态地创建类：type可以把对于类的描述作为参数，并返回一个类。

```	
MyClass = type('MyClass', (), {})
```
这种用法就是由于type实际上是一个元类，作为元类的type在Python中被用于在后台创建所有的类。在Python语言上有个说法「Everything is an object」。包整数、字符串、函数和类… 所有这些都是对象。所有这些都是由一个类创建的：
```
In : age = 35
In : age.__class__
Out: int
In : name = 'bob'
In : name.__class__
Out: str
...
```
现在，任何__class__中的特定__class__是什么？
```
In : age.__class__.__class__
Out: type
In : name.__class__.__class__
Out: type
...
```
如果你愿意，你可以把type称为「类工厂」。type是Python中内建元类，当然，你也可以创建你自己的元类。

### 创建自己的元类

Python2创建类的时候，可以添加一个__metaclass__属性：
```
class Foo(object):
    __metaclass__ = something...
    [...]
```
如果你这样做，Python会使用元类来创建Foo这个类。Python会在类定义中寻找__metaclass__。如果找到它，Python会用它来创建对象类Foo。如果没有找到它，Python将使用type来创建这个类。

在Python3中语法改变了一下：
```
class Simple1(object, metaclass=something...):
    [...]
```
本质是一样的
```
class HelloMeta(type):
    def __new__(cls, name, bases, attrs):
        def __init__(self, func):
            self.func = func
        def hello(self):
            print 'hello world'
        t = type.__new__(cls, name, bases, attrs)
        t.__init__ = __init__
        t.hello = hello
        return t
        
class New_Hello(object):
    __metaclass__ = HelloMeta
```
New_Hello初始化需要添加一个参数，并包含一个叫做hello的方法：
```
In : h = New_Hello(lambda x: x)
In : h.func(10), h.hello()
hello world
Out: (10, None)
```
PS: 这个例子只能运行于Python2。

在Python里__new__方法创建实例，__init__负责初始化一个实例。对于type也是一样的效果，只不过针对的是「类」，在上面的HelloMeta中只使用了__new__创建类，我们再感受一个使用__init__的元类：
```
In : class HelloMeta2(type):
...:     def __init__(cls, name, bases, attrs):
...:         super(HelloMeta2, cls).__init__(name, bases, attrs)
...:         attrs_ = {}
...:         for k, v in attrs.items():
...:             if not k.startswith('__'):
...:                 attrs_[k] = v
...:         setattr(cls, '_new_dict', attrs_)
...:
...:
```
别往下看。思考下这样创建出来的类有什么特殊的地方？

我揭晓一下（这次使用Python 3语法）：
```
In : class New_Hello2(metaclass=HelloMeta2):
...:     a = 1
...:     b = True
In : New_Hello2._new_dict
Out: {'a': 1, 'b': True}
In : h2 = New_Hello2()
In : h2._new_dict
Out: {'a': 1, 'b': True}
```
有点明白么？其实就是在创建类的时候把类的属性循环了一遍把不是__开头的属性最后存在了_new_dict上。
### 什么时候需要用元类？
日常的业务逻辑开发是不太需要使用到元类的，因为元类是用来拦截和修改类的创建的，用到的场景很少。我能想到最典型的场景就是 ORM。ORM就是「对象 关系 映射」的意思，简单的理解就是把关系数据库的一张表映射成一个类，一行记录映射为一个对象。ORM框架中的Model只能动态定义，因为这个模式下这些关系只能是由使用者来定义，元类再配合描述符就可以实现ORM了，现在做个预告，未来我会分享「如何写一个ORM」这个主题。
