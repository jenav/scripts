#!/usr/bin/env bash
# Reporta intentos de logueo fallidos informados por el comando lastb
#
# Utiliza la API de <ipinfo.io> para obtener informacion del host

#"set -e" hace que bash salga en caso de error de cualquier comando
#"set -o pipefail" hace que bash salga con error en cualquier 'pipe' de comandos
set -e
set -o pipefail

# Funciones
usage() {
   echo ""
   echo "Reporta intentos de logueo fallidos informados por el comando lastb"
   echo ""
   echo "Utiliza la API de <ipinfo.io> para obtener informacion del host"
   echo ""
   echo "Empleo:"
   echo "   ${NOMBRE_SCRIPT}"
   echo ""
   echo "Opciones:"
   echo "  -h                          muestra esta ayuda"
   echo ""
   echo "Reporte errores a '{here@home.tux}'"
   echo ""
}

check_programs() {
   local salir=false

   if ! hash curl 2>/dev/null; then
      echo "***Error: No se encuentra el programa 'curl' en el PATH"
      salir=true
   fi

   if ! hash jq 2>/dev/null; then
      echo "***Error: No se encuentra el programa 'jq' en el PATH"
      salir=true
   fi

   if ! hash country 2>/dev/null; then
      echo "***Error: No se encuentra el programa 'country' en el PATH"
      echo "Por favor visite: https://bitbucket.org/rsvp/gists/src"
      salir=true
   fi

   if [ "${salir}" = true ]; then
      exit 1
   fi
}

while getopts ":h" OPCION; do
   case ${OPCION} in
      *|h)
         usage
         exit
         ;;
   esac
done

# Verificamos que esten instalados los programas necesarios
check_programs

sudo lastb > lastb.log

desde=$(tail -n 1 lastb.log | awk '{$1=""; $2=""; sub("  ", " "); print}')

intentos=$(wc -l lastb.log | awk '{ print $1 }')
(( intentos-=2 ))

echo "Intentos fallidos de login desde '${desde:1}': ${intentos}"

# Obtenemos la lista de IP's limpia
cat lastb.log | awk '{ print $3 }' > .lastb.tmp
sort .lastb.tmp | uniq  | head -n -4 | tail -n +2 > .lastb.tmp_2

# Consultamos en ipinfo.io por cada IP
while read in; do 
   # 1er camino: por partes
   todo=$(curl -s "ipinfo.io/${in}")
   pais=$(echo "${todo}" | jq -r '.country')
   region=$(echo "${todo}" | jq -r '.region')
   org=$(echo "${todo}" | jq -r '.org')
   country=$(country "${pais}")

   echo -e "${in} -> {\n\t country: \"${country}\",\n\t region: \"${region}\",\n\t org: \"${org}\"\n}"; 

   # 2do camino: todo junto
   #echo "${in} -> $(curl -s "ipinfo.io/${in}" | jq '. | {country: .country, region: .region, org: .org}')"
done < .lastb.tmp_2

# Borramos temporales
rm .lastb.tmp
rm .lastb.tmp_2
