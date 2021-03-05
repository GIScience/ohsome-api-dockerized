#!/bin/sh

# Change directory to the app directory where the jar file is located
cd /opt/app || exit

# Create the data folder if its not mounted to avoid script access errors
[ -d data ] || mkdir data

if [ -f "./data/${DATA_FILE}" ]; then
  echo "=================================================================="
  echo "Custom database found. Using it instead of the fallback database."
  echo "=================================================================="
  java -jar target/ohsome-api.jar --database.db="./data/${DATA_FILE}"
elif [ -e "fallback_database.oshdb.mv.db" ]; then
  echo "============================================================"
  echo "No custom database found. Falling back to fallback database."
  echo "============================================================"
  java -jar target/ohsome-api.jar --database.db=./fallback_database.oshdb.mv.db
elif [ -e "fallback_database.tar.gz" ]; then
  echo "========================================================================================"
  echo "No custom database found. Fallback database found but it needs to be uncompressed first."
  tar -xvf fallback_database.tar.gz
  echo "Uncompressing successful. Starting the server with the fallback database."
  echo "========================================================================================"
  java -jar target/ohsome-api.jar --database.db=./fallback_database.oshdb.mv.db
else
  echo "========================================================================"
  echo "No custom database found and no fallback database initialized. Quitting."
  echo "========================================================================"
  exit 1
fi

# Keep docker running
exec "$@"
