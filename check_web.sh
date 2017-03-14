#!/usr/bin/env bash

check() {
  curl -s -o "/dev/null" "${1}"
  if [ $? -ne 0 ] ; then
    if [ $? -eq 6 ]; then
      echo "No se pudo resolver el host" | mail -s "Problemas con ${1}" here@home.tux
    elif [ $? -eq 7 ]; then
      echo "No se pudo conectar al host" | mail -s "Problemas con ${1}" here@home.tux
    else
      echo "No se pudo obtener la URL: ${1}" | mail -s "Problemas con ${1}" here@home.tux
    fi
  fi
}

check "google.com.ar"

