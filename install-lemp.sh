#!/bin/bash

# Update the system
echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

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
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: lemp_db
      MYSQL_USER: user
      MYSQL_PASSWORD: password
    volumes:
      - ./mysql:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      - lemp_network

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    restart: always
    environment:
      PMA_HOST: mysql
      MYSQL_ROOT_PASSWORD: root
    ports:
      - "8081:80"
    depends_on:
      - mysql
    networks:
      - lemp_network

networks:
  lemp_network:
    driver: bridge
EOF

# Create Nginx configuration file
cat <<EOF > nginx/default.conf
server {
    listen 80;
    server_name $(curl -s ifconfig.me);

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

echo "✅ Setup complete! Access your server:"
echo "- PHP Info: http://$(curl -s ifconfig.me)"
echo "- phpMyAdmin: http://$(curl -s ifconfig.me):8081"