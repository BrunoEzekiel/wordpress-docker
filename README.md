

# Projeto de Implantação de Ambiente na AWS com Docker e WordPress
imagen da arquetera aqui.
![logo-compass](https://github.com/user-attachments/assets/9f35adf0-b239-4af1-b78a-fb37763e68f4)


![arq](https://github.com/user-attachments/assets/ffde7b19-2bb9-4a79-97c9-2667035c0f62)

## 1. Introdução

Este projeto visa a configuração de um ambiente na AWS para hospedar uma aplicação WordPress com MySQL como backend. A infraestrutura será montada usando EC2, EFS para armazenamento de arquivos estáticos, RDS para o banco de dados, e Load Balancer para distribuição de tráfego.

imagem logo: wordpress, docker, aws 

## 2. Requisitos:

Acesso a intenert e um terminal.

Conta AWS: Certifique-se de ter uma conta na AWS.

Instância EC2: Crie uma instância EC2 para hospedar o WordPress.

Docker: Instale o Docker na instância EC2.

Docker Compose: Instale o Docker Compose para gerenciar os contêineres.

RDS (Relational Database Service): Configure um banco de dados MySQL no RDS.

EFS (Elastic File System): Configure o EFS para armazenamento persistente.

Load Balancer: Configure um Load Balancer para distribuir o tráfego.


Passo a Passo
criar VPC
![VPCPIC](https://github.com/user-attachments/assets/c6bd66d9-2156-4e4d-80d8-ddd80dd4cedd)
☁️ Arrumando VPC
Abra o menu de criação de VPC no seu console AWS e vá em "Your VPCs", feito isso devemos colocar ao menos duas "Subnet" com "Route Table" apontadas para um "Internet Gateway" afim de disponibilizar internet ao Load Balancer posteriormente. O restante com o "Roube Table" apontadas para um "NAT Gateway" como segue a imagem :

🎲 RDS - Criando o Amazon Relational Database Service
O RDS armazenará os arquivos do container de WordPress, então antes de partirmos para o acesso na EC2, devemos criar o banco de dados corretamente.

Busque pelo serviço de RDS no console AWS e vá em "Create database"

Escolha o Engine type como MySQL

Em "Templates" selecione a opção "Free Tier"

Dê um nome para a sua instância RDS

Escolha suas credenciais do banco de dados e guarde essas informações (Master username e Master password), pois são informações necessárias para a criação do container de WordPress

Na etapa de "Connectivity", escolha o Security Group criado especialmente para o RDS, selecione a mesma AZ que sua EC2 criada está e em "Public access" escolha a opção de sim.

Ao fim da criação do RDS, haverá uma etapa chamada "Additional configuration" e nela existe um campo chamado "Initial database name", esse nome também será necessário na criação do container de WordPress

Vá em "Create Database"

Banco de Dados Criado
Banco de Dados Criado

📂 EFS - Criando o Amazon Elastic File System
O EFS armazenará os arquivos estáticos do WordPress. Portanto, para criá-lo corretamente e, em seguida, fazer a montagem no terminal, devemos seguir os seguintes passos:

Busque pelo serviço EFS ainda no console AWS e vá em "Create file system"

Na janela que se abre, escolha o nome do seu volume EFS

Na lista de "File systems" clique no nome do seu EFS e vá na seção "Network". Nessa parte vá no botão "Manage" e altere o SG para o que criamos no início especificamente para o EFS
![NETWORK_EFS](https://github.com/user-attachments/assets/ff04a704-c206-406b-b273-5c617b4eb5eb)

Seção de Network do EFS
Seção de Network do EFS

Acessando a EC2 e fazendo configurações
Para fazermos as configurações necessárias na instância EC2 via terminal, devemos seguir os seguintes passos:

Confirme que o Docker e o Docker Compose foram instalados com sucessos usando os comandos docker ps e docker-compose --version. Apesar desses comandos estarem no shellscript, é sempre bom verificar que as ferramentas estão instaladas corretamente.

O "nfs-utils" também foi instalado durante a inicialização da EC2 através do shellscript de user data, junto a isso foi criado também o caminho para a montagem do seu volume EFS (/mnt/efs/) com as permissões de rwx (leitura, escrita e execução).

Esse caminho é muito importante e você pode conferir se ele foi criado com sucesso indo até ele com o comando cd /mnt/efs/. Com essa confirmação, agora você deve ir novamente no seu console AWS, acessar o serviço de EFS e seguir os seguintes passos:

Selecione o seu volume EFS e clique em "Attach" para atachar o volume na sua EC2

Na janela aberta selecione "Mount via DNS" e copie o comando de montagem usando o NFS client e cole no terminal da EC2:

Janela de Mount targets do EFS
Janela de Mount targets do EFS

Não se esqueça de alterar o caminho no final do comando para /mnt/efs/

Para confirmar a montagem do EFS execute df -h
Saída do comando df -h
Saída do comando df -h

3. Para automatizar a montagem do volume EFS na sua instância EC2 faça o seguinte: + sudo echo "fs-IDDOSEUEFS.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs defaults 0 0" >> /etc/fstab + Para confirmar novamente a montagem do EFS execute `` df -h `` ## 📄 Docker Compose - Criação do docker-compose.yml
Para subirmos o container do WordPress devemos criar um arquivo .yml/.yaml com as seguintes instruções:
1. Criar Instância EC2
Tutorial: Como criar uma instância EC2 na AWS





2. Instalar Docker
Documentação Oficial do Docker: Instalar Docker no Ubuntu

Comandos:

bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
3. Instalar Docker Compose
Documentação Oficial do Docker Compose: Instalar Docker Compose

Comandos:

bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
4. Configurar RDS
Tutorial: Como configurar o Amazon RDS

5. Configurar EFS
Tutorial: Como configurar o Amazon EFS

6. Configurar Load Balancer
Tutorial: Como configurar um Load Balancer na AWS

Exemplo de Arquivo docker-compose.yml
yaml
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
      - "443:443"
    environment:
      WORDPRESS_DB_HOST: seu_host
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: sua_senha
      WORDPRESS_DB_NAME: seu_banco
    volumes:
      - /efs/wordpress:/var/www/html
  db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
    volumes:
      - db_data:/var/lib/mysql
volumes:
  wp_data:
  db_data:
Links Úteis
Como configurar um site WordPress na AWS usando Docker

Guia completo para instalar WordPress no Docker
