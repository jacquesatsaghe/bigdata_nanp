#!/bin/bash

echo "🚀 Chargement du connecteur Source Postgres..."
curl -X POST http://localhost:8083/connectors \
     -H "Content-Type: application/json" \
     -d @source-postgres-debezium.json

echo -e "\n🚀 Chargement du connecteur Sink Elasticsearch..."
curl -X POST http://localhost:8083/connectors \
     -H "Content-Type: application/json" \
     -d @sink-elastic-debezium.json

echo -e "\n✅ Terminé ! Vérifiez l'état avec : curl http://localhost:8083/connectors?expand=status"

