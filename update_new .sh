if [ -d /storage/xiaoya/mytoken.txt ]; then
	rm -rf /storage/xiaoya/mytoken.txt
fi
mkdir -p /storage/xiaoya
touch /storage/xiaoya/mytoken.txt
touch /storage/xiaoya/myopentoken.txt
touch /storage/xiaoya/temp_transfer_folder_id.txt

mytokenfilesize=$(cat /storage/xiaoya/mytoken.txt)
mytokenstringsize=${#mytokenfilesize}
if [ $mytokenstringsize -le 31 ]; then
	echo -e "\033[32m"
	read -p "输入你的阿里云盘 Token（32位长）: " token
	token_len=${#token}
	if [ $token_len -ne 32 ]; then
		echo "长度不对,阿里云盘 Token是32位长"
		echo -e "安装停止，请参考指南配置文件\nhttps://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f \n"
		echo -e "\033[0m"
		exit
	else	
		echo $token > /storage/xiaoya/mytoken.txt
	fi
	echo -e "\033[0m"
fi	

myopentokenfilesize=$(cat /storage/xiaoya/myopentoken.txt)
myopentokenstringsize=${#myopentokenfilesize}
if [ $myopentokenstringsize -le 279 ]; then
	echo -e "\033[33m"
        read -p "输入你的阿里云盘 Open Token（335位长）: " opentoken
	opentoken_len=${#opentoken}
        if [[ $opentoken_len -le 334 ]]; then
                echo "长度不对,阿里云盘 Open Token是335位"
		echo -e "安装停止，请参考指南配置文件\nhttps://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f \n"
		echo -e "\033[0m"
                exit
        else
        	echo $opentoken > /storage/xiaoya/myopentoken.txt
	fi
	echo -e "\033[0m"
fi

folderidfilesize=$(cat /storage/xiaoya/temp_transfer_folder_id.txt)
folderidstringsize=${#folderidfilesize}
if [ $folderidstringsize -le 39 ]; then
	echo -e "\033[36m"
        read -p "输入你的阿里云盘转存目录folder id: " folderid
	folder_id_len=${#folderid}
	if [ $folder_id_len -ne 40 ]; then
                echo "长度不对,阿里云盘 folder id是40位长"
		echo -e "安装停止，请参考指南配置文件\nhttps://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f \n"
		echo -e "\033[0m"
                exit
        else
        	echo $folderid > /storage/xiaoya/temp_transfer_folder_id.txt
	fi	
	echo -e "\033[0m"
fi

#echo "new" > /storage/xiaoya/show_my_ali.txt
if command -v ifconfig &> /dev/null; then
        localip=$(ifconfig -a|grep inet|grep -v 172.17 | grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"|head -n1)
else
        localip=$(ip address|grep inet|grep -v 172.17 | grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"|head -n1|cut -f1 -d"/")
fi

if [ $1 ]; then
if [ $1 == 'host' ]; then
	if [ ! -s /storage/xiaoya/docker_address.txt ]; then
		echo "http://$localip:5678" > /storage/xiaoya/docker_address.txt
	fi	
	docker stop xiaoya 2>/dev/null
	docker rm xiaoya 2>/dev/null
	docker stop xiaoya-hostmode 2>/dev/null
	docker rm xiaoya-hostmode 2>/dev/null
	docker rmi xiaoyaliu/alist:hostmode
	docker pull xiaoyaliu/alist:hostmode
	if [[ -f /storage/xiaoya/proxy.txt ]] && [[ -s /storage/xiaoya/proxy.txt ]]; then
        	proxy_url=$(head -n1 /storage/xiaoya/proxy.txt)
		docker run -d --env HTTP_PROXY="$proxy_url" --env HTTPS_PROXY="$proxy_url" --env no_proxy="*.aliyundrive.com" --network=host -v /storage/xiaoya:/data --restart=always --name=xiaoya xiaoyaliu/alist:hostmode
	else	
		docker run -d --network=host -v /storage/xiaoya:/data --restart=always --name=xiaoya xiaoyaliu/alist:hostmode
	fi	
	exit
fi
fi

if [ ! -s /storage/xiaoya/docker_address.txt ]; then
        echo "http://$localip:5678" > /storage/xiaoya/docker_address.txt
fi
docker stop xiaoya 2>/dev/null
docker rm xiaoya 2>/dev/null
docker rmi xiaoyaliu/alist:latest 
docker pull xiaoyaliu/alist:latest
if [[ -f /storage/xiaoya/proxy.txt ]] && [[ -s /storage/xiaoya/proxy.txt ]]; then
	proxy_url=$(head -n1 /storage/xiaoya/proxy.txt)
       	docker run -d -p 5678:80 -p 2345:2345 -p 2346:2346 --env HTTP_PROXY="$proxy_url" --env HTTPS_PROXY="$proxy_url" --env no_proxy="*.aliyundrive.com" -v /storage/xiaoya:/data --restart=always --name=xiaoya xiaoyaliu/alist:latest
else
	docker run -d -p 5678:80 -p 2345:2345 -p 2346:2346 -v /storage/xiaoya:/data --restart=always --name=xiaoya xiaoyaliu/alist:latest
fi	

