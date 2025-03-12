#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update the system
echo "🔄 Updating system..."
sudo DEBIAN_FRONTEND=noninteractive apt update -y && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -o Dpkg::Options::="--force-confold"

# Install Docker & Docker Compose
echo "🐳 Installing Docker & Docker Compose..."
sudo apt install -y docker.io docker-compose

# Create directory if it doesn't exist
INSTALL_DIR=~/lemp-docker
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p $INSTALL_DIR/{src,nginx,mysql}
fi
cd $INSTALL_DIR

# Create docker-compose.yml file
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  nginx:
    image: nginx:latest
    container_name: nginx_server
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php
    networks:
      - lemp_network

  php:
    image: php:8.2-fpm
    container_name: php_server
    volumes:
      - ./src:/var/www/html
    networks:
      - lemp_network

  mysql:
    image: mysql:8.0
    container_name: mysql_server
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: lemp_db
      MYSQL_USER: user
      MYSQL_PASSWORD: password
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      - lemp_network

  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: phpmyadmin
    environment:
      PMA_HOST: mysql
      PMA_USER: root
      PMA_PASSWORD: root
    ports:
      - "8081:80"
    depends_on:
      - mysql
    networks:
      - lemp_network

networks:
  lemp_network:
    driver: bridge
    
volumes:
  db_data:
EOF

# Create Nginx configuration file
cat <<EOF > nginx/default.conf
server {
    listen 80;
    server_name $(curl -s -4 ifconfig.me);

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include fastcgi_params;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Create index.php file
cat <<EOF > src/index.php
<?php
phpinfo();
?>
EOF

# Run Docker Compose
echo "🚀 Deploying LEMP Stack..."
docker-compose up -d

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
for i in {30..0}; do
    if docker exec mysql_server mysqladmin ping -h "localhost" --silent; then
        break
    fi
    echo -n "."; sleep 1
done
if [ "$i" = 0 ]; then
    echo "MySQL startup failed"
    exit 1
fi


echo "✅ Setup complete! Access your server:"
echo "- PHP Info: http://$(curl -s -4 ifconfig.me)"
echo "- phpMyAdmin: http://$(curl -s -4 ifconfig.me):8081"
