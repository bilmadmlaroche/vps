#!/bin/bash

clear

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
CYN='\033[0;36m'
YEL='\033[1;33m'
NC='\033[0m'

# BANNER
echo -e "${YEL}"
cat << "EOF"
██████╗  █████╗ ██╗  ██╗███╗   ███╗██╗██████╗ ██████╗ ██╗███╗   ██╗
██╔══██╗██╔══██╗██║  ██║████╗ ████║██║██╔══██╗██╔══██╗██║████╗  ██║
██████╔╝███████║███████║██╔████╔██║██║██║  ██║██║  ██║██║██╔██╗ ██║
██╔══██╗██╔══██║██╔══██║██║╚██╔╝██║██║██║  ██║██║  ██║██║██║╚██╗██║
██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║██║██████╔╝██████╔╝██║██║ ╚████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝

██╗   ██╗██████╗ ███████╗
██║   ██║██╔══██╗██╔════╝
██║   ██║██████╔╝███████╗
╚██╗ ██╔╝██╔═══╝ ╚════██║
 ╚████╔╝ ██║     ███████║
  ╚═══╝  ╚═╝     ╚══════╝
EOF
echo -e "${NC}"

echo -e "${GRN}🔥 RAHMIDDIN VPS INSTALLER 🔥${NC}"
sleep 1

echo -e "${YEL}X-> Docker o‘rnatilmoqda...${NC}"
apt update
apt install docker.io docker-compose -y
systemctl start docker
systemctl enable docker

echo -e "${CYN}X-> Papkalar yaratilmoqda...${NC}"
mkdir -p pterodactyl/panel
cd pterodactyl/panel || exit

echo -e "${CYN}X-> docker-compose yozilmoqda...${NC}"

cat <<EOF > docker-compose.yml
version: '3.8'

x-common:
  database:
    &db-environment
    MYSQL_PASSWORD: "RahmiddinRoot321"
    MYSQL_ROOT_PASSWORD: "RootBoot4321"
  panel:
    &panel-environment
    APP_URL: "https://pterodactyl.example.com"
    APP_TIMEZONE: "Asia/Tashkent"
    APP_SERVICE_AUTHOR: "admin@gmail.com"
    TRUSTED_PROXIES: "*"
  mail:
    &mail-environment
    MAIL_FROM: "admin@gmail.com"
    MAIL_DRIVER: "log"
    MAIL_HOST: "mail"
    MAIL_PORT: "1025"
    MAIL_USERNAME: ""
    MAIL_PASSWORD: ""
    MAIL_ENCRYPTION: "true"

services:
  database:
    image: mariadb:10.5
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - "./data/database:/var/lib/mysql"
    environment:
      <<: *db-environment
      MYSQL_DATABASE: "panel"
      MYSQL_USER: "pterodactyl"

  cache:
    image: redis:alpine
    restart: always

  panel:
    image: ghcr.io/pterodactyl/panel:latest
    restart: always
    ports:
      - "8030:80"
      - "4433:443"
    links:
      - database
      - cache
    volumes:
      - "./data/var:/app/var"
      - "./data/nginx:/etc/nginx/http.d"
      - "./data/certs:/etc/letsencrypt"
      - "./data/logs:/app/storage/logs"
    environment:
      <<: [*panel-environment, *mail-environment]
      DB_PASSWORD: "RahmiddinRoot321"
      APP_ENV: "production"
      CACHE_DRIVER: "redis"
      SESSION_DRIVER: "redis"
      QUEUE_DRIVER: "redis"
      REDIS_HOST: "cache"
      DB_HOST: "database"
      DB_PORT: "3306"

networks:
  default:
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF

echo -e "${CYN}X-> Data papkalar...${NC}"
mkdir -p ./data/{database,var,nginx,certs,logs}

echo -e "${GRN}X-> Containerlar ishga tushmoqda...${NC}"
docker-compose up -d

echo -e "${GRN}X-> Panel sozlanmoqda...${NC}"
docker-compose run --rm panel php artisan key:generate --force
docker-compose run --rm panel php artisan migrate --seed --force

echo -e "${GRN}X-> Admin yarat...${NC}"
docker-compose run --rm panel php artisan p:user:make

echo -e "${YEL}✅ TAMOM BO‘LDI RAHMIDDIIN 🚀${NC}"
echo -e "${CYN}👉 Brauzer: http://YOUR_VPS_IP:8030${NC}"
