#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
导出路径

#===================================================
# 系统要求：CentOS/Debian/Ubuntu/ArchLinux
# 说明：ServerStatus客户端+服务器
# 版本：测试 v0.4.1
# 作者：东洋，APTX修改
#===================================================

sh_ver="0.4.1"
文件路径=$(
  cd "$(目录名 "$0")" || 出口
  密码
)
file_1=$(echo -e "${filepath}" | awk -F "$0" '{print $1}')
文件="/usr/local/ServerStatus"
web_file="/usr/local/ServerStatus/web"
server_file="/usr/local/ServerStatus/server"
server_conf="/usr/local/ServerStatus/server/config.json"
server_conf_1="/usr/local/ServerStatus/server/config.conf"
client_file="/usr/local/ServerStatus/client"

client_log_file="/tmp/serverstatus_client.log"
server_log_file="/tmp/serverstatus_server.log"
jq_file="${file}/jq"
[[！-e ${jq_file} ]] && jq_file="/usr/bin/jq"
region_json="${file}/region.json"

github_prefix="https://raw.githubusercontent.com/CokeMine/ServerStatus-Hotaru/master"
coding_prefix="https://cokemine.coding.net/p/hotarunet/d/ServerStatus-Hotaru/git/raw/master"
链接前缀=${github_prefix}

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
错误="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#检查系统
check_sys() {
  如果 [[ -f /etc/redhat-release ]]; 然后
    发布="centos"
  elif grep -q -E -i "debian|ubuntu" /etc/issue；然后
    发布="debian"
  elif grep -q -E -i "centos|red hat|redhat" /etc/issue; 然后
    发布="centos"
  elif grep -q -E -i "Arch|Manjaro" /etc/issue; 然后
    发布="archlinux"
  elif grep -q -E -i "debian|ubuntu" /proc/version; 然后
    发布="debian"
  elif grep -q -E -i "centos|red hat|redhat" /proc/version; 然后
    发布="centos"
  别的
    echo -e "服务器状态暂不支持该Linux发行版"
  菲
  位=$(uname -m)
}
check_installed_server_status() {
  [[！-e "${server_file}/sergate" ]] && echo -e "${Error} ServerStatus 服务端没有安装，请检查！" && 退出 1
}
check_installed_client_status() {
  [[！-e "${client_file}/status-client.py" ]] && echo -e "${Error} ServerStatus 客户端没有安装，请检查！" && 退出 1
}
check_pid_server() {
  #PID=$(ps -ef | grep "sergate" | grep -v grep | grep -v ".sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}' )
  PID=$(pgrep -f "sergate")
}
check_pid_client() {
  #PID=$(ps -ef | grep "status-client.py" | grep -v grep | grep -v ".sh" | grep -v "init.d" | grep -v "service" | awk '{打印 $2}')
  PID=$(pgrep -f "status-client.py")
}
check_region() {
  # 如果找不到区域文件，默认不检测
  [[！-e "${region_json}" ]] && 返回 0
  如果 ${jq_file} "[.countries | has(\"${region_s}}\")]" "${region_json}" | grep -q 'true' >/dev/null 2>&1; 然后
    返回 0
  elif grep -qw "${region_s}" "${region_json}"; 然后
    region_s=$(grep -w "${region_s}" "${region_json}" | sed "s/[[:space:]]//g")
    region_s=${region_s:1:2}
    返回 0
  菲
  返回 1
}
Download_Server_Status_server() {
  cd "/tmp" || 1号出口
  [[ ${mirror_num} == 2 ]] && bundle_link="https://cokemine.coding.net/p/hotarunet/d/ServerStatus-Hotaru/git/archive/master/?download=true" || bundle_link="https://github.com/CokeMine/ServerStatus-Hotaru/archive/master.zip"
  [[ ${mirror_num} == 2 ]] && github_link="https://hub.fastgit.org" || github_link="https://github.com"
  wget -N --no-check-certificate "${bundle_link}" -O "master.zip"
  [[！-e "master.zip" ]] && echo -e "${Error} ServerStatus 服务端下载失败！" && 退出 1
  解压master.zip
  rm -rf master.zip
  [[ -d "/tmp/cokemine-hotarunet-ServerStatus-Hotaru-master" ]] && mv "/tmp/cokemine-hotarunet-ServerStatus-Hotaru-master" "/tmp/ServerStatus-Hotaru-master"
  [[！-d "/tmp/ServerStatus-Hotaru-master" ]] && echo -e "${Error} ServerStatus 服务端解压失败！" && 退出 1
  cd "/tmp/ServerStatus-Hotaru-master/server" || 1号出口
  制作
  [[！-e "sergate" ]] && echo -e "${Error} ServerStatus 服务端编译失败！" && cd "${file_1}" && rm -rf "/tmp/ServerStatus-Hotaru-master" && 退出 1
  cd "${file_1}" || 1号出口
  mkdir -p "${server_file}"
  如果 [[ -e "${server_file}/sergate" ]]; 然后
    mv "${server_file}/sergate" "${server_file}/sergate1"
    mv "/tmp/ServerStatus-Hotaru-master/server/sergate" "${server_file}/sergate"
  别的
    mv "/tmp/ServerStatus-Hotaru-master/server/sergate" "${server_file}/sergate"
    wget -N --no-check-certificate "${github_link}/cokemine/hotaru_theme/releases/latest/download/hotaru-theme.zip"
    解压 hotaru-theme.zip && mv "./hotaru-theme" "${web_file}"
    rm -rf hotaru-theme.zip
  菲
  rm -rf "/tmp/ServerStatus-Hotaru-master"
  如果 [[ ！-e "${server_file}/sergate" ]]; 然后
    echo -e "${Error} ServerStatus 服务端移动重命名失败！"
    [[ -e "${server_file}/sergate1" ]] && mv "${server_file}/sergate1" "${server_file}/sergate"
    1号出口
  别的
    [[ -e "${server_file}/sergate1" ]] && rm -rf "${server_file}/sergate1"
  菲
}
Download_Server_Status_client() {
  cd "/tmp" || 1号出口
  wget -N --no-check-certificate "${link_prefix}/clients/status-client.py"
  [[！-e "status-client.py" ]] && echo -e "${Error} ServerStatus 客户端下载失败！" && 退出 1
  cd "${file_1}" || 1号出口
  mkdir -p "${client_file}"
  [[ -e "${client_file}/status-client.py" ]] && mv "${client_file}/status-client.py" "${client_file}/status-client1.py"
  mv "/tmp/status-client.py" "${client_file}/status-client.py"
  如果 [[ ！-e "${client_file}/status-client.py" ]]; 然后
    echo -e "${Error} ServerStatus 客户端移动失败！"
    [[ -e "${client_file}/status-client1.py" ]] && mv "${client_file}/status-client1.py" "${client_file}/status-client.py"
    rm -rf "/tmp/status-client.py"
    1号出口
  别的
    [[ -e "${client_file}/status-client1.py" ]] && rm -rf "${client_file}/status-client1.py"
    rm -rf "/tmp/status-client.py"
  菲
}
下载_服务器_状态_服务（）{
  模式=$1
  [[ -z ${mode} ]] && mode="服务器"
  local service_note="服务端"
  [[ ${mode} == "client" ]] && service_note="客户端"
  如果 [[ ${release} == "archlinux" ]]; 然后
    wget --no-check-certificate "${link_prefix}/service/status-${mode}.service" -O "/usr/lib/systemd/system/status-${mode}.service" ||
      {
        echo -e "${Error} ServerStatus ${service_note}服务管理脚本下载失败！"
        1号出口
      }
    systemctl enable "status-${mode}.service"
  别的
    wget --no-check-certificate "${link_prefix}/service/server_status_${mode}_${release}" -O "/etc/init.d/status-${mode}" ||
      {
        echo -e "${Error} ServerStatus ${service_note}服务管理脚本下载失败！"
        1号出口
      }
    chmod +x "/etc/init.d/status-${mode}"
    [[ ${release} == "centos" ]] &&
      {
        chkconfig --add "status-${mode}"
        chkconfig "status-${mode}" on
      }

    [[ ${release} == "debian" ]] && update-rc.d -f "status-${mode}" 默认
  菲
  echo -e "${Info} ServerStatus ${service_note} 服务管理脚本下载完成！"
}
Service_Server_Status_server() {
  下载_服务器_状态_服务“服务器”
}
Service_Server_Status_client() {
  下载_服务器_状态_服务“客户端”
}
安装依赖（）{
  模式=$1
  如果 [[ ${release} == "centos" ]]; 然后
    百胜缓存
    yum -y 安装解压
    yum -y install python3 >/dev/null 2>&1 || yum -y 安装python
    [[ ${mode} == "server" ]] && yum -y groupinstall "开发工具"
  elif [[ ${release} == "debian" ]]; 然后
    apt -y 更新
    apt -y 安装解压
    apt -y install python3 >/dev/null 2>&1 || apt -y 安装python
    [[ ${mode} == "server" ]] && apt -y install build-essential
  elif [[ ${release} == "archlinux" ]]; 然后
    pacman -Sy python python-pip unzip --noconfirm
    [[ ${mode} == "server" ]] && pacman -Sy base-devel --noconfirm
  菲
  [[！-e /usr/bin/python ]] && ln -s /usr/bin/python3 /usr/bin/python
}
写服务器配置（）{
  猫 >${server_conf} <<-EOF
{“服务器”：
 [
  {
   "用户名": "用户名01",
   “密码”：“密码”，
   "name": "服务器 01",
   “类型”：“KVM”，
   “主持人”： ””，
   “位置”：“香港”，
   “禁用”：假，
   “地区”：“香港”
  }
 ]
}
EOF
}
Write_server_config_conf() {
  猫 >${server_conf_1} <<-EOF
端口 = ${server_port_s}
EOF
}
Read_config_client() {
  client_text="$(sed 's/\"//g;s/,//g;s/ //g' "${client_file}/status-client.py") "
  client_server="$(echo -e "${client_text}" | grep "SERVER=" | awk -F "="'{print $2}')"
  client_port="$(echo -e "${client_text}" | grep "PORT=" | awk -F "="'{print $2}')"
  client_user="$(echo -e "${client_text}" | grep "USER=" | awk -F "="'{print $2}')"
  client_password="$(echo -e "${client_text}" | grep "PASSWORD=" | awk -F "=" '{print $2}')"
  grep -q "NET_IN, NET_OUT = get_traffic_vnstat()" "${client_file}/status-client.py" && client_vnstat="true" || client_vnstat="假"
}
Read_config_server() {
  如果 [[ ！-e "${server_conf_1}" ]]; 然后
    server_port_s="35601"
    Write_server_config_conf
    server_port="35601"
  别的
    server_port="$(grep "PORT = " ${server_conf_1} | awk '{print $3}')"
  菲
}
设置服务器（）{
  模式=$1
  [[ -z ${mode} ]] && mode="服务器"
  如果 [[ ${mode} == "服务器" ]]; 然后
    echo -e "请输入ServerStatus 端中网站要设置的服务器域名[server]
例如本机IP为域名，输入：toyoo.pw ，如果使用本机默认IP，请空直接回车"
    read -erp "(默认：本机IP):" server_s
    [[ -z "$server_s" ]] && server_s=""
  别的
    echo -e "请输入ServerStatus服务端的IP/域名[服务器]，请注意，如果你的域名使用了CDN，请直接重新填写IP"
    读取 -erp "(默认: 127.0.0.1):" server_s
    [[ -z "$server_s" ]] && server_s="bt.xfjsq.cc"
  菲

  回声 && 回声 " =============================================== =="
  echo -e " IP/域名[服务器]: ${Red_background_prefix} ${server_s} ${Font_color_suffix}"
  echo " ================================================ " && 回声
}
Set_server_http_port() {
  虽然是真的；做
    echo -e "请输入服务器状态的服务器中网站要设置的域名/IP的端口[1-65535]（如果是域名端口，一般用80端口）"
    读取 -erp "（默认值：8888）：" server_http_port_s
    [[ -z "$server_http_port_s" ]] && server_http_port_s="8888"
    如果 [[ "$server_http_port_s" =~ ^[0-9]*$ ]]; 然后
      如果 [[ ${server_http_port_s} -ge 1 ]] && [[ ${server_http_port_s} -le 65535 ]]; 然后
        回声 && 回声 " =============================================== =="
        echo -e "端口：${Red_background_prefix} ${server_http_port_s} ${Font_color_suffix}"
        echo " ================================================ " && 回声
        休息
      别的
        echo "输入错误，请输入正确的端口。"
      菲
    别的
      echo "输入错误，请输入正确的端口。"
    菲
  完毕
}
Set_server_port() {
  虽然是真的；做
    echo -e "请输入ServerStatus服务端监听的端口[1-65535]（用于服务端接收客户端的消息刷新端口，客户端这个端口）"
    读取 -erp "（默认值：35601）：" server_port_s
    [[ -z "$server_port_s" ]] && server_port_s="35601"
    如果 [[ "$server_port_s" =~ ^[0-9]*$ ]]; 然后
      如果 [[ ${server_port_s} -ge 1 ]] && [[ ${server_port_s} -le 65535 ]]; 然后
        回声 && 回声 " =============================================== =="
        echo -e "端口：${Red_background_prefix} ${server_port_s} ${Font_color_suffix}"
        echo " ================================================ " && 回声
        休息
      别的
        echo "输入错误，请输入正确的端口。"
      菲
    别的
      echo "输入错误，请输入正确的端口。"
    菲
  完毕
}
设置用户名（）{
  模式=$1
  [[ -z ${mode} ]] && mode="服务器"
  如果 [[ ${mode} == "服务器" ]]; 然后
    echo -e "请输入ServerStatus 服务端设置的用户名[用户名]（数字/数字，不可与其他账号重复）"
  别的
    echo -e "请ServerStatus 服务端中配置的用户名[用户名] 字符（/数字，不可与其他账号输入重复）"
  菲
  读取 -erp "(默认：取消):" username_s
  [[ -z "$username_s" ]] && echo "已取消..." && exit 0
  回声 && 回声 " =============================================== =="
  echo -e "账号[用户名]: ${Red_background_prefix} ${username_s} ${Font_color_suffix}"
  echo " ================================================ " && 回声
}
设置密码（） {
  模式=$1
  [[ -z ${mode} ]] && mode="服务器"
  如果 [[ ${mode} == "服务器" ]]; 然后
    echo -e "请输入 ServerStatus 设置服务器端的[密码]（数字/数字，可重复密码）"
  别的
    echo -e "请输入服务器端中配置的密码[密码]字符（数字）"
  菲
  读取 -erp "(默认: doub.io):" password_s
  [[ -z "$password_s" ]] && password_s="doub.io"
  回声 && 回声 " =============================================== =="
  echo -e "密码[密码]: ${Red_background_prefix} ${password_s} ${Font_color_suffix}"
  echo " ================================================ " && 回声
}
Set_vnstat() {
  echo -e "对于流量计算是否使用 Vnstat 每月自动清零？ [y/N]"
  读取 -erp "(默认: N):" isVnstat
  [[ -z "$isVnstat" ]] && isVnstat="n"
}
设置名称（）{
  -e "服务器状态输入是你的系统名称的设置的设置，支持SSH服务输入是你的中文支持的系统名称，输入的服务名称和名称，""
  读取 -erp "(默认: Server 01):" name_s
  [[ -z "$name_s" ]] && name_s="服务器 01"
  回声 && 回声 " =============================================== =="
  echo -e "节点名称[name]: ${Red_background_prefix} ${name_s} ${Font_color_suffix}"
  echo " ================================================ " && 回声
}
设置类型（）{
  echo -e "请输入 ServerStatus 服务端要设置的节点虚拟化类型[type]（例如 OpenVZ / KVM）"
  read -erp "(默认: KVM):" type_s
  [[ -z "$type_s" ]] && type_s="KVM"
  回声 && 回声 " =============================================== =="
  echo -e " 虚拟化类型[type]: ${Red_background_prefix} ${type_s} ${Font_color_suffix}"
  echo " ================================================ " && 回声
}
设置位置（）{
  -e "请求服务器状态输入端要设置的节点位置]（支持中文，输入位置是你的系统和SSH服务器输入位置）
  read -erp "(默认: Hong Kong):" location_s
  [[ -z "$location_s" ]] && location_s="香港"
  回声 && 回声 " =============================================== =="
  echo -e "节点位置[location]: ${Red_background_prefix} ${location_s} ${Font_color_suffix}"
  echo " ================================================ " && 回声
}
设置区域（）{
  echo -e "输入 ServerStatus 设置的地区[region]请输入服务器端的图标显示（供国家/地区的服务端图标显示）"
  读取 -erp "(默认: HK):" region_s
  [[ -z "$region_s" ]] && region_s="HK"
  尽管 ！检查区域；做
    read -erp "你输入的地区不合法，请重新输入：" region_s
  完毕
  回声 && 回声 " =============================================== =="
  echo -e " 节点地区[region]: ${Red_background_prefix} ${region_s} ${Font_color_suffix}"
  echo " ================================================ " && 回声
}
Set_config_server() {
  set_username "服务器"
  设置密码“服务器”
  设置名称
  设置类型
  设置位置
  设置区域
}
Set_config_client() {
  设置服务器“客户端”
  设置服务器端口
  设置用户名“客户”
  设置密码“客户”
  设置_vnstat
}
Set_ServerStatus_server() {
  check_installed_server_status
  echo && echo -e "你要做什么？

 ${Green_font_prefix} 1.${Font_color_suffix} 添加节点配置
 ${Green_font_prefix} 2.${Font_color_suffix} 删除节点配置
—————————
 ${Green_font_prefix} 3.${Font_color_suffix} 修改节点配置 - 节点用户名
 ${Green_font_prefix} 4.${Font_color_suffix} 修改节点配置 - 节点密码
 ${Green_font_prefix} 5.${Font_color_suffix} 修改名称节点配置 - 节点
 ${Green_font_prefix} 6.${Font_color_suffix} 修改节点配置 - 节点虚拟化
 ${Green_font_prefix} 7.${Font_color_suffix} 位置修改节点配置 - 节点
 ${Green_font_prefix} 8.${Font_color_suffix} 修改节点配置 - 区域节点
 ${Green_font_prefix} 9.${Font_color_suffix} 修改节点配置 - 所有参数
—————————
 ${Green_font_prefix} 10.${Font_color_suffix} 启用/禁用节点配置
—————————
 ${Green_font_prefix}11.${Fon_color_suffix} 修改服务端监听端口" && echo
  读取 -erp "（默认：取消）：" server_num
  [[ -z "${server_num}" ]] && echo "已取消..." && exit 1
  如果 [[ ${server_num} == "1" ]]; 然后
    Add_ServerStatus_server
  elif [[ ${server_num} == "2" ]]; 然后
    Del_ServerStatus_server
  elif [[ ${server_num} == "3" ]]; 然后
    Modify_ServerStatus_server_username
  elif [[ ${server_num} == "4" ]]; 然后
    Modify_ServerStatus_server_password
  elif [[ ${server_num} == "5" ]]; 然后
    Modify_ServerStatus_server_name
  elif [[ ${server_num} == "6" ]]; 然后
    Modify_ServerStatus_server_type
  elif [[ ${server_num} == "7" ]]; 然后
    Modify_ServerStatus_server_location
  elif [[ ${server_num} == "8" ]]; 然后
    Modify_ServerStatus_server_region
  elif [[ ${server_num} == "9" ]]; 然后
    Modify_ServerStatus_server_all
  elif [[ ${server_num} == "10" ]]; 然后
    Modify_ServerStatus_server_disabled
  elif [[ ${server_num} == "11" ]]; 然后
    读取配置服务器
    设置服务器端口
    Write_server_config_conf
  别的
    echo -e "${Error} 请输入正确的数字[1-11]" && exit 1
  菲
  Restart_ServerStatus_server
}
List_ServerStatus_server() {
  conf_text=$(${jq_file} '.servers' ${server_conf} | ${jq_file} ".[]|.username" | sed 's/\"//g')
  conf_text_total=$(echo -e "${conf_text}" | wc -l)
  [[ ${conf_text_total} == "0" ]] && echo -e "${Error} 没有发现一个节点配置，请检查！" && 退出 1
  conf_text_total_a=$((conf_text_total - 1))
  conf_list_all=""
  for ((integer = 0; integer <= conf_text_total_a; integer++)); 做
    now_text=$(${jq_file} '.servers' ${server_conf} | ${jq_file} ".[${integer}]" | sed 's/\"//g;s/,$//g' | sed '$d;1d')
    now_text_username=$(echo -e "${now_text}" | grep "用户名" | awk -F ": "'{print $2}')
    now_text_password=$(echo -e "${now_text}" | grep "密码" | awk -F ": "'{print $2}')
    now_text_name=$(echo -e "${now_text}" | grep "名称" | grep -v "用户名" | awk -F ": "'{print $2}')
    now_text_type=$(echo -e "${now_text}" | grep "type" | awk -F ": "'{print $2}')
    now_text_location=$(echo -e "${now_text}" | grep "位置" | awk -F ": "'{print $2}')
    now_text_region=$(echo -e "${now_text}" | grep "region" | awk -F ": "'{print $2}')
    now_text_disabled=$(echo -e "${now_text}" | grep "已禁用" | awk -F ": " '{print $2}')
    如果 [[ ${now_text_disabled} == "false" ]]; 然后
      now_text_disabled_status="${Green_font_prefix} 启用${Font_color_suffix}"
    别的
      now_text_disabled_status="${Red_font_prefix}禁用${Font_color_suffix}"
    菲
    conf_list_all=${conf_list_all}"用户名: ${Green_font_prefix}${now_text_username}${Font_color_suffix} 密码: ${Green_font_prefix}${now_text_password}${Font_color_suffix} 节点名: ${Green_font_prefix}${now_text_name}${Font_color_suffix } 类型：${Green_font_prefix}${now_text_type}${Font_color_suffix} 位置：${Green_font_prefix}${now_text_location}${Font_color_suffix} 区域：${Green_font_prefix}${now_text_region}${Font_color_suffix} 状态：${Green_font_prefix}$ {now_text_disabled_status}${Font_color_suffix}\n"
  完毕
  echo && echo -e "节点总数${Green_font_prefix}${conf_text_total}${Font_color_suffix}"
  回声 -e "${conf_list_all}"
}
Add_ServerStatus_server() {
  Set_config_server
  set_username_ch=$(grep '"username": "'"${username_s}"'"' ${server_conf})
  [[ -n "${Set_username_ch}" ]] && echo -e "${Error} 用户名已被使用！" && 退出 1
  sed -i '3i\ },' ${server_conf}
  sed -i '3i\ "region": "'"${region_s}"'"' ${server_conf}
  sed -i '3i\ "disabled": false ,' ${server_conf}
  sed -i '3i\ "location": "'"${location_s}"'",' ${server_conf}
  sed -i '3i\ "host": "'"None"'",' ${server_conf}
  sed -i '3i\ "type": "'"${type_s}"'",' ${server_conf}
  sed -i '3i\ "name": "'"${name_s}"'",' ${server_conf}
  sed -i '3i\ "密码": "'"${password_s}"'",' ${server_conf}
  sed -i '3i\ "用户名": "'"${username_s}"'",' ${server_conf}
  sed -i '3i\ {' ${server_conf}
  echo -e "${Info} 添加节点成功 ${Green_font_prefix}[ 节点名称: ${name_s}, 节点用户名: ${username_s}, 节点密码: ${password_s} ]${Font_color_suffix} !"
}
Del_ServerStatus_server() {
  List_ServerStatus_server
  [[ "${conf_text_total}" == "1" ]] && echo -e "${Error} 节点配置只剩1个，不能删除！" && 退出 1
  echo -e "请输入要删除的用户名"
  读取-erp“（默认：取消）：”del_server_username
  [[ -z "${del_server_username}" ]] && echo -e "已取消..." && exit 1
  del_username=$(cat -n ${server_conf} | grep '"username": "'"${del_server_username}"'"' | awk '{print $1}')
  如果 [[ -n ${del_username} ]]; 然后
    del_username_min=$((del_username - 1))
    del_username_max=$((del_username + 8))
    del_username_max_text=$(sed -n "${del_username_max}p" ${server_conf})
    del_username_max_text_last=${del_username_max_text:((${#del_username_max_text} - 1))}
    如果 [[ ${del_username_max_text_last} != "," ]]; 然后
      del_list_num=$((del_username_min - 1))
      sed -i "${del_list_num}s/,$//g" ${server_conf}
    菲
    sed -i "${del_username_min},${del_username_max}d" ${server_conf}
    echo -e "${Info} 节点节点成功 ${Green_font_prefix}[ 节点名: ${del_server_username} ]${Font_color_suffix} "
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Modify_ServerStatus_server_username() {
  List_ServerStatus_server
  echo -e "请输入要修改的节点用户名"
  阅读-erp“（默认：取消）：”manual_username
  [[ -z "${manually_username}" ]] && echo -e "已取消..." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  如果 [[ -n ${Set_username_num} ]]; 然后
    设置用户名
    set_username_ch=$(grep '"username": "'"${username_s}"'"' ${server_conf})
    [[ -n "${Set_username_ch}" ]] && echo -e "${Error} 用户名已被使用！" && 退出 1
    sed -i "${Set_username_num}"'s/"username": "'"${manually_username}"'"/"username": "'"${username_s}"'"/g' ${server_conf}
    echo -e "${Info} 成功修改 [原节点用户名: ${manually_username}, 新节点用户名: ${username_s} ]"
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Modify_ServerStatus_server_password() {
  List_ServerStatus_server
  echo -e "请输入要修改的节点用户名"
  阅读-erp“（默认：取消）：”manual_username
  [[ -z "${manually_username}" ]] && echo -e "已取消..." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  如果 [[ -n ${Set_username_num} ]]; 然后
    设置密码
    Set_password_num_a=$((Set_username_num + 1))
    Set_password_num_text=$(sed -n "${Set_password_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_password_num_a}"'s/"password": "'"${Set_password_num_text}"'"/"password": "'"${password_s}"'"/g' ${server_conf}
    echo -e "${Info} 成功修改 [原节点密码: ${Set_password_num_text}, 新节点密码: ${password_s} ]"
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Modify_ServerStatus_server_name() {
  List_ServerStatus_server
  echo -e "请输入要修改的节点用户名"
  阅读-erp“（默认：取消）：”manual_username
  [[ -z "${manually_username}" ]] && echo -e "已取消..." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  如果 [[ -n ${Set_username_num} ]]; 然后
    设置名称
    Set_name_num_a=$((Set_username_num + 2))
    Set_name_num_a_text=$(sed -n "${Set_name_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_name_num_a}"'s/"name": "'"${Set_name_num_a_text}"'"/"name": "'"${name_s}"'"/g' ${server_conf}
    echo -e "${Info} 成功修改 [原节点名称: ${Set_name_num_a_text}, 新节点名称: ${name_s} ]"
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Modify_ServerStatus_server_type() {
  List_ServerStatus_server
  echo -e "请输入要修改的节点用户名"
  阅读-erp“（默认：取消）：”manual_username
  [[ -z "${manually_username}" ]] && echo -e "已取消..." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  如果 [[ -n ${Set_username_num} ]]; 然后
    设置类型
    Set_type_num_a=$((Set_username_num + 3))
    Set_type_num_a_text=$(sed -n "${Set_type_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_type_num_a}"'s/"type": "'"${Set_type_num_a_text}"'"/"type": "'"${type_s}"'"/g' ${server_conf}
    echo -e "${Info} 修改成功 [原节点虚拟化: ${Set_type_num_a_text}, 新节点虚拟化: ${type_s} ]"
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Modify_ServerStatus_server_location() {
  List_ServerStatus_server
  echo -e "请输入要修改的节点用户名"
  阅读-erp“（默认：取消）：”manual_username
  [[ -z "${manually_username}" ]] && echo -e "已取消..." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  如果 [[ -n ${Set_username_num} ]]; 然后
    设置位置
    Set_location_num_a=$((Set_username_num + 5))
    Set_location_num_a_text=$(sed -n "${Set_location_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_location_num_a}"'s/"location": "'"${Set_location_num_a_text}"'"/"location": "'"${location_s}"'"/g' ${server_conf}
    echo -e "${Info} 成功修改 [原节点位置: ${Set_location_num_a_text}, 新节点位置: ${location_s} ]"
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Modify_ServerStatus_server_region() {
  List_ServerStatus_server
  echo -e "请输入要修改的节点用户名"
  阅读-erp“（默认：取消）：”manual_username
  [[ -z "${manually_username}" ]] && echo -e "已取消..." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  如果 [[ -n ${Set_username_num} ]]; 然后
    设置区域
    Set_region_num_a=$((Set_username_num + 7))
    Set_region_num_a_text=$(sed -n "${Set_region_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_region_num_a}"'s/"region": "'"${Set_region_num_a_text}"'"/"region": "'"${region_s}"'"/g' ${server_conf}
    echo -e "${Info} 成功修改 [原节点地区: ${Set_region_num_a_text}, 新节点地区: ${region_s} ]"
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Modify_ServerStatus_server_all() {
  List_ServerStatus_server
  echo -e "请输入要修改的节点用户名"
  阅读-erp“（默认：取消）：”manual_username
  [[ -z "${manually_username}" ]] && echo -e "已取消..." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  如果 [[ -n ${Set_username_num} ]]; 然后
    设置用户名
    设置密码
    设置名称
    设置类型
    设置位置
    设置区域
    sed -i "${Set_username_num}"'s/"username": "'"${manually_username}"'"/"username": "'"${username_s}"'"/g' ${server_conf}
    Set_password_num_a=$((Set_username_num + 1))
    Set_password_num_text=$(sed -n "${Set_password_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_password_num_a}"'s/"password": "'"${Set_password_num_text}"'"/"password": "'"${password_s}"'"/g' ${server_conf}
    Set_name_num_a=$((Set_username_num + 2))
    Set_name_num_a_text=$(sed -n "${Set_name_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_name_num_a}"'s/"name": "'"${Set_name_num_a_text}"'"/"name": "'"${name_s}"'"/g' ${server_conf}
    Set_type_num_a=$((Set_username_num + 3))
    Set_type_num_a_text=$(sed -n "${Set_type_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_type_num_a}"'s/"type": "'"${Set_type_num_a_text}"'"/"type": "'"${type_s}"'"/g' ${server_conf}
    Set_location_num_a=$((Set_username_num + 5))
    Set_location_num_a_text=$(sed -n "${Set_location_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_location_num_a}"'s/"location": "'"${Set_location_num_a_text}"'"/"location": "'"${location_s}"'"/g' ${server_conf}
    Set_region_num_a=$((Set_username_num + 7))
    Set_region_num_a_text=$(sed -n "${Set_region_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}' )
    sed -i "${Set_region_num_a}"'s/"region": "'"${Set_region_num_a_text}"'"/"region": "'"${region_s}"'"/g' ${server_conf}
    echo -e "${Info} 修改成功。"
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Modify_ServerStatus_server_disabled() {
  List_ServerStatus_server
  echo -e "请输入要修改的节点用户名"
  阅读-erp“（默认：取消）：”manual_username
  [[ -z "${manually_username}" ]] && echo -e "已取消..." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  如果 [[ -n ${Set_username_num} ]]; 然后
    Set_disabled_num_a=$((Set_username_num + 6))
    Set_disabled_num_a_text=$(sed -n "${Set_disabled_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F": "'{print $2}' )
    如果 [[ ${Set_disabled_num_a_text} == "false" ]]; 然后
      disabled_s="真"
    别的
      disabled_s="假"
    菲
    sed -i "${Set_disabled_num_a}"'s/"disabled": '"${Set_disabled_num_a_text}"'/"disabled": '"${disabled_s}"'/g' ${server_conf}
    echo -e "${Info} 修改成功[原禁用状态：${Set_disabled_num_a_text}，新禁用状态：${disabled_s}]"
  别的
    echo -e "${Error} 请输入正确的节点用户名！" && 退出 1
  菲
}
Set_ServerStatus_client() {
  check_installed_client_status
  Set_config_client
  读取配置客户端
  修改配置客户端
  Restart_ServerStatus_client
}
安装_vnStat() {
  如果 [[ ${release} == "archlinux" ]]; 然后
    pacman -Sy vnstat --noconfirm
    systemctl 启用 vnstat
    systemctl 启动 vnstat
    返回 0
  elif [[ ${release} == "centos" ]]; 然后
    百胜缓存
    yum -y 安装 sqlite sqlite-devel
    yum -y groupinstall "开发工具"
  elif [[ ${release} == "debian" ]]; 然后
    apt -y 更新
    apt -y install sqlite3 libsqlite3-dev build-essential
  菲
  cd "/tmp" || 返回 1
  wget --no-check-certificate https://humdi.net/vnstat/vnstat-latest.tar.gz
  tar zxvf vnstat-latest.tar.gz
  cd vnstat-*/ || 返回 1
  ./configure --prefix=/usr --sysconfdir=/etc && make && make install
  如果 ！vnstat -v >/dev/null 2>&1; 然后
    echo "编译安装vnStat失败，请手动安装vnStat"
    1号出口
  菲
  vnstatd -d
  如果 [[ ${release} == "centos" ]]; 然后
    if grep "6\..*" /etc/redhat-release | grep -i "centos" | grep -v "{^6}\.6" >/dev/null; 然后
      [[！-e /etc/init.d/vnstat ]] && cp示例/init.d/redhat/vnstat /etc/init.d/
      chkconfig vnstat on
      服务 vnstat 重启
    菲
  别的
    如果 grep -i "debian" /etc/issue | grep -q "7" || grep -i "ubuntu" /etc/issue | grep -q "14"; 然后
      [[！-e /etc/init.d/vnstat ]] && cp示例/init.d/debian/vnstat /etc/init.d/
      update-rc.d vnstat 默认值
      服务 vnstat 重启
    菲
  菲
  如果 [[ ！-e /etc/init.d/vnstat ]]; 然后
    cp -v 示例/systemd/simple/vnstat.service /etc/systemd/system/
    systemctl 启用 vnstat
    systemctl 启动 vnstat
  菲
  rm -rf vnstat*
  光盘~ || 出口
}
Modify_config_client_traffic() {
  [ -z ${isVnstat} ] && [[ ${client_vnstat_s} == "false" ]] && 返回
  如果 [[ ${isVnstat="y"} == [Yy] ]]; 然后
    vnstat -v >/dev/null 2>&1 || 安装_vnStat
    netName=$(awk '{i++; if( i>2 && ($2 != 0 && $10 != 0) ){print $1}}' /proc/net/dev | sed 's/^lo:$// g' | sed 's/^tun:$//g' | sed '/^$/d' | sed 's/^[\t]*//g' | sed 's/[:]*$/ /G'）
    如果 [ -z "$netName" ]; 然后
      echo -e "获取网卡名称失败，请在Github反馈"
      1号出口
    菲
    如果 [[ $netName =~ [[:space:]] ]]; 然后
      read -erp "检测到多个网卡：${netName}，请手动输入网卡名称" netName
    菲
    read -erp "请输入月月归零的日期(1~28)，默认为1（即月1日）：" time_N
    [[ -z "$time_N" ]] && time_N="1"
    尽管 ！[[ $time_N =~ ^[0-9]*$ ]] || ((time_N < 1 || time_N > 28)); 做
      read -erp "你输入的日期不合法，请重新输入：" time_N
    完毕
    sed -i "s/$(grep -w "MonthRotate" /etc/vnstat.conf)/MonthRotate $time_N/" /etc/vnstat.conf
    sed -i "s/$(grep -w "Interface" /etc/vnstat.conf)/Interface \"$netName\"/" /etc/vnstat.conf
    chmod -R 777 /var/lib/vnstat/
    systemctl 重启 vnstat
    如果 ！grep -q "NET_IN, NET_OUT = get_traffic_vnstat()" ${client_file}/status-client.py; 然后
      sed -i 's/\t/ /g' ${client_file}/status-client.py
      sed -i 's/NET_IN, NET_OUT = traffic.get_traffic()/NET_IN, NET_OUT = get_traffic_vnstat()/' ${client_file}/status-client.py
    菲
  elif grep -q "NET_IN, NET_OUT = get_traffic_vnstat()" ${client_file}/status-client.py; 然后
    sed -i 's/\t/ /g' ${client_file}/status-client.py
    sed -i 's/NET_IN, NET_OUT = get_traffic_vnstat()/NET_IN, NET_OUT = traffic.get_traffic()/' ${client_file}/status-client.py
  菲
}
修改配置客户端（）{
  sed -i 's/SERVER = "'"${client_server}"'"/SERVER = "'"${server_s}"'"/g' "${client_file}/status-client.py"
  sed -i "s/PORT = ${client_port}/PORT = ${server_port_s}/g" "${client_file}/status-client.py"
  sed -i 's/USER = "'"${client_user}"'"/USER = "'"${username_s}"'"/g' "${client_file}/status-client.py"
  sed -i 's/PASSWORD = "'"${client_password}"'"/PASSWORD = "'"${password_s}"'"/g' "${client_file}/status-client.py"
  修改_config_client_traffic
}
安装_jq() {
  [[ ${mirror_num} == 2 ]] && {
    github_link="https://hub.fastgit.org"
    raw_link="https://raw.fastgit.org"
  } || {
    github_link="https://github.com"
    raw_link="https://raw.githubusercontent.com"
  }
  如果 [[ ！-e ${jq_file} ]]; 然后
    如果 [[ ${bit} == "x86_64" ]]; 然后
      jq_file="${file}/jq"
      wget --no-check-certificate "${github_link}/stedolan/jq/releases/download/jq-1.5/jq-linux64" -O ${jq_file}
    elif [[ ${bit} == "i386" ]]; 然后
      jq_file="${file}/jq"
      wget --no-check-certificate "${github_link}/stedolan/jq/releases/download/jq-1.5/jq-linux32" -O ${jq_file}
    别的
      # ARM 回退到包管理器
      [[ ${release} == "archlinux" ]] && pacman -Sy jq --noconfirm
      [[ ${release} == "centos" ]] && yum -y install jq
      [[ ${release} == "debian" ]] && apt -y install jq
      jq_file="/usr/bin/jq"
    菲
    [[！-e ${jq_file} ]] && echo -e "${Error} JQ解析器下载失败，请检查！" && 退出 1
    chmod +x ${jq_file}
    echo -e "${Info} JQ解析器安装完成，继续..."
  别的
    echo -e "${Info} JQ解析器已安装，继续..."
  菲
  如果 [[ ！-e ${region_json} ]]; 然后
    wget --no-check-certificate "${raw_link}/michaelwittig/node-i18n-iso-countries/master/langs/zh.json" -O ${region_json}
    [[！-e ${region_json} ]] && echo -e "${Error} ISO 3166-1 json文件下载失败，请检查！" && exit 1
  菲
}
安装球童（）{
  回声
  echo -e "${Info} 是否由脚本自动配置HTTP服务(服务器端的在线监控网站)，如果选择N，则请在其他目录HTTP服务中配置网站根为：${Green_font_prefix}${web_file}${字体颜色后缀} [Y/n]"
  读取 -erp "(默认: Y 自动部署):" caddy_yn
  [[ -z "$caddy_yn" ]] && caddy_yn="y"
  如果 [[ "${caddy_yn}" == [Yy] ]]; 然后
    caddy_file="/etc/caddy/Caddyfile" # Archlinux中指定的默认Caddyfile在哪里？
    [[！-e /usr/bin/caddy ]] && {
      如果 [[ ${release} == "debian" ]]; 然后
        apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
        curl -1sLf "https://dl.cloudsmith.io/public/caddy/stable/gpg.key" | 三通 /etc/apt/trusted.gpg.d/caddy-stable.asc
        curl -1sLf "https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt" | 三通 /etc/apt/sources.list.d/caddy-stable.list
        易于更新 && 易于安装球童
      elif [[ ${release} == "centos" ]]; 然后
        百胜安装 yum-plugin-copr -y
        yum copr 启用@caddy/caddy -y
        yum install caddy -y
      elif [[ ${release} == "archlinux" ]]; 然后
        pacman -Sy caddy --noconfirm
      菲
      [[！-e "/usr/bin/caddy" ]] && echo -"${Error} Caddy 安装失败，请手动部署，Web 网页文件位置：${web_file}" && exit 1
      systemctl 启用球童
      回声“”>${caddy_file}
    }
    set_server "服务器"
    Set_server_http_port
    猫 >>${caddy_file} <<-EOF
http://${server_s}:${server_http_port_s} {
  根 * ${web_file}
  编码 gzip
  文件服务器
}
EOF
    systemctl 重启球童
  别的
    echo -e "${Info}跳过HTTP服务部署，请手动部署，Web网页文件位置：${web_file} ，如果更改，请注意位置服务器脚本文件 /etc/init.d/status-server 中的WEB_BIN 变量！”
  菲
}
Install_ServerStatus_server() {
  Set_Mirror
  [[ -e "${server_file}/sergate" ]] && echo -e "${Error} 检测到ServerStatus 服务端已安装！" && 退出 1
  设置服务器端口
  echo -e "${Info} 开始安装/配置依赖..."
  Installation_dependency "服务器"
  安装球童
  echo -e "${Info} 开始下载/安装..."
  下载_服务器_状态_服务器
  安装_jq
  echo -e "${Info} 开始下载/安装脚本服务(init)..."
  Service_Server_Status_server
  echo -e "${Info} 开始写入配置文件..."
  写服务器配置
  Write_server_config_conf
  echo -e "${Info}所有步骤安装完毕，开始启动..."
  Start_ServerStatus_server
}
Install_ServerStatus_client() {
  Set_Mirror
  [[ -e "${client_file}/status-client.py" ]] && echo -e "${Error} 检测到ServerStatus客户端已安装！" && 退出 1
  check_sys
  echo -e "${Info} 开始设置用户配置..."
  Set_config_client
  echo -e "${Info} 开始安装/配置依赖..."
  安装依赖“客户端”
  echo -e "${Info} 开始下载/安装..."
  下载_服务器_状态_客户端
  echo -e "${Info} 开始下载/安装脚本服务(init)..."
  Service_Server_Status_client
  echo -e "${Info} 开始写入配置..."
  读取配置客户端
  修改配置客户端
  echo -e "${Info}所有步骤安装完毕，开始启动..."
  Start_ServerStatus_client
}
Update_ServerStatus_server() {
  Set_Mirror
  check_installed_server_status
  check_pid_server
  如果 [[ -n ${PID} ]]; 然后
    如果 [[ ${release} == "archlinux" ]]; 然后
      systemctl 停止状态服务器
    别的
      /etc/init.d/status-server 停止
    菲
  菲
  下载_服务器_状态_服务器
  rm -rf /etc/init.d/status-server
  Service_Server_Status_server
  Start_ServerStatus_server
}
Update_ServerStatus_client() {
  Set_Mirror
  check_installed_client_status
  check_pid_client
  如果 [[ -n ${PID} ]]; 然后
    如果 [[ ${release} == "archlinux" ]]; 然后
      systemctl 停止状态客户端
    别的
      /etc/init.d/status-client 停止
    菲
  菲
  如果 [[ ！-e "${client_file}/status-client.py" ]]; 然后
    如果 [[ ！-e "${file}/status-client.py" ]]; 然后
      echo -e "${Error} ServerStatus 客户端文件不存在！" && 退出 1
    别的
      client_text="$(sed 's/\"//g;s/,//g;s/ //g' "${file}/status-client.py")"
      rm -rf "${file}/status-client.py"
    菲
  别的
    client_text="$(sed 's/\"//g;s/,//g;s/ //g' "${client_file}/status-client.py")"
  菲
  server_s="$(echo -e "${client_text}" | grep "SERVER=" | awk -F "="'{print $2}')"
  server_port_s="$(echo -e "${client_text}" | grep "PORT=" | awk -F "="'{print $2}')"
  username_s="$(echo -e "${client_text}" | grep "USER=" | awk -F "="'{print $2}')"
  password_s="$(echo -e "${client_text}" | grep "PASSWORD=" | awk -F "=" '{print $2}')"
  grep -q "NET_IN, NET_OUT = get_traffic_vnstat()" "${client_file}/status-client.py" && client_vnstat_s="true" || client_vnstat_s="假"
  下载_服务器_状态_客户端
  读取配置客户端
  修改配置客户端
  rm -rf /etc/init.d/status-client
  Service_Server_Status_client
  Start_ServerStatus_client
}
Start_ServerStatus_server() {
  check_installed_server_status
  check_pid_server
  [[ -n ${PID} ]] && echo -e "${Error} ServerStatus 正在运行，请检查！" && 退出 1
  如果 [[ ${release} == "archlinux" ]]; 然后
    systemctl start status-server.service
  别的
    /etc/init.d/status-server 启动
  菲
}
Stop_ServerStatus_server() {
  check_installed_server_status
  check_pid_server
  [[ -z ${PID} ]] && echo -e "${Error} ServerStatus 没有运行，请检查！" && 退出 1
  如果 [[ ${release} == "archlinux" ]]; 然后
    systemctl stop status-server.service
  别的
    /etc/init.d/status-server 停止
  菲
}
Restart_ServerStatus_server() {
  check_installed_server_status
  check_pid_server
  如果 [[ -n ${PID} ]]; 然后
    如果 [[ ${release} == "archlinux" ]]; 然后
      systemctl stop status-server.service
    别的
      /etc/init.d/status-server 停止
    菲
  菲
  如果 [[ ${release} == "archlinux" ]]; 然后
    systemctl start status-server.service
  别的
    /etc/init.d/status-server 启动
  菲
}
Uninstall_ServerStatus_server() {
  check_installed_server_status
  echo "确定要卸载ServerStatus 服务端同时安装了客户端，则删除端(如果y/N]"
  回声
  read -erp "(默认: n):" unyn
  [[ -z ${unyn} ]] && unyn="n"
  如果 [[ ${unyn} == [Yy] ]]; 然后
    check_pid_server
    [[ -n $PID ]] && kill -9 "${PID}"
    读取配置服务器
    如果 [[ -e "${client_file}/status-client.py" ]]; 然后
      rm -rf "${server_file}"
      rm -rf "${web_file}"
    别的
      rm -rf "${文件}"
    菲
    rm -rf "/etc/init.d/status-server"
    如果 [[ -e "/usr/bin/caddy" ]]; 然后
      systemctl 停止球童
      systemctl 禁用球童
      [[ ${release} == "debian" ]] && apt purge -y caddy
      [[ ${release} == "centos" ]] && yum -y 删除球童
      [[ ${release} == "archlinux" ]] && pacman -R caddy --noconfirm
    菲
    如果 [[ ${release} == "centos" ]]; 然后
      chkconfig --del 状态服务器
    elif [[ ${release} == "debian" ]]; 然后
      update-rc.d -f 状态服务器删除
    elif [[ ${release} == "archlinux" ]]; 然后
      systemctl 停止状态服务器
      systemctl 禁用状态服务器
      rm /usr/lib/systemd/system/status-server.service
    菲
    echo && echo "服务器状态装载完成！" && 回声
  别的
    echo && echo "已卸载取消..." && echo
  菲
}
Start_ServerStatus_client() {
  check_installed_client_status
  check_pid_client
  [[ -n ${PID} ]] && echo -e "${Error} ServerStatus 正在运行，请检查！" && 退出 1
  如果 [[ ${release} == "archlinux" ]]; 然后
    systemctl start status-client.service
  别的
    /etc/init.d/status-client 启动
  菲
}
Stop_ServerStatus_client() {
  check_installed_client_status
  check_pid_client
  [[ -z ${PID} ]] && echo -e "${Error} ServerStatus 没有运行，请检查！" && 退出 1
  如果 [[ ${release} == "archlinux" ]]; 然后
    systemctl stop status-client.service
  别的
    /etc/init.d/status-client 停止
  菲
}
Restart_ServerStatus_client() {
  check_installed_client_status
  check_pid_client
  如果 [[ -n ${PID} ]]; 然后
    如果 [[ ${release} == "archlinux" ]]; 然后
      systemctl restart status-client.service
    别的
      /etc/init.d/status-client 重启
    菲
  菲
}
Uninstall_ServerStatus_client() {
  check_installed_client_status
  echo "确定要删除ServerStatus客户端(如果同时卸载了服务端，则删除安装客户端) ? [y/N]"
  回声
  read -erp "(默认: n):" unyn
  [[ -z ${unyn} ]] && unyn="n"
  如果 [[ ${unyn} == [Yy] ]]; 然后
    check_pid_client
    [[ -n $PID ]] && kill -9 "${PID}"
    读取配置客户端
    如果 [[ -e "${server_file}/sergate" ]]; 然后
      rm -rf "${client_file}"
    别的
      rm -rf "${文件}"
    菲
    rm -rf /etc/init.d/status-client
    如果 [[ ${release} == "centos" ]]; 然后
      chkconfig --del 状态客户端
    elif [[ ${release} == "debian" ]]; 然后
      update-rc.d -f status-client 删除
    elif [[ ${release} == "archlinux" ]]; 然后
      systemctl 停止状态客户端
      systemctl 禁用状态客户端
      rm /usr/lib/systemd/system/status-client.service
    菲
    echo && echo "服务器状态装载完成！" && 回声
  别的
    echo && echo "已卸载取消..." && echo
  菲
}
View_ServerStatus_client() {
  check_installed_client_status
  读取配置客户端
  清除&&回声“—————————————————————” &&回声
  echo -e " ServerStatus 客户端配置信息：

  IP \t: ${Green_font_prefix}${client_server}${Font_color_suffix}
  端口 \\t: ${Green_font_prefix}${client_port}${Font_color_suffix}
  \t: ${Green_font_prefix}${client_user}${Font_color_suffix}
  密码 \t: ${Green_font_prefix}${client_password}${Font_color_suffix}
  vnStat : ${Green_font_prefix}${client_vnstat}${Font_color_suffix}

—————————————————————”
}
View_client_Log() {
  [[！-e ${client_log_file} ]] && echo -e "${Error} 没有找到日志文件！" && 退出 1
  echo && echo -e "${Tip} 按${Red_font_prefix}Ctrl+C${Font_color_suffix} 结束查看日志" && echo -e "查看需要完整的日志内容，请用${Red_font_prefix}cat ${client_log_file}$ {Font_color_suffix} 命令。” && echo
  尾 -f ${client_log_file}
}
View_server_Log() {
  [[！-e ${server_log_file} ]] && echo -e "${Error} 没有找到日志文件！" && 退出 1
  echo && echo -e "${Tip} 按${Red_font_prefix}Ctrl+C${Font_color_suffix} 结束查看日志" && echo -e "查看需要完整的日志内容，请用${Red_font_prefix}cat ${server_log_file}$ {Font_color_suffix} 命令。” && echo
  尾 -f ${server_log_file}
}
更新壳（）{
  Set_Mirror
  sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "${link_prefix}/status.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | 头 -1)
  [[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 Github ！" && 退出 0
  如果 [[ -e "/etc/init.d/status-client" ]] || [[ -e "/usr/lib/systemd/system/status-client.service" ]]; 然后
    rm -rf /etc/init.d/status-client
    rm -rf /usr/lib/systemd/system/status-client.service
    Service_Server_Status_client
  菲
  如果 [[ -e "/etc/init.d/status-server" ]] || [[ -e "/usr/lib/systemd/system/status-server.service" ]]; 然后
    rm -rf /etc/init.d/status-server
    rm -rf /usr/lib/systemd/system/status-server.service
    Service_Server_Status_server
  菲
  wget -N --no-check-certificate "${link_prefix}/status.sh" && chmod +x status.sh
  echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接当前运行的脚本，所以下面可能会提示一些报错，无视功能)" && exit 0
}
菜单客户端（）{
  echo && echo -e " ServerStatus 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- 东洋 | doub.io/shell-jc3 --
  -- 由 APTX 修改 --
 ${Green_font_prefix} 0.${Font_color_suffix} 升级脚本
 ————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装客户端
 ${Green_font_prefix} 2.${Font_color_suffix} 更新客户端
 ${Green_font_prefix} 3.${Font_color_suffix} 卸载客户端
————————————
 ${Green_font_prefix} 4.${Font_color_suffix} 启动客户端
 ${Green_font_prefix} 5.${Font_color_suffix} 停止客户端
 ${Green_font_prefix} 6.${Font_color_suffix} 重启客户端
————————————
 ${Green_font_prefix} 7.${Font_color_suffix} 设置客户端配置
 ${Green_font_prefix} 8.${Font_color_suffix} 查看客户端信息
 ${Green_font_prefix} 9.${Font_color_suffix} 查看客户端日志
————————————
 ${Green_font_prefix}10.${Font_color_suffix} 切换为服务端菜单" && echo
  如果 [[ -e "${client_file}/status-client.py" ]]; 然后
    check_pid_client
    如果 [[ -n "${PID}" ]]; 然后
      echo -e "当前状态：客户端${Green_font_prefix}已安装${Font_color_suffix}并${Green_font_prefix}已启动${Font_color_suffix}"
    别的
      echo -e "当前状态：客户端${Green_font_prefix}已安装${Font_color_suffix}但${Red_font_prefix}未启动${Font_color_suffix}"
    菲
  别的
    如果 [[ -e "${file}/status-client.py" ]]; 然后
      check_pid_client
      如果 [[ -n "${PID}" ]]; 然后
        echo -e "当前状态：客户端${Green_font_prefix}已安装${Font_color_suffix}并${Green_font_prefix}已启动${Font_color_suffix}"
      别的
        echo -e "当前状态：客户端${Green_font_prefix}已安装${Font_color_suffix}但${Red_font_prefix}未启动${Font_color_suffix}"
      菲
    别的
      echo -e "当前状态：客户端${Red_font_prefix}未安装${Font_color_suffix}"
    菲
  菲
  回声
  read -erp " 请输入数字 [0-10]:" num
  案例“$num”在
  0)
    Update_Shell
    ;;
  1)
    Install_ServerStatus_client
    ;;
  2)
    Update_ServerStatus_client
    ;;
  3)
    Uninstall_ServerStatus_client
    ;;
  4)
    Start_ServerStatus_client
    ;;
  5)
    Stop_ServerStatus_client
    ;;
  6)
    Restart_ServerStatus_client
    ;;
  7)
    Set_ServerStatus_client
    ;;
  8)
    View_ServerStatus_client
    ;;
  9)
    View_client_Log
    ;;
  10)
    菜单服务器
    ;;
  *)
    echo "请输入正确的数字 [0-10]"
    ;;
  经社理事会
}
菜单服务器（）{
  echo && echo -e " ServerStatus 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- 东洋 | doub.io/shell-jc3 --
  -- 由 APTX 修改 --
 ${Green_font_prefix} 0.${Font_color_suffix} 升级脚本
 ————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装服务端
 ${Green_font_prefix} 2.${Font_color_suffix} 更新服务端
 ${Green_font_prefix} 3.${Font_color_suffix} 卸载服务端
————————————
 ${Green_font_prefix} 4.${Font_color_suffix} 启动服务端
 ${Green_font_prefix} 5.${Font_color_suffix} 停止服务端
 ${Green_font_prefix} 6.${Font_color_suffix} 重启服务端
————————————
 ${Green_font_prefix} 7.${Font_color_suffix} 设置服务端配置
 ${Green_font_prefix} 8.${Font_color_suffix} 查看服务端信息
 ${Green_font_prefix} 9.${Font_color_suffix} 查看服务端日志
————————————
 ${Green_font_prefix}10.${Font_color_suffix} 切换为客户端菜单" && echo
  如果 [[ -e "${server_file}/sergate" ]]; 然后
    check_pid_server
    如果 [[ -n "${PID}" ]]; 然后
      echo -e "当前状态：服务端${Green_font_prefix}已安装${Font_color_suffix}并${Green_font_prefix}已启动${Font_color_suffix}"
    别的
      echo -e "当前状态：服务端${Green_font_prefix}已安装${Font_color_suffix}但${Red_font_prefix}未启动${Font_color_suffix}"
    菲
  别的
    echo -e "当前状态：服务端${Red_font_prefix}未安装${Font_color_suffix}"
  菲
  回声
  read -erp " 请输入数字 [0-10]:" num
  案例“$num”在
  0)
    Update_Shell
    ;;
  1)
    Install_ServerStatus_server
    ;;
  2)
    Update_ServerStatus_server
    ;;
  3)
    Uninstall_ServerStatus_server
    ;;
  4)
    Start_ServerStatus_server
    ;;
  5)
    Stop_ServerStatus_server
    ;;
  6)
    Restart_ServerStatus_server
    ;;
  7)
    Set_ServerStatus_server
    ;;
  8)
    List_ServerStatus_server
    ;;
  9)
    View_server_Log
    ;;
  10)
    菜单客户端
    ;;
  *)
    echo "请输入正确的数字 [0-10]"
    ;;
  经社理事会
}
Set_Mirror() {
  echo -e "${Info} 请输入要选择的下载源，默认使用GitHub，中国大陆选择Coding.net，但不建议将服务端部署在中国大陆主机上
  ${Green_font_prefix} 1.${Font_color_suffix} GitHub
  ${Green_font_prefix} 2.${Font_color_suffix} Coding.net (部分资源通过 FastGit 提供服务下载，感谢 FastGit.org 的服务)"
  read -erp "请输入数字[1-2]，默认为1：" mirror_num
  [[ -z "${mirror_num}" ]] && mirror_num=1
  [[ ${mirror_num} == 2 ]] && link_prefix=${coding_prefix} || 链接前缀=${github_prefix}
}
check_sys
行动=$1
如果 [[ -n $action ]]; 然后
  如果 [[ $action == "s" ]]; 然后
    菜单服务器
  elif [[ $action == "c" ]]; 然后
    菜单客户端
  菲
别的
  菜单客户端
菲
