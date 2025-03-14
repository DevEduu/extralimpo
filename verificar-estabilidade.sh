#!/bin/bash

echo "=== Script de Diagnóstico e Solução para Container Instável ==="
echo ""

# Verifica se Docker está rodando
if ! docker info > /dev/null 2>&1; then
  echo "ERRO: O serviço Docker não parece estar rodando. Inicie o Docker primeiro."
  exit 1
fi

# Configurações
CONTAINER_NAME="extralimpo-site"
IMAGE_NAME="extralimpo-site-stable"
PORT="5467"

# Remover container anterior
if docker ps -a | grep -q $CONTAINER_NAME; then
  echo "Removendo container antigo..."
  docker stop $CONTAINER_NAME > /dev/null 2>&1
  docker rm $CONTAINER_NAME > /dev/null 2>&1
fi

# Criar arquivo temporário para o Dockerfile modificado
echo "Criando Dockerfile estável..."
cat > Dockerfile.stable << 'EOF'
# Use a imagem Alpine do Nginx que é mais leve e segura
FROM nginx:stable-alpine

# Adicione metadados ao container
LABEL maintainer="Extra Limpo <contato@extralimpo.com.br>"
LABEL version="1.0"
LABEL description="Site da Extra Limpo - Limpeza de estofados em Aracaju"

# Configure o fuso horário
ENV TZ=America/Recife

# Crie diretórios necessários e configure permissões corretas
RUN mkdir -p /usr/share/nginx/html/assets && \
    mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    mkdir -p /var/log/nginx && \
    chmod -R 777 /var/cache/nginx && \
    chmod -R 777 /usr/share/nginx && \
    chmod -R 777 /var/log/nginx

# Copie arquivos de site para o diretório do Nginx
COPY ./index.html /usr/share/nginx/html/
COPY ./assets /usr/share/nginx/html/assets/

# Configure o Nginx - simplificado para maior estabilidade
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    location /health { \
        access_log off; \
        add_header Content-Type text/plain; \
        return 200 "OK"; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Exponha a porta 80
EXPOSE 80

# Comando simples para iniciar o Nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

# Construir imagem com o Dockerfile modificado
echo "Construindo nova imagem estável..."
docker build -t $IMAGE_NAME -f Dockerfile.stable .

# Executar o container com opções simplificadas
echo "Iniciando container estável..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $PORT:80 \
  --restart unless-stopped \
  $IMAGE_NAME

# Aguardar inicialização
echo "Aguardando inicialização..."
sleep 5

# Verificar status
if docker ps | grep -q $CONTAINER_NAME; then
  echo "✅ Container está rodando!"
  echo ""
  echo "Logs do container:"
  docker logs $CONTAINER_NAME
  echo ""
  echo "Acessível em: http://localhost:$PORT"
  echo ""
  echo "Para testar o endpoint de saúde:"
  curl -s localhost:$PORT/health || echo "Não foi possível acessar o endpoint /health"
  echo ""
  echo "Monitoramento contínuo por 2 minutos (pressione Ctrl+C para interromper):"
  echo "Este teste verifica se o container permanece ativo por um período maior."
  
  START_TIME=$(date +%s)
  END_TIME=$((START_TIME + 120))
  
  while [ $(date +%s) -lt $END_TIME ]; do
    if ! docker ps | grep -q $CONTAINER_NAME; then
      echo "❌ ERRO: Container parou de funcionar!"
      echo "Verificando logs:"
      docker logs $CONTAINER_NAME
      exit 1
    fi
    echo -n "."
    sleep 5
  done
  
  echo ""
  echo "✅ Container permaneceu estável por 2 minutos."
  echo "Para continuar monitorando, use: docker logs -f $CONTAINER_NAME"
else
  echo "❌ ERRO: Container não está rodando. Verificando os logs:"
  docker logs $CONTAINER_NAME
fi 