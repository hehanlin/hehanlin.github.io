original: false
title: 利用Github的Webhook部署博客
date: 2015-08-18 15:24:40
tags:
 - Git
---


为了能在Github上产生点动态,不想让hexo直接push到vps上~.~如果每次都要手动到vps上执行pull，那太麻烦了！！！
Github的仓库可以设置Webhook，当收到push后会通知到设定的url，救星来啦～～～

<!--more-->

看了下api文档，用php写了git-hook.php文件放到博客目录下:
```
<?php
error_reporting(7);
date_default_timezone_set('UTC');
define("WWW_ROOT", "/www/sxflyer.com/");
define("LOG_FILE", "/www/logs/sxflyer.com/git-hook.log");
$shell = sprintf("cd %s && /usr/bin/git pull 2>&1", WWW_ROOT);
$output = shell_exec($shell);
$log = sprintf("[%s] %s \n", date('Y-m-d H:i:s', time()), $output);
echo $log;
file_put_contents(LOG_FILE, $log, FILE_APPEND);
```
通过ssh执行php git-hook.php成功,但url访问时失败了.vps上是通过php-fpm执行php的，用户为www-data，shell为/usr/sbin/nologin,会找不到git命令,需要使用git的绝对路径:
$shell = sprintf("cd %s && /usr/bin/git pull", WWW_ROOT);
出现权限问题
error: cannot open .git/FETCH_HEAD: Permission denied
修改目录所属：
sudo chown -R www-data:www-data ./sxflyer.com
在仓库的webhook里添加url http://sxflyer.com/git-hook.php,然后vps就可以从Github自动pull了
