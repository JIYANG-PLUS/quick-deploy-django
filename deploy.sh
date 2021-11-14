#!/bin/bash
# author: jiyang

# 参数1：项目名称
# 参数2：manage.py 文件的路径
# 参数3：wsgi.py 文件所在的目录名
# 参数4：静态文件资源路径，末尾必须加反斜杠
# 参数5：requirements.txt 文件所在的路径
# 参数6：监听的内网端口，默认 8111
# 参数7：外网的连接端口，默认 8112

# 示例：
# sh deploy.sh demoproject /opt/wwwroot/demoproject/manage.py demoproject /opt/wwwroot/demoproject/static/ /opt/wwwroot/demoproject/requirements.txt

function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

function exec_result(){
    # 用在每条执行命令的结尾处，用于提醒用户安装是否成功
    if [ $1 == 0 ]
    then
        echo $2 "执行成功，准备后续操作..."
    else
        echo $2 "执行失败，进程退出，请修改"
        exit 1
    fi
}

function folder_manager(){
    # 用于管理目录
    if [ -e $1 ]
    then
        echo "检测到" $1 "已存在，跳过创建"
    else
        mkdir $1
        exec_result $? $1
    fi
}

function args_check(){
    if [ $2 ]
    then
        echo "检测到[$2]路径已传入"
        if [ -e $2 ]
        then
            echo "$2路径检测完成,路径合法"
        else
            echo "请确保[$2]文件路径真实存在"
            exit 1
        fi
    else
        echo $1
        exit 1
    fi
}

if [ $1 ]
then
    echo "检测到Django项目名称[$1]已传入"
    # 检测项目是否已上传到指定路径下
    folder_manager "/opt/wwwroot"
    if [ -e "/opt/wwwroot/$1" ]
    then
        echo "检测到项目[$1]已上传"
    else
        echo "请先上传项目至【/opt/wwwroot】路径下..."
        exit 1
    fi
else
    echo "第一个参数，请先传入项目名称"
    exit 1
fi


args_check "第二个参数,请传入[manage.py]文件的路径" $2
# args_check "第三个参数,请传入[wsgi.py]文件的路径" $3
if [ $3 ]
then
    echo "参数三传入成功：示例demo.demo，表示项目根路径下指向wsgi.py文件的路径"
else
    echo "第三个参数，请传入wsgi.py文件所在的目录路径。示例：demo.demo，表示项目根路径下指向wsgi.py文件的路径"
    exit 1
fi
args_check "第四个参数,请传入静态文件夹的路径" $4
args_check "第五个参数,请传入[requirements.txt]文件的路径" $5

port_inner="8111" # 内网端口
port_outer="8112" # 外网端口
if [ $6 ]
then
    port_inner=$6
fi
if [ $7 ]
then
    port_outer=$7
fi

echo "------------------------------------"
echo "正在检测是否已安装【wget】"
echo "------------------------------------"
command -v wget > /dev/null
if [ $? == 0 ]
then
    echo "检测到wget已安装"
else
    echo "正在执行命令【yum -y install wget】"
    yum -y install wget
    exec_result $? "wget"
fi

echo "------------------------------------"
echo "正在检测是否已安装【Python3.8.12】环境，以命令【python38】为依据"
echo "------------------------------------"
command -v python38 > /dev/null
if [ $? == 0 ]
then
    echo 'python38命令已存在，跳过python安装'
else
    echo '正准备安装python3.8.12...'
    yum -y groupinstall "Development tools"
    exec_result $? "Development tools"
    yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
    exec_result $? "zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel"
    yum install libffi-devel -y
    exec_result $? "libffi-devel"
    wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
    exec_result $? "wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz"
    tar -zxvf  Python-3.8.12.tgz
    exec_result $? "tar -zxvf  Python-3.8.12.tgz"
    cd Python-3.8.12
    exec_result $? "cd Python-3.8.12"
    folder_manager "/opt/python38x"
    ./configure --prefix=/opt/python38x
    exec_result $? "./configure --prefix=/opt/python38x"
    make && make install
    exec_result $? "make && make install"
    rm -rf /usr/bin/python38
    ln -s /opt/python38x/bin/python3.8 /usr/bin/python38
    exec_result $? "ln -s /opt/python38x/bin/python3.8 /usr/bin/python38"
    rm -rf /usr/bin/pip38
    ln -s /opt/python38x/bin/pip3.8 /usr/bin/pip38
    exec_result $? "ln -s /opt/python38x/bin/pip3.8 /usr/bin/pip38"
    echo "Python3.8.x已安装完成，您可以使用【python38】命令进行验证"
fi

command -v python38 > /dev/null
if [ $? == 0 ]
then
    echo 'Python3.8.12已安装成功，python38命令校验成功。'
else
    echo "Python3.8.12安装失败，请检查上述的报错信息，然后根据实际情况进行命令的调整。"
    exit 1
fi

echo "------------------------------------"
echo "准备安装uwsgi"
echo "------------------------------------"
command -v uwsgi > /dev/null
if [ $? == 0 ]
then
    echo "检测到已安装uwsgi"
else
    pip38 install uwsgi
    exec_result $? "pip38 install uwsgi"
    rm -rf /usr/bin/uwsgi
    ln -s /opt/python38x/bin/uwsgi /usr/bin/uwsgi
    exec_result $? "ln -s /opt/python38x/bin/uwsgi /usr/bin/uwsgi"
fi

echo "------------------------------------"
echo "准备生成虚拟环境"
echo "------------------------------------"
command -v virtualenv > /dev/null
if [ $? == 0 ]
then
    echo "检测到已安装uwsgi"
else
    pip38 install virtualenv
    exec_result $? "pip38 install virtualenv"
    rm -rf /usr/bin/virtualenv
    ln -s /opt/python38x/bin/virtualenv /usr/bin/virtualenv
    exec_result $? "ln -s /opt/python38x/bin/virtualenv /usr/bin/virtualenv"
fi

folder_manager "/opt/venv"

if [ -e "/opt/venv/venv1/bin/activate" ]
then
    echo "检测到虚拟环境【venv1】已创建"
else
    virtualenv -p python38 /opt/venv/venv1
    exec_result $? "virtualenv -p python38 /opt/venv/venv1"
fi

/opt/venv/venv1/bin/pip install uwsgi


echo "------------------------------------"
echo "正在尝试更新Sqlite3，请耐心等待..."
echo "------------------------------------"
sqlite3_version=`sqlite3 -version`
array=($sqlite3_version)
if version_ge "${array[0]}" "3.8.3"
then
    echo "Sqlite无需更新，当前版本：" "${array[0]}"
else
    cd ~
    wget --no-check-certificate https://www.sqlite.org/2019/sqlite-autoconf-3290000.tar.gz
    tar zxvf sqlite-autoconf-3290000.tar.gz
    cd sqlite-autoconf-3290000/
    ./configure --prefix=/usr/local
    make && make install
    mv /usr/bin/sqlite3  /usr/bin/sqlite3_old
    ln -s /usr/local/bin/sqlite3   /usr/bin/sqlite3
    echo "/usr/local/lib" > /etc/ld.so.conf.d/sqlite3.conf
    ldconfig
    echo "Sqlite更新完成"
fi


echo "------------------------------------"
echo "正在配置【$1】项目环境，请耐心等待..."
echo "------------------------------------"
source /opt/venv/venv1/bin/activate # 激活虚拟环境
exec_result $? "source /opt/venv/venv1/bin/activate"
# 安装Django
pip install -r $5

echo "正在收集静态文件"
python $2 makemigrations
exec_result $? "python $2 makemigrations"
python $2 migrate
exec_result $? "python $2 migrate"
python $2 collectstatic
# exec_result $? "python $2 collectstatic"


echo "------------------------------------"
echo "正在配置uwsgi文件，请耐心等待..."
echo "------------------------------------"
# 此步骤的关键是项目已成功上传，并且脚本检测通过
if [ -e "/opt/wwwroot/$1/$1.xml" ]
then
    echo "项目配置文件【$1.xml】已存在，跳过配置"
else
    cat > "/opt/wwwroot/$1/$1.xml" <<- EOF
<uwsgi>    
    <socket>127.0.0.1:${port_inner}</socket> <!-- 内部端口，自定义 --> 
    <chdir>/opt/wwwroot/$1/</chdir> <!-- 项目路径 -->            
    <module>${1}.wsgi</module>  <!-- ${1}为wsgi.py所在目录名--> 
    <processes>4</processes> <!-- 进程数 -->     
    <daemonize>uwsgi.log</daemonize> <!-- 日志文件 -->
</uwsgi>
EOF
    echo "配置文件【$1.xml】已配置完成"
fi

# 初始化配置项
uwsgi -x "/opt/wwwroot/$1/$1.xml"
exec_result $? "uwsgi -x /opt/wwwroot/$1/$1.xml"


echo "------------------------------------"
echo "正在安装配置nginx，请耐心等待..."
echo "------------------------------------"
command -v nginx > /dev/null
if [ $? == 0 ]
then
    echo "nginx已安装，跳过安装步骤"
else
    cd ~
    wget http://nginx.org/download/nginx-1.13.7.tar.gz
    tar -zxvf nginx-1.13.7.tar.gz
    cd nginx-1.13.7
    ./configure
    make && make install # 默认安装在 /usr/local/nginx 中
    cd /usr/local/nginx/conf
    cp nginx.conf nginx.conf.bak # 备份
fi

if [ -e /usr/local/nginx/conf/vhost ]
then
    echo "[vhost]文件夹已存在，跳过创建"
else
    mkdir /usr/local/nginx/conf/vhost # 存放多个 Django 站点，一个站点一个 .conf 文件
    exec_result $? "mkdir /usr/local/nginx/conf/vhost"
fi


cat > "/usr/local/nginx/conf/vhost/$1.conf" <<- EOF
server {
    listen $port_outer; # 对外开放的端口，假设公网ip为x.x.x.x，则外部可以用x.x.x.x:$port_outer访问。
    server_name 127.0.0.1;
    charset utf-8;
    location / {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:$port_inner; # 内部交互端口，必须和 $1.xml 中配置的 socket 一致
        uwsgi_param UWSGI_SCRIPT ${3}.wsgi; # 必须和 $1.xml 中配置的 module 一致
        uwsgi_param UWSGI_CHDIR /opt/wwwroot/$1/; # 必须和 $1.xml 中配置的 chdir 一致（注意最后的右斜线）
    }
    location /static/ {
        alias ${4}; # Django的静态文件路径（注意最后的右斜线）
    }
}
EOF

cp nginx.conf nginx.conf.bak
cat > "/usr/local/nginx/conf/nginx.conf" <<- EOF
#user  nobody;
worker_processes  1;
error_log  logs/error.log;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    include /usr/local/nginx/conf/vhost/*.conf;

    # server {
    #     listen       8001;
    #     server_name  127.0.0.1;
    #     location / {
    #         root   universalparser;
    #         index  index.html index.htm;
    #     }

    #     error_page  404              /404.html;

    #     error_page   500 502 503 504  /50x.html;
    #     location = /50x.html {
    #         root   html;
    #     }
    # } # 此处可用于部署静态网站，有需要的可以解除注释

}
EOF

/usr/local/nginx/sbin/nginx -t # 检查配置是否成功
exec_result $? "nginx检查配置项"
/usr/local/nginx/sbin/nginx # 启动
exec_result $? "nginx启动(如果工具启动失败，请手工启动，或者等后续版本的自动化更新)"

deactivate # 退出虚拟环境
echo "------------------------------------"
exec_result $? "deactivate"
echo "------------------------------------"
echo "END."
