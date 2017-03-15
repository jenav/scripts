#!/usr/bin/env bash
# Script para verificar si una página es accesible

#"set -e" hace que bash salga en caso de error de cualquier comando
#"set -o pipefail" hace que bash salga con error en cualquier 'pipe' de comandos
set -e
set -o pipefail

# Funciones
usage() {
   echo ""
   echo "Script para verificar si una página es accesible"
   echo ""
   echo "Empleo:"
   echo "   ${NOMBRE_SCRIPT} [sitio web]"
   echo ""
   echo "Opciones:"
   echo "  -m [EMAIL]						  manda mail de reporte"
   echo "  -h                          muestra esta ayuda"
   echo ""
   echo "Reporte errores a '{here@home.tux}'"
   echo ""
}

check() {
   curl -s -o "/dev/null" "${1}"

   if [ $? -ne 0 ] ; then
      if [ $? -eq 6 ]; then
         salida="No se pudo resolver el host"
      elif [ $? -eq 7 ]; then
         salida="No se pudo conectar al host"
      else
         salida="No se pudo obtener la URL: ${1}"
      fi
   fi

   if [ "${email_automatico}" = true ]; then
      echo "${salida}" | mail -s "Problemas con ${1}" "${email_address}"
   fi
}

check_programs() {
   local salir=false

   if ! hash curl 2>/dev/null; then
      echo "***Error: No se encuentra el programa 'curl' en el PATH"
      salir=true
   fi

   if ! hash mail 2>/dev/null; then
      echo "***Error: No se encuentra el programa 'mail' en el PATH"
      salir=true
   fi

   if [ "${salir}" = true ]; then
      exit 1
   fi
}

# Variables
NOMBRE_SCRIPT=$(basename ${0})
email_automatico=false
email_address="here@home.tux"

while getopts ":m:h" OPCION; do
   case ${OPCION} in
      m)
         if [ -z "${OPTARG}" ]; then
            echo "Debe especificar una direccion de email"
            usage
         fi
         email_address=${OPTARG}
         email_automatico=true
         ;;
      *|h)
         usage
         exit
         ;;
   esac
done

# Verificamos que esten instalados los programas necesarios
check_programs

check "${1}"
