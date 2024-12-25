#!/bin/bash
 
# Atualiza o repositório de pacotes do sistema, e instala pacotes necessários para a instalação do Docker.

sudo apt update && apt upgrade -y

sudo apt-get install -y ca-certificates curl
 
# Cria o diretório onde as chaves GPG do repositório do Docker serão armazenadas

sudo install -m 0755 -d /etc/apt/keyrings
 
# Baixa a chave GPG oficial do docker e a salva no diretório criado e dá permissão para o usuário de leitura para a chave baixada

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc
 
# Adiciona o repositório oficial do Docker, com a chave GPG para validar os pacotes.

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 
# Atualiza a lista de pacotes novamente.

sudo apt update
 
# Instalar a versão mais recente do Docker e dos seus componentes

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
 
# Inicia o Docker e troca suas permissões

sudo systemctl start docker

sudo usermod -aG docker ubuntu
 
# Configuração nfs

sudo apt install nfs-common -y

sudo mkdir -p /efs/wordpress
 
 
# Criar pasta para depositar docker compose

sudo mkdir /projeto
 
cd /projeto
 
# Criação de docker compose
echo "version: '3.8'" >> docker-compose.yml && \
echo "services:" >> docker-compose.yml && \
echo "  wordpress:" >> docker-compose.yml && \
echo "    image: wordpress:latest" >> docker-compose.yml && \
echo "    ports:" >> docker-compose.yml && \
echo "      - 80:80" >> docker-compose.yml && \
echo "      - 443:443" >> docker-compose.yml && \
echo "    environment:" >> docker-compose.yml && \
echo "      WORDPRESS_DB_HOST: rds-server-test-03.ctrvlqjj9icq.us-east-1.rds.amazonaws.com" >> docker-compose.yml && \
echo "      WORDPRESS_DB_USER: admin" >> docker-compose.yml && \
echo "      WORDPRESS_DB_PASSWORD: WLWfsw6%%JZDnZPtaRNmJac*r" >> docker-compose.yml && \
echo "      WORDPRESS_DB_NAME: wordpress" >> docker-compose.yml && \
echo "    volumes:" >> docker-compose.yml && \
echo "      - /efs/wordpress:/var/www/html" >> docker-compose.yml

#Criando arquivo de configuração de serviço
echo "[Unit]" >> /etc/systemd/system/wordpress-app.service &&\
echo "Description=Docker Compose Application Service" >> /etc/systemd/system/wordpress-app.service &&\
echo "Requires=docker.service" >> /etc/systemd/system/wordpress-app.service &&\
echo "After=docker.service" >> /etc/systemd/system/wordpress-app.service &&\
echo "StartLimitIntervalSec=60" >> /etc/systemd/system/wordpress-app.service &&\

echo "[Service]" >> /etc/systemd/system/wordpress-app.service &&\
echo "WorkingDirectory=/projeto" >> /etc/systemd/system/wordpress-app.service &&\
echo "ExecStart=docker compose up" >> /etc/systemd/system/wordpress-app.service &&\
echo "ExecStop=docker compose down" >> /etc/systemd/system/wordpress-app.service &&\
echo "TimeoutStartSec=0" >> /etc/systemd/system/wordpress-app.service &&\
echo "Restart=on-failure" >> /etc/systemd/system/wordpress-app.service &&\
echo "StartLimitBurst=3" >> /etc/systemd/system/wordpress-app.service &&\

echo "[Install]" >> /etc/systemd/system/wordpress-app.service &&\
echo "WantedBy=multi-user.target" >> /etc/systemd/system/wordpress-app.service


#habilitando wordpress para iniciar junto ao sistema
systemctl enable wordpress-app
 
 
# não precisa usar o nome do arquivo. Vc ta na pasta já
#sudo docker compose up -d
sudo service wordpress-app start


sudo apt install nfs-common -y && \
    sudo systemctl status nfs-utils
	
	
	
sudo mount -t efs -o tls fs-0f9229d4f67e9ae39:/ efs

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0f9229d4f67e9ae39.efs.us-east-1.amazonaws.com:/ efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 172.31.90.215:/ efs