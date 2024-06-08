# StrongSwan VPN на основе Alpine Linux

Этот проект представляет собой Docker-контейнер для развёртывания VPN на основе StrongSwan и Alpine Linux.

## Использование

### Установка

##### Установите Docker на вашем сервере.
[Docker Engine](https://docs.docker.com/engine/install/)
##### Склонируйте репозиторий:

   ```bash
   git clone https://github.com/username/alpine-strongswan-vpn.git
   ```
##### Перейдите в каталог проекта:
```bash
cd alpine-strongswan-vpn
```
##### Соберите Docker-образ:
```bash
docker-compose build
```
##### Настройка
Отредактируйте конфигурационные файлы *config/strongswan.conf, config/ipsec.conf, config/ipsec.secrets* в соответствии с вашими потребностями.
##### Проверьте конфигурацию StrongSwan перед запуском:
```bash
docker-compose run --rm strongswan ipsec check
```
##### Запустите контейнер:
```bash
docker-compose up -d
```
##### Проверка статуса
Чтобы проверить статус StrongSwan, выполните следующую команду:
```bash
docker-compose exec strongswan ipsec statusall
```
##### Чтобы остановить контейнер:
```bash
docker-compose down
```
