#!/bin/sh

# shadowsocks script for HND/AXHND router with kernel 4.1.27/4.1.51 merlin firmware

source /jffs/softcenter/scripts/base.sh
eval $(dbus export ss_basic_)
mkdir -p /tmp/upload
echo "" > /tmp/upload/ss_log.txt
http_response "$1"
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
ARCH=`uname -m`
KVER=`uname -r`
if [ "$ARCH" == "armv7l" ]; then
	if [ "$KVER" == "4.1.52" -o "$KVER" == "3.14.77" ];then
		ARCH="armng"
	fi
else
	if [ "$KVER" == "3.10.14" ];then
		ARCH="mipsle"
	fi
fi
if [ "$ARCH" == "armv7l" ]; then
	scarch="arm"
elif [ "$ARCH" == "armng" ]; then
	scarch="armng"
elif [ "$ARCH" == "aarch64" ]; then
	scarch="arm64"
elif [ "$ARCH" == "mipsle" ]; then
	scarch="mipsle"
elif [ "$ARCH" == "mips" ]; then
	scarch="mips"
fi
main_url="https://raw.githubusercontent.com/zusterben/plan_d/master/bin/$scarch/"
backup_url=""

install_ss(){
	echo_date 开始解压压缩包...
	tar -zxf shadowsocks.tar.gz
	chmod a+x /tmp/shadowsocks/install.sh
	echo_date 开始安装更新文件...
	sh /tmp/shadowsocks/install.sh
	rm -rf /tmp/shadowsocks*
}

update_ss(){
	echo_date 更新过程中请不要刷新本页面或者关闭路由等，不然可能导致问题！
	echo_date 开启SS检查更新：使用主服务器：github
	echo_date 检测主服务器在线版本号...
	ss_basic_version_web1=`curl -s --connect-timeout 5 $main_url/version | sed -n 1p`
	if [ -n "$ss_basic_version_web1" ];then
		echo_date 检测到主服务器在线版本号：$ss_basic_version_web1
		if [ "$ss_basic_version_local" != "$ss_basic_version_web1" ];then
		echo_date 主服务器在线版本号："$ss_basic_version_web1" 和本地版本号："$ss_basic_version_local" 不同！
			cd /tmp
			md5_web1=`curl -4sk --connect-timeout 5 $main_url/version | sed -n 2p`
			echo_date 开启下载进程，从主服务器上下载更新包...
			wget --no-check-certificate --timeout=5 "$main_url"/shadowsocks.tar.gz
			md5sum_gz=`md5sum /tmp/shadowsocks.tar.gz | sed 's/ /\n/g'| sed -n 1p`
			if [ "$md5sum_gz" != "$md5_web1" ]; then
				echo_date 更新包md5校验不一致！估计是下载的时候出了什么状况，请等待一会儿再试...
				rm -rf /tmp/shadowsocks* >/dev/null 2>&1
				sleep 1
				echo_date 更换备用备用更新地址，请稍后...
				sleep 1
				update_ss2
			else
				echo_date 更新包md5校验一致！ 开始安装！...
				install_ss
			fi
		else
			echo_date 主服务器在线版本号："$ss_basic_version_web1" 和本地版本号："$ss_basic_version_local" 相同！
			echo_date 退出插件更新!
			sleep 1
			echo XU6J03M6
			exit
		fi
	else
		echo_date 没有检测到主服务器在线版本号,访问github服务器可能有点问题！
		sleep 1
		echo_date 更换备用备用更新地址，请稍后...
		sleep 1
		update_ss2
	fi
}

update_ss2(){
	echo_date "目前还没有任何备用服务器！请尝试使用离线安装功能！"
	echo_date "历史版本下载地址：https://raw.githubusercontent.com/zusterben/plan_d/master/history_package/$scarch/"
	echo_date "下载后请将下载包名字改为：shadowsocks.tar.gz，再使用软件中心离线安装功能进行安装！"
	sleep 1
	echo XU6J03M6
	exit
}

case $2 in
update)
	update_ss >> /tmp/upload/ss_log.txt 2>&1
	echo XU6J03M6 >> /tmp/upload/ss_log.txt
	;;
esac

