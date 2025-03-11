# LEMP Docker Auto Deployment

This repository provides an **automated** way to deploy a **LEMP stack** (Linux, Nginx, MySQL, PHP) using Docker & Docker Compose.  

## Features
- Auto-installs **Docker & Docker Compose**  
- Deploys **Nginx, PHP-FPM, MySQL & phpMyAdmin**  
- Configures **Nginx & PHP automatically**  
- Works on **any VPS with Ubuntu/Debian**  

## Installation

Run the following commands on your VPS:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/chunghieu1/lemp-docker-auto/main/install-lemp.sh)
```

## Notes
- Ensure your VPS has at least **2GB of RAM** for smooth operation.
- The script assumes you have **sudo** privileges.
- Make sure **port 80** and **port 8081** are open and not used by other services.
- The default MySQL root password is set to `root`. Change it in the `docker-compose.yml` file if needed.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.