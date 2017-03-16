#!/usr/bin/env bash
# Script de ejemplo para utilizar la función "rotate"

# Función
function rotate {
   # Parameter validations
   if [ -d "${1}" ]; then
      echo "*** Error: el argumento es un directorio. Se esperaba un archivo."
      exit 1
   elif [ -z "${1}" ]; then
      echo "*** Error: el argumento es una cadena vacia."
      exit 1
   fi

	# Create up to 5 historical records
   if [ -f "${1}" ]; then
      for i in 0 1 2 3 4 5; do
         if [ -f "${1}.${i}" ]; then
            continue
         else
            mv "${1}" "${1}.${i}"
            return
         fi
      done
   	
   	# Compress historical records if slots are full
      if [ "${i}" -eq "5" ]; then
      	# Find oldest record
         clean_filename="${1##*/}"     # log filename sanitation
         file_path="${1%/*}"           # log file path
         data_oldest_file=$(find "${file_path}" -maxdepth 1 -type f -name "${clean_filename}*" -printf '%T+ %p\n' | sort | head -n 1) 
         array_oldest_file=(${data_oldest_file// / })
         filename_oldest=$(basename ${array_oldest_file[1]})
         full_filename_oldest="${file_path}/${filename_oldest}"
         
         # Backup oldest record freeing a slot
         tar --remove-files -zcvf "${full_filename_oldest}.tgz" "${full_filename_oldest}" > /dev/null 2>&1
         
         # Re-analyze logs with 1 slot free now
         rotate "${1}"
      fi
   fi
}

LOG_FILE="${HOME}/miqueridodiario.log"

# rotamos (si hace falta) antes de pisar todo
rotate "${LOG_FILE}"    

# uso '>>' para corroborar tambien que no se añaden mas lineas
echo "Esta debe ser la unica linea del archivo" >> "${LOG_FILE}"
