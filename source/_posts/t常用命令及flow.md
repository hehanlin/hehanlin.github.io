title: git常用命令及flow
author: hanlin
tags: []
categories: []
date: 2016-02-03 19:38:00
---
git 现在的火爆程度非同一般，它被广泛地用在大型开源项目，团队开发，以及独立开发者，学生之中。
### 1. 安装git
- Linux – 打开控制台，然后通过包管理安装，在Ubuntu上命令是：
sudo apt-get install git-all
- Windows – 推荐使用git for windows，它包括了图形工具以及命令行模拟器。
- OS X – 最简单的方式是使用homebrew安装，命令行执行
brew install git
<!--more-->
### 2. 配置Git
```
$ git config --global user.name "My Name"
$ git config --global user.email myEmail@example.com
```
配置好这两项，用户就能知道谁做了什么
### 3. 常用命令
- git commit
- git add [–all]
- git push
- git fetch
- git rebase
- git pull
- git branch [-d]
- git merge
- git cherry-pick
- git checkout [-b] BRANCH_NAME
- git stash
**>详见`man git`**

### 4. git flow
![](/images/2224012334.jpg)