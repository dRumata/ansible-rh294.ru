#!/bin/bash
echo -e "\n\033[32m [ TASK ]\033[37m - Установка ПО\n"

sudo dnf install mc neovim htop tmux gcc-c++ zsh neofetch fish git -y
sudo systemctl enable --now cockpit.socket
sudo firewall-cmd --add-port=9090/tcp
sudo firewall-cmd --add-port=9090/tcp --permanent
sudo systemctl enable --now cockpit.socket

echo -e "\n\033[32m [ TASK ]\033[37m - Настраиваем tmux\n"
tee $HOME/.tmux.conf << _EOF_
set -g mouse on
set -g status-style bg=black
set -g window-status-current-style bg=yellow,fg=black,bold
set -g status-right '#(curl -s wttr.in/Hamburg:Москва:Челябинск:Иркутск:Владивосток\?format\="%%l:+%%c%%20%%t%%60%%w&period=20") ...'
#set -g status-right '#(curl "wttr.in/?format=3") '
set -g default-terminal "tmux-256color"

set -g status-interval 10
set -g status-left-length 30
set -g status-left '#[fg=green]#(cut -d " " -f 1-3 /proc/loadavg)#[default] #[fg=cyan]%H:%M#[default] '
_EOF_

echo -e "\n\033[32m [ TASK ]\033[37m - Настраиваем neovim\n"
mkdir -p ~/.local/share/fonts
cd /tmp/
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/MartianMono.zip && unzip MartianMono.zip -d ~/.local/share/fonts/
cd
git clone https://github.com/NvChad/starter ~/.config/nvim
sudo mkdir /root/.config
sudo cp ~/.config/nvim /root/.config/nvim -R
echo "alias vim=nvim"|tee -a ~/.bashrc
echo -e '\n\033[31m--------------------------------------\nВНИМАНИЕ!!! При первом запуске nvim или vim будет произведена инициализация и настройка плагинов.\n--------------------------------------\033[37m\n'

echo -e "\033[32m [ TASK ]\033[37m - Настраиваем bashrc\n"
tee -a $HOME/.bashrc << _EOF_
neofetch; who -a
echo "Tmux sessions:"; tmux ls
_EOF_
tee $HOME/.config/fish/conf.d/neo.fish << _EOF_
if status is-interactive
    # Commands to run in interactive sessions can go here
  neofetch; who -a
  echo "Tmux sessions:"; tmux ls
end
_EOF_



# Настройка стенда
# Дата: 19.03.2024

# Ввод значений переменных
echo -e "\n\033[32m [ TASK ]\033[37m - Ввод значений переменных\n"
echo -n "Домен для имен ВМ в виде imyafamilia: "
read suffix
echo -n "Адрес /24 подсети без последнего октета  [172.16.195]: "
read netaddr
netaddr=${netaddr:=172.16.195}

echo -n "IP адреc (только 4-й октет) сервера ws.$suffix.example.com [100]: "
read wsip
wsip=${wsip:=100}

echo -n "IP адреc (только 4-й октет) сервера servera.$suffix.example.com [101]: "
read s1ip
s1ip=${s1ip:=101}

echo -n "IP адреc (только 4-й октет) сервера serverb.$suffix.example.com [102]: "
read s2ip
s2ip=${s2ip:=102}

echo -n "IP адреc (только 4-й октет) сервера serverc.$suffix.example.com [103]: "
read s3ip
s3ip=${s3ip:=103}

echo -n "IP адреc (только 4-й октет) сервера serverd.$suffix.example.com [104]: "
read s4ip
s4ip=${s4ip:=104}

# Исправляем /etc/hosts
echo -e "\n\033[32m [ TASK ]\033[37m - Исправляем /etc/hosts\n"
sudo tee -a /etc/hosts << _EOF_
$netaddr.$wsip ws-$suffix.lab.example.com ws-$suffix ws
$netaddr.$s1ip servera.$suffix.example.com servera.lab.example.com servera sa
$netaddr.$s2ip serverb.$suffix.example.com serverb.lab.example.com serverb sb
$netaddr.$s3ip serverc.$suffix.example.com serverc.lab.example.com serverc sc
$netaddr.$s4ip serverd.$suffix.example.com serverd.lab.example.com serverd sd
_EOF_

# Переименовываем хосты
echo -e "\n\033[32m [ TASK ]\033[37m - Переименовываем хосты\n"
sudo hostnamectl set-hostname ws.$suffix.example.com
ssh student@sa -t "hostnamectl set-hostname servera.$suffix.example.com"
ssh student@sb -t "hostnamectl set-hostname serverb.$suffix.example.com"
ssh student@sc -t "hostnamectl set-hostname serverc.$suffix.example.com"
ssh student@sd -t "hostnamectl set-hostname serverd.$suffix.example.com"
