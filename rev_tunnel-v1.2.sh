#!/bin/bash
# Por C0nt05

# Definindo cores
vermelha='\033[0;31m'
verde='\033[0;32m'
amarelo='\033[0;33m'
azul='\033[0;34m'
rosa='\033[0;35m'
cinza='\033[0;90m'
sem_cor='\033[0m'

# Versão do script
versao="1.2"

# Solicita e valida a porta
get_port() {
    local port
    read -r port
    port=${port:-80} # Porta padrão é 80

    # Verifica se a porta é um número válido
    if ! [[ $port =~ ^[0-9]+$ ]] || [ $port -le 0 ] || [ $port -gt 65535 ]; then
        echo -e "${vermelha}Porta inválida. Por favor, insira um número entre 1 e 65535.${sem_cor}"
        return 1
    fi

    echo $port
}

# Solicita o nome da VPN
get_vpn_name() {
    local vpn_name
    read -r vpn_name

    if [ -z "$vpn_name" ]; then
        echo -e "${vermelha}Nome da VPN não pode ser vazio.${sem_cor}"
        return 1
    fi

    echo $vpn_name
}

# Função para instalar o proxy
install_proxy() {
    clear
    echo ""
    if [ -f /usr/bin/proxy.bak ]; then
        echo -e " ${azul}*${sem_cor} ${amarelo}Um backup do proxy já existe. Instalação cancelada para evitar sobrescrever o backup.${sem_cor}"
        echo ""
        return
    fi
    if [ -f /usr/bin/proxy ]; then
        mv /usr/bin/proxy /usr/bin/proxy.bak
        echo -e "${amarelo}Backup do proxy atual salvo como proxy.bak${sem_cor}"
    fi
    curl -s -L -o /usr/bin/proxy https://github.com/RevTunnel/ProxyCracked/raw/main/DT%201.2.5/X86/proxy
    chmod +x /usr/bin/proxy
    clear
    echo ""
    echo -e "${verde}Proxy instalado com sucesso!${sem_cor}"
    echo ""
}

# Função para restaurar o proxy original
restore_proxy() {
    clear
    echo ""
    if [ -f /usr/bin/proxy.bak ]; then
        mv /usr/bin/proxy.bak /usr/bin/proxy
        echo -e " ${verde}*${sem_cor} Proxy original restaurado com sucesso."
        echo ""
    else
        echo ""
        echo -e "${vermelha}Backup do proxy não encontrado.${sem_cor}"
        echo ""
    fi
}

# Função para listar portas em execução
list_ports() {
    echo -e "${amarelo}Portas em execução:${sem_cor}"
    netstat -tuln | grep LISTEN
}

# Função para matar processo em uma porta específica
kill_port() {
    clear
    echo ""
    echo -n "Digite a porta para encerrar o processo: "
    read port
    pid=$(lsof -t -i:$port)
    if [ -n "$pid" ]; then
        kill $pid
        echo -e "${verde}Processo na porta $port encerrado.${sem_cor}"
    else
        echo -e "${vermelha}Nenhum processo encontrado na porta $port.${sem_cor}"
    fi
}

# Função para executar o proxy com configurações específicas
run_proxy() {
    clear
    echo ""
    echo -e "${azul}Iniciando configuração do proxy...${sem_cor}" && sleep 1
    echo -e "Digite a porta para o proxy e pressione Enter ${cinza}(padrão 80)${sem_cor}:"

    local port=$(get_port)
    if [ $? -ne 0 ]; then
        return
    fi

    echo "Solicitando nome da VPN..."
    local vpn_name=$(get_vpn_name)
    if [ $? -ne 0 ]; then
        echo -e "${vermelha}Erro ao obter o nome da VPN.${sem_cor}"
        return
    fi

    local mode=$1
    local command="/usr/bin/proxy --port $port --http --response $vpn_name"

    case $mode in
        "ssh") command="$command --ssh-only" ;;
        "openvpn") command="$command --openvpn-port" ;;
    esac
    echo ""
    echo -e "Proxy executando na porta ${verde}$port${sem_cor} com configuração: ${azul}$mode${sem_cor} e VPN: ${rosa}$vpn_name${sem_cor}"
    echo ""
    screen -dmS proxy $command
}

# Menu principal
clear
while true; do
    echo -e "   ${azul}DTPROXY ${sem_cor} - ${amarelo}$versao${sem_cor}"
    echo ""
    echo -e "1. ${verde}Instalar/Atualizar Proxy${sem_cor}"
    echo -e "2. ${amarelo}Restaurar Proxy Original${sem_cor}"
    echo -e "3. ${verde}Executar Proxy com HTTP e SSH${sem_cor}"
    echo -e "4. ${verde}Executar Proxy com HTTP e OpenVPN${sem_cor}"
    echo -e "5. ${azul}Listar portas em execução${sem_cor}"
    echo -e "6. ${rosa}Encerrar processo em uma porta${sem_cor}"
    echo -e "0. ${vermelha}Sair${sem_cor}"
    echo ""
    echo -n "Escolha uma opção: "
    read option

    case $option in
        1) install_proxy ;;
        2) restore_proxy ;;
        3) run_proxy "ssh" ;;
        4) run_proxy "openvpn" ;;
        5) list_ports ;;
        6) kill_port ;;
        0) break ;;
        *) echo -e "${vermelha}Opção inválida.${sem_cor}" ;;
    esac
done
