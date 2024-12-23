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

#Etapas para Criar uma VPC para Load Balancer

1. Criar a VPC

Acesse o AWS Management Console e navegue até o serviço VPC.
Clique em Create VPC.

Preencha os detalhes:  

Nome da sua VPC (por exemplo, minha-vpc).
IPv4 CIDR block: Especifique um intervalo de IP (ex.: 10.0.0.0/16).
Tenancy: Deixe como Default.
Clique em Create VPC.

---

##2. Criar Subnets
O Load Balancer precisa de subnets públicas para acessar a internet e privadas para os recursos internos.

### Crie subnets públicas:

  Vá em Subnets e clique em Create Subnet.
  Selecione a VPC criada anteriormente.
  Escolha uma Availability Zone (ex.: us-east-1a).
  Adicione um CIDR block para a subnet (ex.: 10.0.1.0/24).
  Marque a opção Auto-assign public IPv4.
  Repita o processo para outra zona de disponibilidade (ex.: us-east-1b).
  
### Crie subnets privadas:

  *Siga o mesmo processo das subnets públicas, mas sem ativar a opção de IP   
   público.
   
  *Use intervalos de CIDR diferentes (ex.: 10.0.2.0/24 e 10.0.3.0/24).
  
3. Configurar o Internet Gateway
   Vá em Internet Gateways e clique em Create internet gateway.
   Nomeie o gateway e clique em Create.
   Anexe o Internet Gateway à sua VPC:
    Selecione o gateway criado, clique em Actions → Attach to VPC, e escolha sua 
    VPC.
    
4. Configurar Tabelas de Roteamento
   Vá em Route Tables e selecione a tabela de roteamento associada à sua VPC.
   
   Para subnets públicas:
       Adicione uma rota para a internet:
       Destination: 0.0.0.0/0.
       Target: O Internet Gateway criado.
    Associe a tabela às subnets públicas.
    
Para subnets privadas:
      Certifique-se de que as subnets privadas utilizam um NAT Gateway.
      
5. Criar o NAT Gateway
  Vá em NAT Gateways e clique em Create NAT Gateway.
  Escolha uma subnet pública e associe um Elastic IP.
  Após criar o NAT Gateway, configure uma tabela de roteamento para as subnets 
  privadas:
     Destination: 0.0.0.0/0.
     Target: O NAT Gateway criado.

###. Estrutura da VPC

### Configuração Geral
- **VPC:** Padrão, com NAT Gateway configurado.
- **Zonas de Disponibilidade:** `us-east-1a` e `us-east-1b`.
- **Subnets:** 
  - 2 públicas para recursos expostos (Load Balancer e NAT Gateway).
  - 2 privadas para instâncias EC2 e RDS.

![Diagrama da VPC]()

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

No diretório `/wordpress`, crie o arquivo `docker-compose.yml`:

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
 
