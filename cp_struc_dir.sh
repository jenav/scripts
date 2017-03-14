#!/usr/bin/env bash
# Script para copiar estructura de directorios unicamente

#"set -e" hace que bash salga en caso de error de cualquier comando
#"set -o pipefail" hace que bash salga con error en cualquier 'pipe' de comandos
set -e
set -o pipefail

# Funciones
usage() {
  echo ""
  echo "Script para copiar estructura de directorios (esqueleto)."
  echo ""
  echo "Empleo:"
  echo "   ${NOMBRE_SCRIPT} [opciones] [ORIGEN] [DESTINO]"
  echo ""
  echo "Opciones:"
  echo "  -l [NIVEL]                  nivel de directorios a copiar"
  echo "  -h                          muestra esta ayuda"
  echo ""
  echo "Reporte errores a '{here@home.tux}'"
  echo ""
}

# Variables
NOMBRE_SCRIPT=$(basename ${0})
NIVEL=0

while getopts ":l:h" OPCION; do
  case ${OPCION} in
    l)
	   if [ -z "${OPTARG}" ]; then
	   	echo "Debe especificar un valor"
	   	usage
	   fi
      NIVEL=${OPTARG}
      ;;
    *|h)
      usage
      exit
      ;;
  esac
done

shift $((OPTIND-1))

ORIGEN=$(realpath ${1%/})
DESTINO=$(realpath ${2%/})    ## sin la barra al final, por las dudas

if [ "${ORIGEN}" == "${DESTINO}" ]; then
   echo "Debe elegir un directorio de destino diferente"
   exit
fi

if [ -d "${DESTINO}" ]; then
   echo "El directorio de destino ya existe"
   exit
fi

cd -- ${ORIGEN}
if [[ "${NIVEL}" -gt 0 ]]; then
  find . -maxdepth ${NIVEL} -type d -exec mkdir -p -- "${DESTINO}/{}" \;
else
  find . -type d -exec mkdir -p -- "${DESTINO}/{}" \;
fi

