title: 6月面php开发常见题总结
author: hanlin
tags: []
categories: []
date: 2016-06-16 12:36:00
---

1. php是什么？

  php，超文本处理语言，我个人觉得php是为处理http报文而出现的.下为详细：

  (1). 它实现了日常开发中最常用的数据结构及操作函数（诸如字符串，栈，队列，hash等），并保持变量弱类型的灵活，处理垃圾回收。屏蔽了大部分的细节。

  (2). 它将http报文及服务器端的许多重要信息（诸如url,get参数，post参数，cookie,session，用户浏览器信息，服务器信息等）封装成了便于php层开发者操作的数据结构和函数，使得上手及开发速度提升。

  (3). 内部实现了大量操作文件，日期，字符编码，json，xml等函数。

  (4). 对外提供扩展接口，一大批实用的扩展应运而生，phper操作数据库，缓存，处理图片等任务变得简单。

1. 有多少种方法在HTML页面嵌入PHP代码？

  使用标记嵌入，&lt;?php ?&gt;或者短标记&lt;?  ?&gt;。

1. php.ini的作用是什么？

  php.ini是php的配置文件：

  (1). 更改自带功能的配置，比如更改是否显示错误(display\_errors)，更改错误级别(error\_reporting)，输出错误日志(log\_errors)，更改错误日志位置(error\_log)，脚本最大执行时间(max\_execution\_time)，session存储方式及位置，时区，语言，默认编码，禁用函数(disable\_functions)，类(disable\_classes)，上传文件大小等.

  (2). 载入其他扩展，更改其他模块的配置，比如是否允许mysql持久连接(max\_links)，更改扩展的载入路径等。

1. php是区分大小写的语言吗？

  (1).php变量名

    (包括$\_GET,$\_POST,$\_REQUEST, $\_COOKIE,$\_SESSION,$\_SERVER,$\_FILES,$\_ENV,$GLOBALS这些)，常量名区分大小写。

  (2). php函数名，方法名，类名不区分大小写。

  (3). 魔术常量\_\_LINE\_\_，\_\_FILE\_\_，\_\_DIR\_\_, \_\_FUNCTION\_\_, \_\_CLASS\_\_, \_\_METHOD\_\_, \_\_NAMESPACE\_\_不区分大小写。

  (4). NULL，TRUE，FALSE不区分大小写。

  (5). 类型转换int,double,bool,string,array,object不区分大小写。

  (6). windows下包含文件不区分大小写,linux下区分大小写。

1. PHP预定义常量有哪些？

  (1). 魔术常量\_\_LINE\_\_，\_\_FILE\_\_，\_\_DIR\_\_, \_\_FUNCTION\_\_, \_\_CLASS\_\_, \_\_METHOD\_\_, \_\_NAMESPACE\_\_.

  (2). 真假值TRUE,FALSE.

  (3). 其他常用常量（php核心常量，标准预定义常量）

 PHP\_VERSION,PHP\_OS,PHP\_EOL,E\_WARNING,E\_ERROR,E\_PARSE,E\_NOTICE,LOCK\_EX(独占锁写锁),LOCK\_UN(释放锁),LOCK\_SH(共享锁读锁)，LOCK\_NB(不希望锁定是阻塞)。

1. php变量类型有哪些？

  (1). NULL

  (2). int, double, bool, string

  (3). array, object

  (4). Resource

  (5). callback

1. php变量命名规则是什么？

  $ 打头，可以是字母，数字，下划线，但不能以数字开头。

  一般遵循驼峰法或者下划线分割法。

1. NULL是什么？

  一般指空指针常量，php中为一种数据类型，表示空值。不区分大小写，NULL需注意以下几点：

  1. 如果变量未赋值，被unset(),被显式赋值为NULL，则该变量为NULL。

  2. NULL==0,NULL==false, NULL==&#39;&#39; 均为真，但===为假。(&#39;0&#39;不一样）

  3. 对于is\_null(),只有是NULL值(包括未被赋值的变量)才会为TRUE，其他为FALSE。

1. php预定义常量有哪些？

  (1). 魔术常量\_\_LINE\_\_，\_\_FILE\_\_，\_\_DIR\_\_, \_\_FUNCTION\_\_, \_\_CLASS\_\_, \_\_METHOD\_\_, \_\_NAMESPACE\_\_.

  (2). 真假值TRUE,FALSE.

  (3). 其他常用常量（php核心常量，标准预定义常量）

 PHP\_VERSION,PHP\_OS,PHP\_EOL,E\_WARNING,E\_ERROR,E\_PARSE,E\_NOTICE,LOCK\_EX(独占锁写锁),LOCK\_UN(释放锁),LOCK\_SH(共享锁读锁)，LOCK\_NB(不希望锁定是阻塞)。

1. php怎么连接两个字符串？

  (1).  $str3 = $str1.$str2;

  (2).  $str = &#39;hello&#39;;

       $str .=  &#39;world&#39;;

1. php怎么判断一个字符串长度？

  (1). 对于纯英文字符，直接用strlen()判断。

  (2). 对于含有诸如中文字符，应使用mb\_strlen($str,&#39;字符编码&#39;)。(需要mb\_string扩展)

1. php怎样判断一个字符串是否包含在另一个字符串中？

  (1). 对于纯英文字符，直接用strpos()判断。

  (2). 对于含有诸如中文字符：

      $str1 = iconv(&#39;GBK, &#39;UTF-8&#39; ,&#39;中文&#39;)；//当不知道字符串编码时使用mb\_convert\_encoding( &#39;中文&#39;, &#39;UTF-8&#39;, &#39;auto&#39;)可以自动识别编码

      $str2 = iconv(&#39;GBK&#39;, &#39;UTF-8&#39; ,&quot;中&quot;);

      if( mb\_strpos($str1, $str2) !== false  ) {

//说明包含关系

     }

1. php怎么获取用户使用的浏览器？

   通过判断$\_SERVER[&#39;HTTP\_USER\_AGENT&#39;]可以判断用户浏览器信息。下为详细：

   function browserInfo() {

     $userAgent = $\_SERVER[&#39;HTTP\_USER\_AGENT&#39;];

 $browserName = &#39;&#39;;

 $browserVersion = &#39;&#39;;

 $temp = array();

 If(ereg(&quot;MSIE([0-9].[0-9]{1,2})&quot;, $userAgent, $temp)) {

$browserVersion = $temp[1];

$browserName = &quot;IE&quot;;

 } else if(ereg(&quot;Opera/([0-9]{1,2}.[0-9]{1,2})&quot;, $userAgent, $temp)) {

$browserVersion = $temp[1];

$browserName = &quot;Opera&quot;;

 } else if(ereg(&quot;Firefox/([0-9.]{1,5}))&quot;, $userAgent, $temp)) {

$browserVersion = $temp[1];

    $browserName = &quot;Firefox&quot;;

 } else if(ereg(&quot;Chrome/([0-9.]{1,3})&quot;, $userAgent, $temp)) {

$browserVersion = $temp[1];

    $browserName = &quot;Chrome&quot;;

 } else if(ereg(&quot;Safari/([0-9.]{1,3})&quot;, $userAgent, $temp)) {

$browserVersion = $temp[1];

    $browserName = &quot;Safari&quot;;

 } else {

$browserVersion = &quot;&quot;;

    $browserName = &quot;Unknown&quot;;

 }

 return $browserName . &quot;&quot; . $browserVersion;

   }

1. php怎么获取随机数？

   通常使用mt\_rand()函数

   echo mt\_rand(10,100)

1. php怎么重定向页面？

   (1). 使用header函数重定向，使用时前面不能有任何输出，及session，cookie设置，手动开启缓冲区除外。

       &lt;?php

       Header(&quot;location: [http://www.xxx.com](./../)%3B) [&quot;](./../)%3B) [);](./../)%3B)

   (2). 使用html meta标签跳转

       &lt;?php

       $url = &quot;www.xxx.com&quot;;

       Echo &quot;&lt;meta htto-equiv=\&quot;refresh\&quot; content=\&quot;0;url=$url\&quot;&gt;&quot;;

   (3). 使用js跳转

       &lt;?php

       $url = &quot;www.xxx.com&quot;;

      Echo &quot;&lt;script type=\&quot;text/javascript\&quot;&gt;&quot;;

      Echo &quot;location.href=\&quot;$url\&quot;&quot;;

      Echo &quot;&lt;/script&gt;&quot;;

1. 怎么显示文件下载对话框？

   通过header函数改变Content-type来显示文件下载对话框，如果需要隐藏文件真实地址，可以先读取到内存，再传给客户端。下为详细：

   Function showDownload($file\_path) {

     If(!file\_exists($file\_path)) {

        echo &quot;file not found&quot;;

        exit;

     }else {

        $file = fopen($file\_path,&quot;r&quot;);

header(&quot;Content-type: application/octet-stream&quot;);

header(&quot;Accept-Length: filesize($file\_path)&quot;);

header(&quot;Content-Disposition: attachment; filename=$file\_path&quot;);

echo fread($file,filesize($file\_path));

fclose($file);

exit;

     }

  }

1. php怎样获取通过GET,POST发送的信息？

$\_GET，$\_POST, $\_REQUEST

一般情况下要检测下key值是否合法，比如：

$test = isset($\_GET[&#39;test&#39;]) ? $\_GET[&#39;test&#39;] : &#39;&#39;;

1. php的$\_REQUEST变量包含哪些获取信息的方法？

$\_REQUEST变量中默认包含了$\_GET,$\_POST,$\_COOKIE的数组，如果key相同，则遵循php.ini中request\_order=&quot;GPC&quot;的设置覆盖，默认后者会覆盖前者。

1. php怎样创建一个数组？

$arr = array(&#39;k&#39;=&gt;&#39;v&#39;);

$arr = [&#39;k&#39;=&gt;&#39;v&#39;]; //5.4开始

1. php怎样对数组进行排序?

(1). 对数字，字母简单顺序排列用sort($arr),倒序排列用rsort($arr).会删除原有的key.

(2). 根据key顺序排列用ksort($arr),倒序排列用krsort($arr).保留原有的key.

(3). 根据value顺序排列用asort($arr),倒序排列用asort($arr).保留原有的key.

(4). 以上均会改变原数组，以上函数有第二个可选参数sort\_flags，分别是：

    SORT\_REGULAR，SORT\_NUMERIC, SORT\_STRING, SORT\_LOCALE\_STRING.

1. php单引号字符串与双引号字符串的区别是什么？

(1). 一般两者通用，但是双引号内部变量会解析，单引号中则不解析。所以内部是纯字符串的时候用单引号（速度快一点）。

(2). 有的时候需要用php生成文本文件，最好用双引号，单引号会把\n直接当字符输出。

(3). 最好html中尽量双引号，这样如果需要拷贝大段的html代码到php中，只需在两头加单引号就ok。

1. php如何包含另一个php文件？

(1). include(),include\_once()函数如果有错误报警告，脚本继续执行。Include\_once()会检测该文件是否已包含过，如果包含过则不会再次包含。

(1). require(),require\_once()函数如果有错误报致命错误，脚本停止执行。require\_once()会检测该文件是否已包含过，如果包含过则不会再次包含。

1. php include()函数和require()函数的区别是什么？

   (1). require()函数执行发生在php脚本执行前段，该语句会被最终替换为要包含的内容，有错误停止脚本执行。

   (2). Include()函数执行发生在该行代码执行时，有错误继续执行。

   (3). require()是不会受到条件判断约束的，如果需要循环一组文件包含或者通过条件判断包含，则需要用include().

1. php怎样以只读模式打开一个文件？

   将fopen设置的第二参数设置为&quot;r&quot;,file\_get\_contents()也可以。

   $file = fopen($file\_path,&#39;r&#39;);

   echo fread($file,filesize($file\_path));

   fclose($file);

1. php怎样获取一个文件的大小？

   利用filesize()函数来获取，而对于是远程文件，可以使用get\_headers()函数来获取文件大小。

   function \_getFileSize($file\_path, $type = 1 ) {

       $size = false;

       if($type === 1) {

$size = @filesize(&quot;$file\_path&quot;);

       } else {

            $header\_arr = get\_headers($url,true);

            $size = $header\_arr[&#39;Content-type&#39;];

       }

       return $size;

   }

1. php怎么判断一个文件是否存在？

对于本地文件利用file\_exists()来获取，远程文件依旧使用get\_headers()函数。

详细如下：

 function \_fileExists($file\_path, $type = 1 ) {

       $flag = false;

       if($type === 1) {

$flag = file\_exists(&quot;$file\_path&quot;);

       } else {

            $flag = (bool)get\_headers($url,true);

       }

       return $flag;

   }

1. php怎样设置和获取cookie?

(1).设置cookie

   1. 可以使用setcookie()函数来设置cookie，依次需要以下参数(第一个为必选)：

      name: cookie名称，value: 值, expire: 过期时间(时间戳)，path：服务端有效路径(默认为/), domain: cookie有效域名。

      setcookie(&#39;key&#39;,&#39;value&#39;,time()+3600\*24\*7,&#39;/&#39;,&#39;xxx.com&#39;);

      setcookie前不能有任何输出(除非设置缓冲区),setcookie()后，当前页输出刚刚设置的cookie不会输出结果。

1. (2). 获取cookie

       $name  = isset($\_COOKIE[&#39;name&#39;]) ? $\_COOKIE[&#39;name&#39;] : &#39;&#39;;

1. php怎样检测一个变量是否设置？

使用isset()函数

29. php怎样发送邮件？

  (1). 使用mail()函数(需要smtp服务器)  (2). 使用封装好的php mailer邮件类。

1. php怎样访问已经被上传到temp的文件？

   $tmp\_dir = ini\_get(&quot;upload\_tmp\_dir&quot;);

   $file\_path = $tmp\_dir . $\_FILES[&#39;name&#39;][&#39;tmp\_name&#39;];

   echo file\_get\_contents($file\_path);

1. php preg\_match()函数是怎样使用的？

preg\_match()函数对字符串执行正则匹配，成功返回TRUE，失败返回FALSE;

var\_dump(preg\_match(&quot;/app/&quot;, &#39;apple&#39;));

1. php在发生异常错误时怎样捕获异常信息？

当发生异常时利用try{}catch(Exception $e){}捕获异常信息。

1. php创建一个Mysql连接，进行一次查询，然后关闭连接操作?

   $connect = mysql\_connect($dbhost, $username, $password) or die(&quot; connect error!&quot;);

   mysql\_select\_db($dbname, $connect);

   $result = mysql\_query(&quot;select name from table1&quot;);

   print\_r(mysql\_fetch\_row($result));

   mysql\_close($connect);