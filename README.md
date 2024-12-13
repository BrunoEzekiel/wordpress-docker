# Projeto de Implantação de Ambiente na AWS com Docker e WordPress

## 1. Introdução

Este projeto visa a configuração de um ambiente na AWS para hospedar uma aplicação WordPress com MySQL como backend. A infraestrutura será montada usando EC2, EFS para armazenamento de arquivos estáticos, RDS para o banco de dados, e Load Balancer para distribuição de tráfego.

## 2. Configuração Inicial

### AWS:
1. **Instância EC2**: Crie uma instância EC2 para servir como host da aplicação.
2. **Permissões**: Certifique-se de ter permissões para configurar o Elastic File System (EFS) e o Load Balancer.
   - Acesso ao EC2
   - Acesso ao EFS
   - Acesso ao Load Balancer

### Docker:
1. **Instalação do Docker: Instale o Docker na instância EC2.
   - Para instalar o Docker, siga as instruções da [documentação oficial](https://docs.docker.com/get-docker/).
2. **Verificação de Funcionamento**: Verifique se o Docker está funcionando corretamente com o comando:
   ```bash
   docker --version
