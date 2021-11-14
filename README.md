# quick-deploy-django
真正的一键式部署Django

<font color="red">使用前请先上传项目文件至服务器 /opt/wwwroot/ 路径下！！！</font>  
<font color="red">并配置好Django的生产环境参数！！！</font>   

## <font color="#caff56">启动命令</font>
`sh deploy.sh demoproject /opt/wwwroot/demoproject/manage.py demoproject /opt/wwwroot/demoproject/static/ /opt/wwwroot/demoproject/requirements.txt 8111 8112`

命令接受7个参数，前5个参数必须传入，后两个参数均有默认值：  

1. 参数1：项目名称
2. 参数2：manage.py 文件的路径
3. 参数3：wsgi.py 文件所在的目录路径
4. 参数4：静态文件资源路径，末尾必须加反斜杠
5. 参数5：requirements.txt 文件所在的路径
6. 参数6：监听的内网端口，默认 8111
7. 参数7：外网的连接端口（外部访问端口），默认 8112


## <font color="#caff56">关于参数3的特殊说明</font>
假如有个项目Demo，项目结构如下：  
`DemoProject` 
&nbsp;&nbsp;&nbsp;&nbsp;`- Demo`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`- wsgi.py`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`- ...`  
&nbsp;&nbsp;&nbsp;&nbsp;`- manage.py`  

则参数三需要传入：`Demo`，如果层级较深，比如：  

`DemoProject`  
&nbsp;&nbsp;&nbsp;&nbsp;`- Demo`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`- SubDemo`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`- wsgi.py`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`- ...`  
&nbsp;&nbsp;&nbsp;&nbsp;`- manage.py`  

则参数三需要传入：`Demo.SubDemo`  



## <font color="#caff56">目前测试的环境</font>
CentOS7、Django2.1.0、Python3.8.12（后续会测试更多的版本）  
目前已经发现的问题：Django3.1.2版本及以后的Sqlite版本无法正确识别的问题，以后会想办法解决。  

nginx暂时不支持重启，重启nginx和uwsgi请先暂时移至手动操作。  


## <font color="#caff56">其它</font>
后续会完善脚本，使其更加健壮，并增加更多的功能。  

