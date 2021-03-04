#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Change directory to the app directory where the jar file is located
cd /opt/app || exit

# Create the data folder if its not mounted to avoid script access errors
[ -d data ] || mkdir data

if [ -f "./data/${DATA_FILE}" ]; then
  echo "${GREEN}Custom database found.${NC} Using it instead of the fallback database."
  java -jar target/ohsome-api.jar --database.db="./data/${DATA_FILE}"
elif [ -e "fallback_database.oshdb.mv.db" ]; then
  echo "${RED}No custom database found.${NC} Falling back to fallback database."
  java -jar target/ohsome-api.jar --database.db=./fallback_database.oshdb.mv.db
else
  echo "${RED}No custom database found and no fallback database initialized. Quitting.${NC}"
  exit 1
fi

# Keep docker running
exec "$@"
