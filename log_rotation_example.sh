#!/bin/bash

#ROTATION FUNCTION
function rotate {
   # Parameter validations
   if [ -d "${1}" ]; then
      echo "*** Error: el argumento es un directorio. Se esperaba un archivo."
      exit 1
   elif [ -z "${1}" ]; then
      echo "*** Error: el argumento es una cadena vacia."
      exit 1
   fi

   if [ -f "${1}" ]; then
      for i in 0 1 2 3 4 5; do
         if [ -f "${1}.${i}" ]; then
            continue
         else
            mv "${1}" "${1}.${i}"
            return
         fi
      done
   
      if [ "${i}" -eq "5" ]; then
         clean_filename="${1##*/}"     # log filename sanitation
         file_path="${1%/*}"           # log file path
         data_oldest_file=$(find "${file_path}" -maxdepth 1 -type f -name "${clean_filename}*" -printf '%T+ %p\n' | sort | head -n 1) 
         array_oldest_file=(${data_oldest_file// / })
         filename_oldest=$(basename ${array_oldest_file[1]})
         full_filename_oldest="${file_path}/${filename_oldest}"
         tar --remove-files -zcvf "${full_filename_oldest}.tgz" "${full_filename_oldest}" > /dev/null 2>&1 
         rotate "${1}"
      fi
   fi
}

LOG_FILE="${HOME}/miqueridodiario.log"

# rotamos (si hace falta) antes de pisar todo
rotate "${LOG_FILE}"    

# uso '>>' para corroborar tambien que no se añaden mas lineas
echo "Esta debe ser la unica linea del archivo" >> "${LOG_FILE}"
