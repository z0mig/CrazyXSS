#!/bin/bash

# Definir variables
green=$(tput setaf 2)
Yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Verificar si se proporcionó el dominio
if [ $# -eq 0 ]
then
  echo "Uso: $0 [-h] [-d dominio]"
  echo "    -h: Muestra la ayuda del script."
  echo "    -d: Dominio objetivo."
  exit 1
fi

# Ver si se proporcionó la opción -h
while getopts ":hd:" opt; do
   case $opt in
      h)
         echo "    -d: Dominio objetivo."
         exit 0
         ;;
      d) 
         dominio=$OPTARG
         ;;
      \?)
         echo "Opción inválida: -$OPTARG" >&2
         exit 1
         ;;
      :)
         echo "La opción -$OPTARG requiere un argumento." >&2
         exit 1
         ;;
   esac
done


function main(){
  
  #Tiempo de Ejecución.
  
  HoraInicio=$(date +%s)
  
    echo "${Yellow}Comenzando escaneo de subdominios con gau...${reset}"
    gau --subs "$dominio" | unfurl domains>> vul1.txt
    echo "${green}Escaneo de subdominios finalizado con gau...${reset}"

    echo "${Yellow}Comenzando escaneo de subdominios en waybackurls...${reset}"
    waybackurls "$dominio" | unfurl domains >> vul2.txt
    echo "${green}Escaneo de subdominios en waybackurls finalizado...${reset}"
    
    echo "${Yellow}Comenzando escaneo de subdominios en subfinder...${reset}"
    subfinder -d "$dominio" -silent >> vul3.txt
    echo "${green}Escaneo de subdominios en subfinder finalizado...${reset}"
    
    echo "${Yellow}Comenzando limpieza...${reset}"
    cat vul1.txt vul2.txt vul3.txt | sort -u >> unique_sub.txt
    echo "${green}Limpieza finalizada...${reset}"
    
    echo "${Yellow}Creando customer wordlist para fuzzeo...${reset}"
    gau --subs "$dominio" | grep "=" | sed 's/.*.?//' | sed 's/\&/\n/' | sed 's/=.*//' >> param1.txt
    waybackurls "$dominio" | grep "=" | sed 's/.*.?//' | sed 's/\&/\n/' | sed 's/=.*//' | sort -u >> param2.txt
    echo "${green}Wordlist para fuzzeo finalizada...${reset}"
    
    echo "${Yellow}Uniendo parametros en una misma lista...${reset}"
    cat param1.txt param2.txt | sort -u >> param.txt
    echo "${green}Lista de parametros finalizada...${reset}"
  #Tiempo de ejecución
  
  echo "${green}El escaneo para $dominio se ha ejecutado correctamente${reset}"
  HoraFin=$(date +%s)
  duracion=$((HoraFin-HoraInicio))
  echo "Escaneo completado en : $(($duracion / 60)) minutos y $(($duracion % 60)) segundos."
  
}

main "$dominio"

