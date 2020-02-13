#!/bin/bash
# Baixar Ler qualquer letra do Vagalume"
# Autor: Rodrigo "WanzerData" Lombardi"
# Data:  01.01.2020"
# Arquivo será salvo na pasta do aplicativo"

title=$"VagaLyrics"
op=0
ap=0
while [ $op = 0 ]
do
	#=========================================================================================
	#ESCOLHA UMA LETRA
	if [ $ap = 0 ]
	then
		choice=$(zenity \
		--list   \
		--title "$title" \
		--text="Selecione uma letra" \
		--column="Letra" "0-9" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" --width 400 --height 330)
		echo "$choice"
		if [ -z $choice ] 
		then
		
		op=25
		ap=5
		elif [ $choice != "0-9" ]
		then
		choice=${choice,,}
		
		 lista=$(
		 echo "https://www.vagalume.com.br/browse/$choice.html" |
		 wget -O- -i- --no-check-certificate | 
		 hxnormalize -x | 
		 hxselect -i  ".moreNamesContainer" |
		 lynx -stdin -dump -listonly -nonumbers | sed 's=file:///==g' )
		  arr1=($lista) #transforma em array a lista
		 ap=1
		else
		lista=$(
		 echo "https://www.vagalume.com.br/browse/$choice.html" |
		 wget -O- -i- --no-check-certificate | 
		 hxnormalize -x | 
		 hxselect -i  ".moreNamesContainer"  |
		lynx -stdin -dump -listonly -nonumbers | sed 's=file:///==g' ) 
		arr1=($lista) #transforma em array a lista
		ap=1
		fi
			
	fi
	#=============================================================================
	#ESCOLHA UM ARTISTA
	if [ $ap = 1 ]
	then
		artist=$(zenity --list --title "$title" --text="Selecione um artista" --column="Artista" "${arr1[@]}" --width 400 --height 330)
		echo "$artist"
		
		if [ -z $artist ] 
		then
		
		#op=25
		ap=0
		else
		 artist=${artist,,}
		 lista=$(
		 echo "https://www.vagalume.com.br/$artist" |
		 wget -O- -i- --no-check-certificate | 
		 hxnormalize -x | 
		 hxselect -i  ".nameMusic"  |
		lynx -stdin -dump -listonly -nonumbers | sed 's=file:///==g' | sed 's='$artist'==g' | sed 's=.html==g' )  
		arr2=($lista) #transforma em array a lista
		ap=2
		fi	
		
	fi
	#============================================================================
	#ESCOLHA UMA MUSICA
	if	[ $ap = 2 ]
	then	
		music=$(zenity --list --title "$title" --text="Selecione uma musica\n banda:$artist" --column="Musica" "${arr2[@]}" --width 400 --height 330)
		if [ -z $music ] 
		then
		
		#op=25
		ap=1
		else
		 music=${music,,}
		 letra=$(
		 echo "https://www.vagalume.com.br/$artist$music" |
		 wget -O- -i- --no-check-certificate | 
		 hxnormalize -x | 
		 hxselect -i  ".col1-2-1"  |
		lynx -stdin -dump -nolist | 
		sed 's=(BUTTON)==g' |
		sed 's=*==g' | 
		sed 's=Encontrou algum erro na letra? Por favor, envie uma correção >==g' |
		sed 's=Comentar==g' > temp.lyr ) #> temp 
		ap=3      
		fi
		
	fi
	#===========================================================================
	#VISUALIZA A LETRA
	if [ $ap = 3 ] 
	then
		final=$(zenity --text-info --title="$music" --filename=./temp.lyr  --width 400 --height 500)		
		
		music=""
		rm ./temp.lyr
		ap=2
	fi
done
