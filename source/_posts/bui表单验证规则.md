original: false
title: bui表单验证规则
tags:
  - bui
  - jquery
  - js
  - 前端
id: 122
categories:
  - 杂谈
date: 2015-05-08 12:38:41
---
做离石啦项目时整理了下阿里的bui使用规则。

<!--more-->

```
label>正则表达式：</label>

<input name="j" data-messages="{regexp:'不是有效的数字'}" data-rules="{regexp:/^\d+$/}" type="text">



var Form = BUI.Form;



      new Form.Form({

        srcNode : '#J_Form'

      }).render();

<input name="b"  type="text" data-tip="{text:'请填写内容！',iconCls:'icon-ok'}" />



data-tip="{text:'请填写内容！'}"

data-rules="{required:true}"

{required:true,sid:5} 必填 并且为5位

{number:true} 必须为数字

{max:100} 最大值为100

<label>最小值：</label><input name="c" data-rules="{min:10}" type="text">

<label>最小长度：</label><input name="d" data-rules="{minlength:5}" type="text">

<label>最大长度：</label><input name="e" data-rules="{maxlength:5}" type="text">



修改默认提示信息

data-rules="{required:true}" data-messages="{required:'修改默认提示信息 '}"



<label>第一次输入：</label><input id="f1" name="f1" type="text"><br/>

<label>第二次输入：</label><input name="f2" data-rules="{equalTo:'#f1'}" type="text">



<label>日期值：</label><input class="calendar" name="h" data-rules="{date:true}" type="text">

<label>邮箱值：</label><input name="i" data-rules="{email:true}" type="text">    

<label>最小日期：</label><input class="calendar" name="k" data-rules="{minDate:'2014-01-01'}" type="text">

<label>最大日期：</label><input class="calendar" name="l" data-rules="{maxDate:'2012-01-01'}" type="text">

必须选择

<select data-rules="{required:true}">

  <option value="">-请选择-</option>

  <option value="其他">其他</option>

</select>



表单默认值：placeholder  

<input type="text" class="span1 span-width control-text" placeholder="span1">



文本框 宽度 样式

<select class="input-small"><option>input-small</option></select>

<select class="input-normal"><option>input-normal</option></select>

<select class="input-large"><option>input-large</option></select>



调整 高度

controls control-row1 到 controls control-row9



调整 table 表单 高度

<form action="{:U('userchuli/adduserhandle')}" method="post" name="form1" id="J_Form" class="form-horizontal">

<form action="{:U('userchuli/adduserhandle')}" method="post" name="form1" id="J_Form" class="form-horizontal well">

<form action="{:U('userchuli/adduserhandle')}" method="post" name="form1" id="J_Form" class="form-horizontal span20  well">



红色 标注 必填

<label class="control-label"><s>*</s>供应商编码：</label>



最小日期：

<p>

<label>最小日期：</label><input class="calendar" name="k" data-rules="{minDate:'2014-01-01'}" type="text">

</p>



最大日期：

<p>

<label>最大日期：</label><input class="input-small calendar" name="l" data-rules="{maxDate:'2012-01-01'}" type="text">

</p>

加载日历 控件

<!-- script start-->  

    <script type="text/javascript">

          var Calendar = BUI.Calendar

          var datepicker = new Calendar.DatePicker({

            trigger:'.calendar',

            showTime:true, // 显示 小时 分钟 默认不显示时间

            lockTime : { //可以锁定时间，hour,minute,second

              //hour : 12,

              minute:30,

              second : 30

            },

            maxDate : '2014-01-01', // 最大日期限制

            minDate : '2013-7-25', //  最小日期限制

            autoRender : true

          });

    </script>

<!-- script end -->



<!-- script start-->  

    <script type="text/javascript">

          var Calendar = BUI.Calendar

          var datepicker = new Calendar.DatePicker({

            trigger:'.calendar',

            autoRender : true

          });

    </script>

<!-- script end -->

列表元素

<div class="demo-content">

<div >

  <ul id="list1"  class="bui-select-list">

    <li data-value="1">选项一</li>

    <li data-value="2">选项二</li>

    <li data-value="3">选项三</li>

  </ul>

</div>



按钮组

<div class="button-group" style="margin: 9px 0;">

      <button class="button">Left</button>

      <button class="button">Middle</button>

      <button class="button">Right</button>

</div>



相关css

.pull-right{float: right;}   右浮动

.pull-left{float: left;}   左浮动

.pull-none{float: none;}   无浮动

.hide{display: none;}  隐藏元素

.show{display: block;}   显示元素

.invisible{visibility: hidden;}  占位隐藏

.bordered{border:1px solid @borderColor;.border-radius(@radius);}  设置圆角边框

.centered{text-align:center;}  元素居中



展开、收起 元素

<button id="btn" class="button button-small">展开/折叠</button>

<button id="btn3"  class="button button-small">清空数据</button>

<form id="J_Form" class="form-horizontal" data-depends="{'#btn:click':['toggle'],'#btn3:click':['clearFields']}">



启用、禁用 元素

<button id="btn1"  class="button button-small">禁用分组</button>

<button id="btn2"  class="button button-small">可用分组</button>

<div id="range" class="controls bui-form-group" data-depends="{'#btn1:click':['disable'],'#btn2:click':['enable']}">

<input name="start" class="calendar" type="text"><label> - </label><input name="end" class="calendar" type="text">

</div>



下拉多选

<div class="controls bui-form-field-select" data-items="{'1':'游泳','2':'跑步','3':'爬山'}" data-select="{multipleSelect:true}">

<input name="love" type="hidden" value="1,2">

</div>



<p>

  正常文本<span class="auxiliary-text">通篇辅助型中文</span>

</p>



批量删除的垃圾桶图标向上偏移得厉害。用 vertical-align: text-bottom 比较好



信息提示:

<div class="span8 well">

          <p id="t2" style="margin-bottom: 0;">Tight pants next level keffiyeh <a href="#" title="Default tooltip">you probably</a>

          </p>

        </div>

var tips2 = new Tooltip.Tips({

        tip : {

          trigger : '#t2 a', //出现此样式的元素显示tip

          alignType : 'top', //默认方向

          elCls : 'tips  tips-notice',

          titleTpl : '<span class="x-icon x-icon-small x-icon-warning"><i class="icon icon-white icon-volume-up"></i></span><div class="tips-content">{title}</div>',

          offset : 10 //距离左边的距离

        }

      });

tips2.render();



//--------------

利用.table-striped可以给<tbody>之内的每一样增加斑马条纹样式。

利用.table-bordered为表格和其中的每个单元格增加边框。

利用.table-hover可以让<tbody>中的每一行响应鼠标悬停状态。

利用.table-condensed可以让表格更加紧凑，单元格中的内部（padding）均会减半。

将任何.table包裹在.table-responsive中即可创建响应式表格，其会在小屏幕设备上（小于768px）水平滚动。当屏幕大于768px宽度时，水平滚动条消失。



// 使用thinkphp  接收 中文 参数时, I 不需要过滤 I('参数','默认值','空:不过滤');

//js 不缓存

<script src="/Public/js/tm/function.js?randomId=<?php echo date('YmdHis');?>.js"></script>



html_entity_decode  html 实体化

strip_tags 函数可以方便地去除 HTML 标签。



EQ 等于（=） equal

NEQ 不等于（<>） not equal

GT 大于（>） greater

EGT 大于等于（>=） equal or greater

LT 小于（<） less than

ELT 小于等于（<=） equal or less than



----------------------

ctrl+d 选词

ctrl+alt+↑ 批量选择

ctrl+shift+a 以等号整理代码

ctrl+j 合并一行

ctrl+p 搜索文件

ctrl+r 定位方法



// jquery 异步上传

var aQuery = $("#T_form").serializeArray();



//alert(aQuery);



$.post("/plan/chuli/jhtj",aQuery,function(data){



alert(data);



});



======================================================

strstr 显示第一次找到，要查找的字符串，以及后面的字符串。

strrchr 显示最后一次找到，要查找的字符串，以及后面的字符串。



$email = 'test@test.com@jb51.net';

$domain = strstr($email, '@');

echo "strstr 测试结果 $domain<br>";

$domain = strrchr($email, '@');

echo "strrchr 测试结果 $domain<br>";



结果如下：



strstr 测试结果 @test.com@jb51.net

strrchr 测试结果 @jb51.net

================================================================

strstr是大小写敏感的。

stristr是大小写不敏感的。



复制代码 代码如下:

<?php

$email = 'zhangYing@jb51.net';

$domain = strstr($email, 'y');

echo "strstr 测试结果 $domain<br>";

$domain = stristr($email, 'y');

echo "stristr 测试结果 $domain<br>";

?>



结果如下：



strstr 测试结果 jb51.net

stristr 测试结果 Ying@jb51.net



=============================================================

strstr 是匹配后截取。

substr 是不匹配，根据起始位置，进行截取。



复制代码 代码如下:

<?php

$email = 'zhangYing@jb51.net';

$domain = strstr($email, 'y');

echo "strstr 测试结果 $domain<br>";

$domain = substr($email,-7);

echo "substr 测试结果 $domain<br>";

?>

结果如下:

strstr 测试结果 jb51.net

substr 测试结果 jb51.net

```
