# Projeto de Implantação de Ambiente na AWS com Docker e WordPress

![Logo Compass](https://github.com/user-attachments/assets/9f35adf0-b239-4af1-b78a-fb37763e68f4)

![Arquitetura](https://github.com/user-attachments/assets/ffde7b19-2bb9-4a79-97c9-2667035c0f62)

## 1. Introdução

Este projeto descreve a implantação de um ambiente AWS para hospedar uma aplicação WordPress com MySQL. A infraestrutura foi configurada com uma VPC padrão contendo NAT Gateway, duas zonas de disponibilidade (A e B), e subnets públicas e privadas para escalabilidade e segurança.

---

## 2. Requisitos

- Conta AWS com permissões administrativas.
- Conhecimento básico em Docker, WordPress, e AWS CLI.
- Ferramentas instaladas:
  - Docker e Docker Compose na instância EC2.
  - nfs-common para montar o EFS.

---

## 3. Estrutura da VPC

### Configuração Geral
- **VPC:** Padrão, com NAT Gateway configurado.
- **Zonas de Disponibilidade:** `us-east-1a` e `us-east-1b`.
- **Subnets:** 
  - 2 públicas para recursos expostos (Load Balancer e NAT Gateway).
  - 2 privadas para instâncias EC2 e RDS.

![Diagrama da VPC](https://github.com/user-attachments/assets/c6bd66d9-2156-4e4d-80d8-ddd80dd4cedd)

#### Subnets Configuradas:
| Subnet        | Tipo       | Zona de Disponibilidade | Tabela de Roteamento   |
|---------------|------------|-------------------------|------------------------|
| Public Subnet | Pública    | `us-east-1a`           | Internet Gateway       |
| Public Subnet | Pública    | `us-east-1b`           | Internet Gateway       |
| Private Subnet| Privada    | `us-east-1a`           | NAT Gateway            |
| Private Subnet| Privada    | `us-east-1b`           | NAT Gateway            |

#### Pontos Importantes:
1. **NAT Gateway:** Permite que instâncias em subnets privadas acessem a internet para atualizações e downloads.
2. **Security Groups:** Configurados para restringir acessos aos serviços críticos.

---

## 4. Componentes da Infraestrutura

### 4.1 EC2
- **Uso:** Hospedagem do WordPress com Docker.
- **Localização:** Subnets privadas.
- **Acesso:** Gerenciado via Security Group, permitindo apenas acesso interno e SSH controlado.

### 4.2 EFS
- **Uso:** Armazenamento persistente para arquivos WordPress.
- **Montagem:** Configurado em `/mnt/efs` na instância EC2.

### 4.3 RDS
- **Banco de Dados:** MySQL.
- **Segurança:** Acesso restrito às subnets privadas.
- **Public Access:** Desativado para maior segurança.

### 4.4 Load Balancer
- **Tipo:** Application Load Balancer.
- **Função:** Distribuir tráfego para as instâncias EC2.

---

## 5. Configuração Técnica

### Configuração do Docker Compose

No diretório `/opt/wordpress`, crie o arquivo `docker-compose.yml`:

```yaml
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: <HOST-RDS>
      WORDPRESS_DB_USER: <USUÁRIO>
      WORDPRESS_DB_PASSWORD: <SENHA>
      WORDPRESS_DB_NAME: <BANCO>
    volumes:
      - /mnt/efs/wordpress:/var/www/html
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: <SENHA-ROOT>
      MYSQL_DATABASE: wordpress
    volumes:
      - db_data:/var/lib/mysql
volumes:
  db_data:
