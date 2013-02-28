test-porta
==========

有一个git仓库，有很多分支，它们都要被运行，测试需要看它们……

##安装

通过npm：`sudo npm install test-porta -g`

##设置

在源代码中添加一个`.test-porta`的启动脚本，并且设置为可执行`chmod +x .test-porta`，并提交。

##运行

在任意位置（最好是一个空目录，因为会产生很多临时文件），运行`test-porta git://....`即可！

##不同分支都在运行，怎样分配端口给它们

* 推荐使用[dev-porta](https://github.com/layerssss/dev-porta/)来自动分配端口并显示！
* 或者在程序中读取环境变量来进行判断，`TESTPORTABRANCH`表示当前的分支，`TESTPORTAREPO`表示当前的仓库URL
