# Extra Limpo - Dockerfile Otimizado

Este é o Dockerfile otimizado para o site da Extra Limpo, uma empresa de limpeza de estofados em Aracaju. O arquivo foi configurado para ser usado de forma independente, sem necessidade de arquivos adicionais como docker-compose.yml ou nginx.conf.

## Características

- **Segurança aprimorada**: Usuário não-root, configurações de segurança do Nginx
- **Performance otimizada**: Compressão gzip, cache de arquivos estáticos, timeouts otimizados
- **Imagem Alpine leve**: Tamanho reduzido e menor superfície de ataque
- **Monitoramento integrado**: Healthcheck e endpoint de status para monitoramento
- **Configuração completa**: Todas as configurações do Nginx incorporadas no Dockerfile

## Como usar

### Preparação

1. Certifique-se de que o arquivo `index.html` e a pasta `assets` estão no mesmo diretório do Dockerfile
2. Estrutura de arquivos esperada:
   ```
   .
   ├── Dockerfile
   ├── index.html
   └── assets/
       ├── logo.svg
       ├── favicon.ico
       ├── sofa.jpeg
       └── ... (outras imagens)
   ```

### Build da imagem

```bash
docker build -t extralimpo-site:latest .
```

### Executar o container

```bash
docker run -d --name extralimpo-site -p 80:80 extralimpo-site:latest
```

Você também pode personalizar a porta exposta:

```bash
docker run -d --name extralimpo-site -p 5467:80 extralimpo-site:latest
```

### Verificar status do container

```bash
docker ps | grep extralimpo-site
```

### Ver logs

```bash
docker logs -f extralimpo-site
```

## Personalização

### Mudar o fuso horário

```bash
docker run -d --name extralimpo-site -e TZ=America/Sao_Paulo -p 80:80 extralimpo-site:latest
```

### Limitar recursos (CPU e memória)

```bash
docker run -d --name extralimpo-site --cpus=0.5 --memory=256M -p 80:80 extralimpo-site:latest
```

### Persistir logs

```bash
docker run -d --name extralimpo-site -v nginx_logs:/var/log/nginx -p 80:80 extralimpo-site:latest
```

## Manutenção

### Reiniciar o container

```bash
docker restart extralimpo-site
```

### Atualizar o site

1. Modifique os arquivos `index.html` e/ou `assets/`
2. Reconstrua a imagem: `docker build -t extralimpo-site:latest .`
3. Pare o container atual: `docker stop extralimpo-site && docker rm extralimpo-site`
4. Execute o novo container: `docker run -d --name extralimpo-site -p 80:80 extralimpo-site:latest`

## Considerações para produção

Para ambientes de produção, recomenda-se:

1. Utilizar um proxy reverso como Traefik ou Nginx Proxy Manager para gerenciar certificados SSL
2. Configurar limites de recursos apropriados para seu servidor
3. Implementar monitoramento usando as métricas disponíveis no endpoint `/stub_status`
4. Configurar backups regulares dos arquivos do site 