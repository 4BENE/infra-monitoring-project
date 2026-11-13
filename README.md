## Безопасная передача файлов проекта на удалённый сервер (SSH/SCP)

### 1. Генерация SSH-ключей

ssh-keygen -t ed25519 -C "devops@infra-monitoring"

Создаётся пара ключей: приватный `~/.ssh/id_ed25519` и публичный `~/.ssh/id_ed25519.pub`.

### 2. Копирование публичного ключа на сервер

ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server_ip

После этого вход на сервер выполняется по ключу, без пароля.

### 3. Передача архива проекта

tar -czf project.tar.gz --exclude='.git' --exclude='*.log' .
scp project.tar.gz user@server_ip:/home/user/

### 4. Деплой на сервере

ssh user@server_ip "mkdir -p ~/infra-monitoring && tar -xzf ~/project.tar.gz -C ~/infra-monitoring"
ssh user@server_ip "cd ~/infra-monitoring && docker compose up -d"
