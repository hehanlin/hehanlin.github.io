title: python--元类实现orm
author: hanlin
tags:
  - python
categories: []
date: 2016-09-21 07:38:00
---
准备工作，创建一个Field类
```
class Field(object):
 
    def __init__(self, name, column_type):
        self.name = name
        self.column_type = column_type
 
    def __str__(self):
        return '<%s:%s>' % (self.__class__.__name__, self.name)
```
<!--more-->
它的作用是
在Field类实例化时将得到两个参数，name和column_type，它们将被绑定为Field的私有属性，如果要将Field转化为字符串时，将返回“Field:XXX” ， XXX是传入的name名称。

准备工作：创建StringField和IntergerField
```
class StringField(Field):
 
    def __init__(self, name):
        super(StringField, self).__init__(name, 'varchar(100)')
 
class IntegerField(Field):
 
    def __init__(self, name):
        super(IntegerField, self).__init__(name, 'bigint')
```
它的作用是
在StringField,IntegerField实例初始化时，时自动调用父类的初始化方式。

### 道生一
```
class ModelMetaclass(type):

    def __new__(cls, name, bases, attrs):
        if name=='Model':
            return type.__new__(cls, name, bases, attrs)
        print('Found model: %s' % name)
        mappings = dict()
        for k, v in attrs.items():
            if isinstance(v, Field):
                print('Found mapping: %s ==> %s' % (k, v))
                mappings[k] = v
        for k in mappings.keys():
            attrs.pop(k)
        attrs['__mappings__'] = mappings # 保存属性和列的映射关系
        attrs['__table__'] = name # 假设表名和类名一致
        return type.__new__(cls, name, bases, attrs)
```
它做了以下几件事

1. 创建一个新的字典mapping
2 .将每一个类的属性，通过.items()遍历其键值对。如果值是Field类，则打印键值，并将这一对键值绑定到mapping字典上。
3. 将刚刚传入值为Field类的属性删除。
4. 创建一个专门的__mappings__属性，保存字典mapping。
5. 创建一个专门的__table__属性，保存传入的类的名称。

### 一生二
```
class Model(dict, metaclass=ModelMetaclass):

    def __init__(self, **kwarg):
        super(Model, self).__init__(**kwarg)

    def __getattr__(self, key):
        try:
            return self[key]
        except KeyError:
            raise AttributeError("'Model' object has no attribute '%s'" % key)

    def __setattr__(self, key, value):
        self[key] = value

    # 模拟建表操作
    def save(self):
        fields = []
        args = []
        for k, v in self.__mappings__.items():
            fields.append(v.name)
            args.append(getattr(self, k, None))
        sql = 'insert into %s (%s) values (%s)' % (self.__table__, ','.join(fields), ','.join([str(i) for i in args]))
        print('SQL: %s' % sql)
        print('ARGS: %s' % str(args))
```
如果从Model创建一个子类User：
```
class User(Model):
    # 定义类的属性到列的映射：
    id = IntegerField('id')
    name = StringField('username')
    email = StringField('email')
    password = StringField('password')
```
这时
id= IntegerField(‘id’)就会自动解析为：

Model.__setattr__(self, ‘id’, IntegerField(‘id’))

因为IntergerField(‘id’)是Field的子类的实例，自动触发元类的__new__，所以将IntergerField(‘id’)存入__mappings__并删除这个键值对。
### 二生三、三生万物
当你初始化一个实例的时候并调用save()方法时候
```
u = User(id=12345, name='Batman', email='batman@nasa.org', password='iamback')
u.save()
```
这时先完成了二生三的过程：

1. 先调用Model.__setattr__，将键值载入私有对象
2. 然后调用元类的“天赋”，ModelMetaclass.__new__，将Model中的私有对象，只要是Field的实例，都自动存入u.__mappings__。

接下来完成了三生万物的过程：

通过u.save()模拟数据库存入操作。这里我们仅仅做了一下遍历__mappings__操作，虚拟了sql并打印，在现实情况下是通过输入sql语句与数据库来运行。

输出结果为
```
Found model: User
Found mapping: name ==> <StringField:username>
Found mapping: password ==> <StringField:password>
Found mapping: id ==> <IntegerField:id>
Found mapping: email ==> <StringField:email>
SQL: insert into User (username,password,id,email) values (Batman,iamback,12345,batman@nasa.org)
ARGS: ['Batman', 'iamback', 12345, 'batman@nasa.org']
```
end！！！