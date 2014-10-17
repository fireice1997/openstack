1、执行脚本前提

使用sudo -i 切换到root用户

2、在root目录中上传cirros-0.3.2-x86_64-disk.img文件

3、执行每个shell脚本时，按照自己的环境修改shell文件开头的变量

4、执行顺序

(1)netinit.sh
(2)baseinit.sh
(3)keystoneinstall
(4)glanceinstall.sh
(5)novainstall.sh
(6)horizon.sh

5、执行脚本使用sh命令

6、执行完成后，打开http://$HOST_IP/horizon 登录admin/admin_pass