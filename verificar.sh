#!/bin/bash

echo "=== Verificando Configuração do Container ==="
echo ""

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
  echo "ERRO: O serviço Docker não parece estar rodando. Inicie o Docker primeiro."
  exit 1
fi

# Reconstruir a imagem
echo "Reconstruindo a imagem do container..."
docker build -t extralimpo-site .

# Remover container existente se houver
if docker ps -a | grep -q extralimpo-site; then
  echo "Removendo container existente..."
  docker stop extralimpo-site > /dev/null 2>&1
  docker rm extralimpo-site > /dev/null 2>&1
fi

# Iniciar o container
echo "Iniciando o container..."
docker run -d --name extralimpo-site -p 5467:80 extralimpo-site

# Esperar alguns segundos para inicialização
echo "Aguardando a inicialização..."
sleep 5

# Verificar status
if docker ps | grep -q extralimpo-site; then
  echo "✅ Container está rodando!"
  echo ""
  echo "Logs do container:"
  docker logs extralimpo-site
  echo ""
  echo "Acessível em: http://localhost:5467"
  echo ""
  echo "Para testar o endpoint de saúde:"
  curl -s localhost:5467/health || echo "Não foi possível acessar o endpoint /health"
else
  echo "❌ ERRO: Container não está rodando. Verificando os logs:"
  docker logs extralimpo-site
fi 