#!/bin/bash

# 函数：安装 Docker
install_docker() {
    echo "Updating package lists and installing Docker dependencies..."
    sudo apt update -y && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    echo "Adding Docker GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "Adding Docker repository..."
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

    echo "Installing Docker..."
    sudo apt update -y && sudo apt install -y docker-ce

    docker_version=$(docker --version)
    if [[ $? -eq 0 ]]; then
        echo "Docker installed successfully: $docker_version"
    else
        echo "Docker installation failed. Exiting."
        exit 1
    fi
}

# 函数：下载和安装 PingPong 应用
install_pingpong() {
    echo "Downloading PingPong app..."
    cd $HOME && sudo rm -rf PINGPONG && wget https://pingpong-build.s3.ap-southeast-1.amazonaws.com/linux/latest/PINGPONG

    echo "Making PingPong app executable..."
    chmod +x PINGPONG

    echo "PingPong app is ready. Use the '添加设备ID' option in the menu to start the app."
}

# 函数：安装 screen 并创建会话
install_and_create_screen_session() {
    echo "Installing screen..."
    sudo apt install -y screen
    echo "Creating a new screen session for PingPong app..."
    screen -dmS pingpong_main
    echo "screen installed and session 'pingpong_main' created."
}

# 函数：添加设备ID并运行 PingPong 应用（在 screen 会话中）
add_device_id() {
    read -p "请输入你的设备ID: " device_id
    if [[ -z "$device_id" ]]; then
        echo "设备ID不能为空，请重试。"
    else
        echo "Entering screen session 'pingpong_main' to run PingPong app..."
        screen -S pingpong_main -X stuff "sudo ./PINGPONG --key \"$device_id\"\n"
        echo "PingPong app started with your device ID."
    fi
}

# 函数：配置 AIOZ 账户（无需创建新的 screen 会话）
configure_aioz() {
    read -p "请输入你的 AIOZ 账户: " aioz_account
    if [[ -z "$aioz_account" ]]; then
        echo "AIOZ 账户不能为空，请重试。"
    else
        echo "配置 AIOZ 并运行相关命令..."
        sudo ./PINGPONG config set --aioz="$aioz_account" && sudo ./PINGPONG stop --depins=aioz && sudo ./PINGPONG start --depins=aioz
        echo "AIOZ 配置完成。"
    fi
}

# 函数：配置 0g 钱包
configure_0g() {
    read -p "请输入你的钱包私钥: " wallet_key
    if [[ -z "$wallet_key" ]]; then
        echo "钱包私钥不能为空，请重试。"
    else
        echo "配置 0g 并运行相关命令..."
        sudo ./PINGPONG config set --0g="$wallet_key" && sudo ./PINGPONG stop --depins=0g && sudo ./PINGPONG start --depins=0g
        echo "0g 配置完成。"
    fi
}

# 函数：配置 Blockmesh
configure_blockmesh() {
    read -p "请输入你的 blockmesh 邮箱: " blockmesh_email
    read -p "请输入你的 blockmesh 密码: " blockmesh_pwd
    if [[ -z "$blockmesh_email" || -z "$blockmesh_pwd" ]]; then
        echo "邮箱和密码不能为空，请重试。"
    else
        echo "配置 Blockmesh 并运行相关命令..."
        sudo ./PINGPONG config set --blockmesh.email="$blockmesh_email" --blockmesh.pwd="$blockmesh_pwd" && sudo ./PINGPONG stop --depins=blockmesh && sudo ./PINGPONG start --depins=blockmesh
        echo "Blockmesh 配置完成。"
    fi
}

# 函数：下载 NESA 镜像
download_nesa_images() {
    echo "Downloading NESA images..."
    docker pull pingpongbuild/nesa:20240913
    docker pull ghcr.io/nesaorg/orchestrator:devnet-latest
    echo "NESA 镜像下载完成。"
}

# 函数：配置 NESA
configure_nesa() {
    echo "配置 NESA 并运行相关命令..."
    sudo ./PINGPONG stop --depins=nesa && sudo ./PINGPONG start --depins=nesa
    echo "NESA 配置完成。"
}

# 函数：查看日志 (Ctrl + A + D 退出)
view_logs() {
    echo "Viewing logs in screen session 'pingpong_main'..."
    echo "按 Ctrl + A + D 退出日志查看。"
    screen -r pingpong_main
}

# 函数：删除所有相关的会话
delete_sessions() {
    echo "Deleting all related screen sessions..."
    screen -ls | grep -E 'pingpong_main|aioz_config' | awk '{print $1}' | xargs -I {} screen -S {} -X quit
    echo "All related sessions deleted."
}

# 菜单选项
show_menu() {
    echo "请选择一个操作:"
    echo "1. 安装 Docker"
    echo "2. 下载和安装 PingPong 应用"
    echo "3. 安装 screen 并创建 PingPong 会话"
    echo "4. 添加设备ID并运行 PingPong 应用（新 screen 会话）"
    echo "5. 查看日志 (Ctrl + A + D 退出)"
    echo "6. 配置 AIOZ 账户"
    echo "7. 配置 0g 钱包"
    echo "8. 配置 Blockmesh"
    echo "9. 下载 NESA 镜像"
    echo "10. 配置 NESA"
    echo "11. 删除所有相关会话"
    echo "12. 退出"
}

# 主循环
while true; do
    show_menu
    read -p "请输入选项 (1-12): " choice
    case $choice in
        1)
            install_docker
            ;;
        2)
            install_pingpong
            ;;
        3)
            install_and_create_screen_session
            ;;
        4)
            add_device_id
            ;;
        5)
            view_logs
            ;;
        6)
            configure_aioz
            ;;
        7)
            configure_0g
            ;;
        8)
            configure_blockmesh
            ;;
        9)
            download_nesa_images
            ;;
        10)
            configure_nesa
            ;;
        11)
            delete_sessions
            ;;
        12)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效选项，请输入 1 到 12."
            ;;
    esac
done
