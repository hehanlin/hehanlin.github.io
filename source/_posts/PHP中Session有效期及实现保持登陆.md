original: false
title: PHP中Session有效期及实现保持登陆
tags:
  - php
id: 117
categories:
  - 杂谈
date: 2015-05-10 23:28:44
---

<!--more-->

> [http://www.csdn123.com/html/itweb/20131022/179917.htm](http://www.csdn123.com/html/itweb/20131022/179917.htm)
>
> session.gc_maxlifetime session在服务器保存的时间，超时可能被删除
>
> session.cookie_lifetime session_id在客户端cookie中保存的时间，超时失效
>
> 一个有效的session要求cookie有效，同时在服务器存在
>
> php.ini默认值cookie_lifetime=0, gc_maxlifetime=1440，即cookie在浏览器关闭后立即失效，数据在服务器这边保存24分钟
>
> 如果单独修改cookie_lifetime超过1440，没有修改gc_maxlifetime同样不能让 session 生存周期超过24分钟
>
> 网站中要达到用户登陆时勾选了“保持登陆”则保持更长的登陆有效期（只要没有主动退出，关闭浏览器后再次打开依然是登陆状态）：
>
> 1\. 修改gc_maxlifetime为希望的保持登陆有效期，比如7天则是86400*7
>
> 2\. 保持cookie_lifetime为0，登陆时没有勾选“保持登陆”则关闭浏览器立即失效
>
> 3\. 等登陆时勾选了“保持登陆”，则使用
>
> $params = session_get_cookie_params();
>
> setcookie(session_name(), session_id(), time() + ini_get('session.gc_maxlifetime'), $params['path'], $params['domain'], $params['secure'], $params['httponly']);
>
> 来修改cookie的有效期和服务器保存数据的有效期一致
