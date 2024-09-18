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
    screen -dmS pingpong
    echo "screen installed and session 'pingpong' created."
}

# 函数：添加设备ID并运行 PingPong 应用（在新的 screen 会话中）
add_device_id() {
    read -p "请输入你的设备ID: " device_id
    if [[ -z "$device_id" ]]; then
        echo "设备ID不能为空，请重试。"
    else
        echo "Starting PingPong app in a new screen session with your device ID..."
        screen -dmS pingpong_id bash -c "cd $HOME && sudo ./PINGPONG --key \"$device_id\"; exec bash"
        echo "PingPong app started with your device ID in screen session 'pingpong_id'."
        echo "请使用以下命令进入该会话，并执行相关操作："
        echo "screen -r pingpong_id"
    fi
}

# 函数：配置 AIOZ 账户（在新的 screen 会话中）
configure_aioz() {
    read -p "请输入你的 AIOZ 账户: " aioz_account
    if [[ -z "$aioz_account" ]]; then
        echo "AIOZ 账户不能为空，请重试。"
    else
        echo "配置 AIOZ 并运行相关命令..."
        screen -dmS aioz_config bash -c "cd $HOME && sudo ./PINGPONG config set --aioz=\"$aioz_account\" && sudo ./PINGPONG stop --depins=aioz && sudo ./PINGPONG start --depins=aioz; exec bash"
        echo "AIOZ 配置完成并已启动，在 screen 会话 'aioz_config' 中执行。"
        echo "请使用以下命令进入该会话，并执行相关操作："
        echo "screen -r aioz_config"
    fi
}

# 函数：查看日志 (Ctrl + A + D 退出)
view_logs() {
    echo "Viewing logs in screen session 'pingpong'..."
    echo "按 Ctrl + A + D 退出日志查看。"
    screen -r pingpong
}

# 菜单选项
show_menu() {
    echo "请选择一个操作:"
    echo "1. 安装 Docker"
    echo "2. 下载和安装 PingPong 应用"
    echo "3. 安装 screen 并创建 PingPong 会话"
    echo "4. 添加设备ID并运行 PingPong 应用（新 screen 会话）"
    echo "5. 查看日志 (Ctrl + A + D 退出)"
    echo "6. 配置 AIOZ 账户（新 screen 会话）"
    echo "7. 退出"
}

# 主循环
while true; do
    show_menu
    read -p "请输入选项 (1/2/3/4/5/6/7): " choice
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
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效选项，请输入 1, 2, 3, 4, 5, 6 或 7."
            ;;
    esac
done
