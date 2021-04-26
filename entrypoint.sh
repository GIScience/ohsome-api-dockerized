#!/bin/sh

# Change directory to the app directory where the jar file is located
cd /opt || exit

if ! [ -d "./app" ] && [ -f "./app.tar.xz" ]; then
  echo "===================================================="
  echo "App folder still compressed. Decompressing it first."
  echo "===================================================="
  tar -xvf app.tar.xz
  rm -rf app.tar.xz
elif ! [ -d "./app" ] && ! [ -f "./app.tar.xz" ]; then
  echo "=================================================================================="
  echo "No app folder and not compressed app folder found. This shouldn't happen. Exiting."
  echo "=================================================================================="
  exit
fi

if ! [ -f "./fallback.oshdb.mv.db" ] && [ -f "./fallback.tar.xz" ]; then
  echo "===================================================="
  echo "Fallback data still compressed. Decompressing it first."
  echo "===================================================="
  tar -xvf fallback.tar.xz
  rm -rf fallback.tar.xz
else
  echo "=================================================================================="
  echo "No fallback data found. Skipping fallback setup"
  echo "=================================================================================="
fi

if [ -f "./data/${DATA_FILE}" ]; then
  echo "=================================================================="
  echo "Custom database found. Using it instead of the fallback database."
  echo "=================================================================="
  java -jar app/ohsome-api.jar --database.db="./data/${DATA_FILE}"
elif [ -e "./fallback.oshdb.mv.db" ]; then
  echo "============================================================"
  echo "No custom database found. Falling back to fallback database."
  echo "============================================================"
  java -jar app/ohsome-api.jar --database.db=./fallback.oshdb.mv.db
else
  echo "========================================================================"
  echo "No custom database found and no fallback database initialized. Quitting."
  echo "========================================================================"
  exit 1
fi

# Keep docker running
exec "$@"
