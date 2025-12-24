Для установки VS Code в виде веб-сервиса (code-server) на AlmaLinux используйте официальный скрипт установки, который автоматически настроит systemd-сервис. Это позволит запускать VS Code через браузер по адресу http://your-server-ip:8080. После установки настройте конфигурацию для внешнего доступа и откройте порт в firewall.

## Подготовка системы
Обновите пакеты и установите необходимые утилиты.
```
sudo dnf update -y
sudo dnf install curl nano -y
```

## Установка code-server
Выполните официальный скрипт установки, который автоматически установит code-server и создаст systemd-сервис для вашего пользователя.
```
curl -fsSL https://code-server.dev/install.sh | sh
```

## Запуск сервиса
Запустите и включите автозапуск сервиса для текущего пользователя.
```
sudo systemctl enable --now code-server@$USER
sudo systemctl status code-server@$USER
```

## Настройка для внешнего доступа
Отредактируйте конфиг для прослушивания всех интерфейсов (по умолчанию только localhost).
```
nano ~/.config/code-server/config.yaml
```
Измените `bind-addr: 127.0.0.1:8080` на `bind-addr: 0.0.0.0:8080`. Пароль для входа указан в этом файле. Перезапустите сервис:
```
sudo systemctl restart code-server@$USER
```

## Настройка firewall
Откройте порт 8080 (и опционально 80/443 для HTTPS).
```
sudo firewall-cmd --add-port={8080,80,443}/tcp --permanent
sudo firewall-cmd --reload
```

## Доступ к интерфейсу
Откройте в браузере `http://your-server-ip:8080`, введите пароль из `~/.config/code-server/config.yaml`. Для HTTPS настройте Nginx как reverse proxy с Let's Encrypt.

[8](https://orcacore.com/install-visual-studio-code-almalinux-9/)
[9](https://skillbox.ru/media/code/visual-studio-code-ustanovka-nastroyka-rusifikatsiya-i-spisok-goryachikh-klavish/)
[10](https://coder.com/docs/code-server/install)
