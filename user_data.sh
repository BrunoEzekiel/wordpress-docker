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
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
 
# Configuração nfs

#instalar o nfs
sudo apt install nfs-common -y

#criar pasta para montar o efs
sudo mkdir -p /efs/wordpress

#montar o efs: 
ubuntu@ip-10-0-6-179:/projeto$ sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0f02b6379b723ab9d.efs.us-east-1.amazonaws.com:/ /efs/wordpress

# Criar pasta para depositar docker compose.yml
sudo mkdir /projeto

# Entrar na pasta
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

 
# não precisa usar o nome do arquivo. Vc ta na pasta já
sudo docker compose up -d
