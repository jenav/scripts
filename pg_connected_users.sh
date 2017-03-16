#!/usr/bin/env bash
# Muestra los usuarios conectados a una base de datos

# Guarda stderr en el descriptor 3 para luego restaurarlo
exec 3>&2
exec 2> /dev/null

# Funciones
check_if_in_use() {
#~ arrIN=(${var//|/ })
#~  // significan 'reemplazo global'
#~  / } reemplaza la | por un espacio
#~ Los parentesis sobre una variable lo convierten en arreglo: arrIN=(${var//|/ })

lista=$(
psql -t postgresql://${USERNAME}:${PASSWORD}@${HOST_MONITOR}/${DB_MONITOR} << EOF
  SELECT usename, pid, client_addr from pg_stat_activity where datname = '${DB_MONITOR}';
EOF
)
arrIN=(${lista//|/ })

if [ ${#arrIN[@]} -gt 0 ]; then
   echo -e "\n## Usuarios conectados:"

   for ((i=0; i<${#arrIN[@]}; i+=3)); do
      echo -e "· ${arrIN[$i]} (uid: ${arrIN[$i+1]}) → ip: ${arrIN[$i+2]}"
   done
else
   echo -e "\n## No hay usuarios conectados"
fi

}

usage() {
   # Muestra la ayuda
   echo ""
   echo "Script para ver quien esta conectado a la base de datos"
   echo ""
   echo "Empleo:"
   echo "   ${NOMBRE_SCRIPT} [opciones]"
   echo ""
   echo "Opciones:"
   echo "  -t                      comprueba en '{testing-site}'"
   echo "  -p                      comprueba en '{production-site}'"
   echo "  -b [NAME_DB]            comprueba contra la base de datos NAME_DB (default: {default_db})"
   echo "  -U [USERNAME]           usa USERNAME para conectarse a la DB (default: {default_user})"
   echo "  -P [PASSWORD]           usa una contraseña diferente para conectarse a la DB"
   echo "  -h                      muestra esta ayuda"
   echo ""
   echo ""
   echo "Reporte errores a '{here@home.tux}'"
   echo ""
}

# Variables por defecto
DB_MONITOR="{default_db}"
USERNAME="{default_user}"
PASSWORD="{default_pass}"
NOMBRE_SCRIPT="$(basename ${0})"

## Procesa parametros
# El primer : significa "silent error reporting mode"
while getopts ":htpb:U:P:" PARAMETRO; do
   case ${PARAMETRO} in
      t)
         HOST_MONITOR="{local-ip-testing}"
         ;;
      p)
         HOST_MONITOR="{local-ip-produccion}"
         ;;
      b)
         if [[ -z ${OPTARG} ]]; then
            echo "Debe indicar una base de datos!"
            exit 1
         else
            DB_MONITOR="${OPTARG}"
         fi
         ;;
      # Usa un usuario especifico
      U)
         if [[ -z ${OPTARG} ]]; then
            echo "Debe indicar un usuario!"
            exit 1
         else
            USERNAME="${OPTARG}"
         fi
         ;;
      # Usa un usuario diferente
      P)
         if [[ -z ${OPTARG} ]]; then
            echo "Debe indicar una contraseña"!
            exit 1
         else
            PASSWORD="${OPTARG}"
         fi
         ;;
      \?)
         echo "Opcion invalida: -${OPTARG}"
         usage
         exit 1
         ;;
      *|h)
         usage
         exit 1
         ;;
   esac
done

check_if_in_use

exec 2>&3
