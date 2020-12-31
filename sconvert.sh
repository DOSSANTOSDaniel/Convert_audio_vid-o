#!/bin/bash

#================================================================#
# DESCRIPTION:
# Ce script permet de convertir plusieurs types de
# fichiers :
# 1. Audios en mp3.
# 2. Vidéo en MP4.
#----------------------------------------------------------------#
# AUTEURS:
#  Daniel DOS SANTOS < daniel.massy91@gmail.com >
#----------------------------------------------------------------#
# DATE DE CRÉATION: 22/12/2020
#----------------------------------------------------------------#
# USAGE: ./ConvertMD.sh
#----------------------------------------------------------------#
# NOTES:
#
#----------------------------------------------------------------#
# BASH VERSION: GNU bash 5.0.17
#================================================================#

clear
cat << "EOF"
       ____        _           ____                          _            
      |  _ \  ___ | | ___   _ / ___|___  _ ____   _____ _ __| |_ ___ _ __ 
      | | | |/ _ \| |/ / | | | |   / _ \| '_ \ \ / / _ \ '__| __/ _ \ '__|
      | |_| | (_) |   <| |_| | |__| (_) | | | \ V /  __/ |  | ||  __/ |   
      |____/ \___/|_|\_\\__,_|\____\___/|_| |_|\_/ \___|_|   \__\___|_|   
                                                                    
EOF

### Fonctions
#------------------

# $1: chemin dossier, $file_name: nom transformé
f_rename_one() {

type_file=$(file -b --mime-type "${1}" | cut -d '/' -f1)
  
if [[ "${type_file}" == "video" || "${type_file}" == "audio" ]]
then
  dir_name=$(dirname ${1})

  cd ${dir_name}

  # Substituer
  file_name=$(basename ${1})
  sub_name="$(echo ${file_name} | sed 's/[^[:alnum:]]/-/g' | tr '[:upper:]' '[:lower:]')"

  # renomer les fichiers
  if [[ "${file_name}" != "${sub_name}" ]]
  then
    mv "${file_name}" "${sub_name}"
    if [[ "${?}" == "0" ]]
    then
      file_name="${sub_name}"
    else
      echo " ERREUR pour renommer le fichier !"
      exit 1
    fi
  fi
else
  echo "Erreur le fichier n'est pas une vidéo ou un audio !"
  exit 1
fi
}

# $1: chemin dossier, $file_name: nom transformé
f_rename_all() {
cd "${1}"
for i in *
do
  type_file=$(file -b --mime-type "${i}" | cut -d '/' -f1)
  
  if [[ "${type_file}" == "video" || "${type_file}" == "audio" ]]
  then
    # variable
    file_name="${i}"

    # Substituer 
    sub_name="$(echo ${i} | sed 's/[^[:alnum:]]/-/g' | tr '[:upper:]' '[:lower:]')"

    # renomer les fichiers
    if [[ "${file_name}" != "${sub_name}" ]]
    then
      mv "${file_name}" "${sub_name}"
      if [[ "${?}" == "0" ]]
      then
        file_name="${sub_name}"
      else
        echo " ERREUR pour renommer le fichier !"
        exit 1
      fi
    fi
  fi
done
}

# $1: Paquet
f_install() {
if [[ $(type -p "${1}") ]]
then
  echo "${1} est déjà installé !"
else
  echo "Installation de ${1}"
  apt-get update -q
  apt-get install --install-suggests -yq "${1}"
  if [[ "${?}" != "0" ]]
  then
    echo "Erreur : L'installation de "${1}" a échoué !"
    exit 2
  fi
fi
}

# $1: chemin fichier/dossier $2: un par un 'one' ou all $3: mp4/mp3 $4 : option ffmpeg
f_convert()
{
if [[ "${2}" == "all" ]]
then
  declare -i nb_count="0"

  cd "${1}"
  for i in *
  do
    type_file=$(file -b --mime-type "${i}" | cut -d '/' -f1)
    if [[ "${type_file}" == "video" && ! -z "${3}" ]]
    then
      echo "${i} est un(e) : ${type_file}"
      ((nb_count++))
    elif [[ "${type_file}" == "audio" && -z "${3}" ]]
    then
      echo "${i} est un(e) : ${type_file}"
      ((nb_count++))
    else
      continue
    fi
    ffmpeg -loglevel repeat+error -nostdin -i ${i} ${4} ${i}.${3}
    if [[ "${?}" != "0" ]]
    then
      echo "ERREUR : La conversion a échoué !"
      exit 1
    fi
    #clear
  done
    echo " [ ${nb_count} fichiers converties ] "
elif [[ "${2}" == "one" ]]
then
  clear
  ffmpeg -hide_banner -nostats -nostdin -i ${1} ${4} ${1}.${3}
  if [[ "${?}" != "0" ]]
  then
    echo "ERREUR : La conversion a échoué !"
    exit 1
  fi
else
  echo "ERREUR : Choix all/one ?"
  exit 1
fi
}

# $1: fichier ou dossier
f_exist()
{
file_type="n"
doc_type="n"

if [[ -z "${1}" ]]
then
  echo -e "\n Le champ est vide, veuillez insérer un chemin valide \n"
  f_stopp
else
  if [[ -e "${1}" ]]
  then
    if [[ -f "${1}" ]]
    then
      file_type="y"
    elif [[ -d "${1}" ]]
    then
      doc_type="y"
    fi
  else
    echo -e "\n Le 'fichier/dossier' n'existe pas !, ou c'est une erreur de syntaxe ! \n"
    f_stopp
  fi
fi
}


f_stopp()
{
echo ""
read -p "Voulez vous convertir d'autres fichiers ? [o] oui [n] non : " fin
echo ""
case "$fin" in
  [oO]|"oui"|"OUI")
  continue;;
  [nN]|"non"|"NON")
  f_fin;;
  *)
  if [[ -z "${fin}" ]]
  then
    echo "Le champ est vide, Veuillez insérer un choix valide"
    f_stopp
  else
    echo "Problème de syntaxe, Veuillez insérer un choix valide"
    f_stopp
  fi;;
esac
}


f_fin()
{
clear
echo -e "\n < FIN DU SCRIPT ! > \n"
sleep 1 
clear
echo -e "\n<FIN DU SCRIPT ! > \n"
sleep 1 
clear
echo -e "\n < FIN DU SCRIPT !>\n"
sleep 1 
exit 0
}

### Variables
#-------------

#readonly video_option='-c:v copy -c:a copy -y'
video_option='-c:v copy -c:a aac'

### Main
#-----------

f_install 'ffmpeg'

while :
do
echo -e "\n \t Médias pris en charge : "
cat << "EOF"

+--------+----------------+
| Image  | gif, jpg, png  |
+--------+----------------+
| Vidéo  | webm, ogv, mp4 |
+--------+----------------+
| Audio  | ogg, mp3, wav  |
+--------+----------------+
| Flash  | swf            |
+--------+----------------+
EOF

echo -e "\n \t Quel type de média voulez vous convertir : "
read -p "[1] Vidéo, [2] Audio : " choix_type

read -p "Chemin fichier ou dossier : " media

case ${choix_type} in
1) echo -e "\n Mode Vidéo \n"
   f_exist "${media}"
   if [[ "${file_type}" == "y" ]]
   then
     f_rename_one "${media}"
     f_convert "${file_name}" one mp4 "${video_option}"
     f_stopp
   elif [[ "${doc_type}" == "y" ]]
   then
     f_rename_all "${media}"
     f_convert "${media}" all mp4 "${video_option}"
     f_stopp
   fi 
   ;;
2) echo -e "\n Mode Audio \n"
     f_exist "${media}"
   if [[ "${file_type}" == "y" ]]
   then
     f_rename_one "${media}"
     f_convert "${file_name}" one mp3
     f_stopp
   elif [[ "${doc_type}" == "y" ]]
   then
     f_rename_all "${media}"
     f_convert "${file_name}" all mp3
     f_stopp
   fi 
   ;;
*) echo "ERREUR DE PARAMETRES !"
   f_stopp 
   ;;
esac
done
