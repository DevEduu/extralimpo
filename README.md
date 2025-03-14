# Extra Limpo - Site Estático Otimizado

Este é o repositório do site estático da Extra Limpo, uma empresa de limpeza de estofados em Aracaju. O site foi configurado para ser executado em um container Docker com Nginx, garantindo performance, segurança e facilidade de implantação.

## Estrutura do Projeto

- `index.html` - Página principal do site
- `assets/` - Diretório contendo imagens e outros recursos estáticos
- `Dockerfile.final` - Configuração Docker otimizada para o site
- `docker-compose-final.yml` - Configuração do ambiente Docker Compose
- `deploy.sh` - Script para facilitar a implantação do site

## Características

- **Servidor web leve e rápido**: Baseado em Nginx Alpine para máxima performance
- **Segurança aprimorada**: Headers HTTP de segurança, permissões adequadas e configurações seguras
- **Alta performance**: Compressão gzip, cache de arquivos estáticos e timeouts otimizados
- **Configuração robusta**: Healthcheck integrado e monitoramento via endpoint status

## Como usar

### Implantação Rápida

Para implantar o site, simplesmente execute o script de deploy:

```bash
./deploy.sh
```

Isso irá construir e iniciar o container Docker. O site estará disponível em http://localhost:5467.

### Comandos Manuais

Se preferir executar os comandos manualmente:

```bash
# Construir e iniciar o container
docker-compose -f docker-compose-final.yml up -d

# Verificar status
docker ps | grep extralimpo-site

# Ver logs
docker logs -f extralimpo-site

# Parar o serviço
docker-compose -f docker-compose-final.yml down
```

## Personalização

Para modificar o site:

1. Edite o arquivo `index.html` conforme necessário
2. Atualize ou adicione recursos na pasta `assets/`
3. Execute novamente o script de deploy

## Considerações para Produção

Para ambientes de produção, considere:

1. Configurar um proxy reverso com suporte a HTTPS
2. Ajustar os recursos alocados no docker-compose.yml de acordo com as necessidades
3. Configurar backups regulares dos arquivos do site

## Requisitos

- Docker 20.10.0+
- Docker Compose 2.0.0+ 