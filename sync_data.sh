#!/usr/bin/env bash

ROOT='/home/www/fotos'
LOG_CORREO='/home/usuario/scripts/logs/correo.log'
LOG_ICONOS='/home/usuario/scripts/logs/iconos.log'
LOG_OTROS='/home/usuario/scripts/logs/otros.log'

for i in $ROOT/*
do
  arr=(${i//\// })
  if [ "${arr[3]}" != "data" ] && [ "${arr[3]}" != "tmp" ]; then
    if [ -d "${arr[3]}" ]; then
  		rsync -azp --delete --log-file=$LOG_CORREO usuario@hostname:/home/archivos/repo/${arr[3]}/correo/ $i/correo
  		rsync -azp --delete --log-file=$LOG_ICONOS usuario@hostname:/home/archivos/repo/${arr[3]}/iconos/ $i/iconos
  		rsync -azp --delete --log-file=$LOG_OTROS usuario@hostname:/home/archivos/repo/${arr[3]}/otros/ $i/otros
    fi
  fi
done
