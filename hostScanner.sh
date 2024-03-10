#!/usr/bin/bash
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n ${redColour} [!] Saliendo ... $endColour \n"
  exit 1 
  
}

# Ctrl C 
trap ctrl_c INT 
tput cnorm

function helpPanel(){ 
  echo -e "\n ${yellowColour}[*] Herramienta para realizar un escaneo de host en local${endColour}\n\n${blueColour} ----> Uso ${endColour}" 
  echo -e "\n\t${redColour}      -i Buscar host, pero antes se le pedira que se le especifique que tipo de interfaz es la que desea buscar${endColour}"
  echo -e "\n\t${greenColour}      -h Mostrar este panel de ayuda${endColour}"
}
function ipSelect(){
  echo -e "\n\t${blueColour}[+] Realizando busquedas de interfaces de red...\n${endColour}"
  interfaces="$(ip addr show | awk '/^[0-9]+:/ {gsub(/:/,"",$2); iface=$2} /inet / && $2 !~ /^127\.0\.0\.1/ {split($2,ip,"/"); print "Interfaz de red:", iface,"| " "ip:", ip[1]}' | column -t)"
  sleep 3
  echo -e "\n${greenColour}----> $interfaces${endColour}\n"
  echo -ne "${yellowColour}[?] ${endColour}${grayColour}Cual${endColour} ${turquoiseColour}interfaz de red${endColour} ${grayColour}deseas para el escaneo? ${endColour}${redColour}----> ${endColour}" && read selectedInterface
if [[ ! "$interfaces" =~ (^|[[:space:]])"$selectedInterface"($|[[:space:]]) ]]; then
    echo -e "${redColour}[!] Esa interfaz no se encuentra activa o no existe, verifica nuevamente...${endColour}"
else
  ip_to_scan="$(ip a | grep $selectedInterface | grep inet | awk '{print $2}' | awk '{print $1}' FS=/)" 
  echo -e "\n${yellowColour}[*]${endColour} ${grayColour}Se realizara el escaneo con la interfaz${endColour} ${blueColour}$selectedInterface ${endColour} ${grayColour}que tiene como ip${endColour} ${blueColour}$ip_to_scan${endColour}\n"
  sleep 3
  ip_cleared="$(ip a | grep $selectedInterface | grep inet | awk '{print $2}' | awk '{print $1}' FS=/ | awk '{print $1}' | sed 's/\.[0-9]\+$//')" 
  tput civis 
  for i in $(seq 1 254); do 
    timeout 1 bash -c "ping -c 1 $ip_cleared.$i &>/dev/null" && echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Host${endColour} ${blueColour}$ip_cleared.$i${endColour} ${grayColour}->${endColour} ${greenColour}Activo!${endColour}" &

  done 
  wait 
  tput cnorm 


fi
}

# Indicadores
declare -i parameter_counter=0 

while getopts "ih" arg ; do 
  case $arg in 
  i) ipSelect=$OPTARG; let parameter_counter+=2;;
  h) helpPanel=$OPTARG; let parameter_counter+=1;;

  esac
done

if [ $parameter_counter -eq 2 ]; then 
  ipSelect
else 
  helpPanel
fi
