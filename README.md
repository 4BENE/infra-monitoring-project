## Инструкция по запуску

### 1. Проверка окружения
```bash
git --version
docker --version
docker compose version
```
Проверяет, что установлены Git и Docker. Если какая-то команда не найдена, соответствующий инструмент нужно установить.

### 2. Сделать скрипты исполняемыми
```bash
chmod +x check_api.sh analyze_logs.sh
```
Даёт право запускать скрипты как программы.

```bash
ls -l check_api.sh analyze_logs.sh
```
Проверяет права: в начале строки должна быть буква `x` (например, `-rwxr-xr-x`).

### 3. Проверка синтаксиса скриптов
```bash
bash -n check_api.sh
bash -n analyze_logs.sh
```
Проверяет синтаксис без выполнения. Если ошибок нет, команды ничего не выводят.

### 4. Анализ логов
```bash
./analyze_logs.sh
```
Генерирует `access.log` (400 строк) и выводит общее число запросов, топ-3 IP-адреса и количество ответов с кодами 4xx и 5xx.

```bash
head -5 access.log
wc -l access.log
```
Показывает первые 5 строк сгенерированного лога и подтверждает количество строк.

### 5. Проверка доступности API

Валидный URL:
```bash
./check_api.sh https://httpbin.org/status/200
echo "Код возврата: $?"
```
Выводит «API доступен», код возврата 0.

Невалидный URL (сервер вернул ошибку):
```bash
./check_api.sh https://httpbin.org/status/500
echo "Код возврата: $?"
```
Выводит «API недоступен, код ответа: 500», код возврата 1.

Несуществующий домен:
```bash
./check_api.sh https://nonexistent-domain.com
echo "Код возврата: $?"
```
Выводит «API недоступен, код ответа: 000» (соединение не установлено), код возврата 1.

Запуск без аргумента:
```bash
./check_api.sh
```
Выводит подсказку по использованию и возвращает код 1.

### 6. Запуск контейнеров
Перед запуском убедитесь, что Docker Desktop запущен (статус Engine running).

```bash
docker compose config
```
Проверяет корректность `docker-compose.yml` и показывает итоговую конфигурацию.

```bash
docker compose up -d
```
Скачивает образы (при первом запуске) и поднимает сервисы `api` (hashicorp/http-echo) и `proxy` (nginx:alpine) в фоновом режиме.

```bash
docker compose ps
```
Показывает список контейнеров и их статус (должны быть в состоянии `running`).

```bash
curl http://localhost:80
```
Проверяет работу прокси. Ожидаемый ответ: `Monitoring Service Active`.

```bash
docker compose logs
```
Выводит логи обоих сервисов (полезно при отладке).

```bash
docker compose down
```
Останавливает и удаляет контейнеры и сеть.

### 7. Работа с Git и CI/CD
```bash
git status
git branch
```
Показывает состояние рабочей директории и текущую ветку (должна быть `feature/monitoring`).

```bash
git add .
git commit -m "Описание изменений"
git push
```
Добавляет изменения, фиксирует их и отправляет в GitHub.

После создания Pull Request в `main` автоматически запускается пайплайн (вкладка Actions в GitHub). Он выполняет те же проверки, которые можно запустить локально:
```bash
bash -n check_api.sh
bash -n analyze_logs.sh
./check_api.sh https://httpbin.org/status/200
```
Первые две команды проверяют синтаксис, третья тестирует мониторинг (ожидается код возврата 0).



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


