#!/bin/sh
set -e

# Mensagem de diagnóstico
echo "Iniciando container Extra Limpo..."

# Verifica as permissões dos diretórios críticos
echo "Verificando permissões..."
if [ ! -w /var/cache/nginx ]; then
    echo "ERRO: Diretório /var/cache/nginx não tem permissão de escrita!"
    mkdir -p /var/cache/nginx/client_temp
    chown -R nginx:nginx /var/cache/nginx
    chmod -R 755 /var/cache/nginx
fi

if [ ! -w /var/log/nginx ]; then
    echo "ERRO: Diretório /var/log/nginx não tem permissão de escrita!"
    mkdir -p /var/log/nginx
    chown -R nginx:nginx /var/log/nginx
    chmod -R 755 /var/log/nginx
fi

echo "Testando a configuração do Nginx..."
nginx -t || exit 1

echo "Iniciando o Nginx..."
exec nginx 