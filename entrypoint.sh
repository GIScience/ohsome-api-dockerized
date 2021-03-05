#!/bin/sh

# Change directory to the app directory where the jar file is located
cd /opt || exit

if ! [ -d "./app" ] && [ -f "./app.tar.xz" ]; then
  echo "===================================================="
  echo "App folder still compressed. Decompressing it first."
  echo "===================================================="
  pv app.tar.xz | tar -xvf - -J
  rm -rf app.tar.xz
elif ! [ -d "./app" ] && ! [ -f "./app.tar.xz" ]; then
  echo "=================================================================================="
  echo "No app folder and not compressed app folder found. This shouldn't happen. Exiting."
  echo "=================================================================================="
  exit
fi

if [ -f "./data/${DATA_FILE}" ]; then
  echo "=================================================================="
  echo "Custom database found. Using it instead of the fallback database."
  echo "=================================================================="
  java -jar app/ohsome-api.jar --database.db="./data/${DATA_FILE}"
elif [ -e "./app/fallback.oshdb.mv.db" ]; then
  echo "============================================================"
  echo "No custom database found. Falling back to fallback database."
  echo "============================================================"
  java -jar app/ohsome-api.jar --database.db=./app/fallback.oshdb.mv.db
else
  echo "========================================================================"
  echo "No custom database found and no fallback database initialized. Quitting."
  echo "========================================================================"
  exit 1
fi

# Keep docker running
exec "$@"
