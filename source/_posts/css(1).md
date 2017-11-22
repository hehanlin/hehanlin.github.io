title: css(一)
author: hanlin
tags: []
categories: []
date: 2016-01-12 09:34:00
---
### **1.为文档添加样式的三种方法**

<!--more-->

1. 行内样式
2. 嵌入样式
3. 外联样式

>  	@import url('')
	@import指令必须出现在样式表中其他样式之前,否则不会加载

### **2.结构**

![](http://liqiong520-hexo.stor.sinaapp.com/img%2Fcss_struct.png)

### **3.选择符**

##### **上下文选择符**
一般(祖先/后代选择符): 
`p em{font-weight: bold;}`
特殊: 
* 子选择符: `p>em{font-weight: bold;}`
* 紧邻同胞选择符**+** `h2+p{font-voriant: small-caps;}`
* 一般同胞选择符**~** `h2~a{color: red;}`
* 通用选择符***** `*{color: green;}`

##### **ID和类选择符**
* 类选择符
    格式: `.container{font-face: 'arival';}`
* 标签带类选择符
    格式: `p.specialtext{color: red;}`(中间没有空格)
* 多类选择符
    格式: `.specialtext.featured{font-size: 120%;}`(同上)
* ID同class

##### **属性选择符**
* 属性名选择符
    `input[type]{border: 2px solid blue;}`
* 属性值选择符
    `img[title="red"]{border: 4px solid green;}`

### **4.伪类**
##### **UI伪类**
* 链接伪类(LoVe,HA)
    `a:link{color: black;}`
    `a:visited{color: gray;}`
    `a:hover{background: green;}`
    `a:active{color: red;}`
* :focus伪类
    `input:focus{border: 1px solid blue;}`
* :target伪类
    `#more_info:target{background: #eee;}`
    会在用户单击链接转向ID为more_info的元素时,为该元素添加浅灰色背景.

##### **结构化伪类**
* :first-child和:last-child
* :nth-child(n)
    n可为数值,表达式,odd和even

### **5.伪元素**
1. ::first-letter伪元素 (选择首字符)
2. ::first-line伪元素 (选择首行)
3. ::before和::after伪元素
    可用于在特定元素前后添加特殊内容.