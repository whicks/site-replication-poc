#!/bin/bash   

begin=$(date +"%s")
bak=$(echo bak)

HOME='/methode/meth01/tmp'
NCD_CONTENT=NCD_CONTENT-10-19-2016-20-36-01
market_content_workspace=Athens-Radio-CONTENT-12-09-2016-09-10-59
workspace=$(echo "$HOME/$market_content_workspace")

#Site Replication Process

NOW=$(date +"%m-%d-%Y-%H-%M-%S")
#exec > $HOME/$market_content_workspace/logs//$market_content.log.$NOW 2>&1
SERVER_FILE=$HOME/server.xml
HOST=$(hostname)

env=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(1))}' | cut -f3 -d_)
env_description=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(1))}')
#market=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(2))}')
market=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(2))}' | awk '{print $2}')
vertical=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(2))}' | awk '{print $2}')
existing_market_content=$(cat $HOME/$market_content_workspace/myValues |  awk 'BEGIN{FS=","}; {print($(3))}')
site_folder_name=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(NF))}' )
tmp_folder='/methode/meth01/tmp'
backup_ext=$(echo 'bkfiles')
backup_folder="${site_folder_name}_${backup_ext}"
site_replicationn_ini=$(cat $HOME/$market_content_workspace/$vertical.ini)

#method connection string
CONN="-EOMUser system -EOMPassword syscoxpwd -EOMRepositoryIor /methode/meth01/ior/eomdb1.ior"
CONN_REPO=$(echo $CONN | cut  -f5-6 -d" ")

#remove all empty lines
	sed -i '/^$/d' $HOME/$market_content_workspace/$vertical.ini 



export_eomdb_object ()  {

cd "$workspace"

#create import file
touch $workspace/$import_validated.${NOW}
printf  "echo  v1integration\n" > import_validated.${NOW}
sleep 1
sed -i '1i #!/bin/bash' import_validated.${NOW}
sed -i "s/echo  v1integration//g" import_validated.${NOW}
 

 filesystemrootpath=$(cat $vertical.ini | awk -F '.' '{print $1}' | sed "s/#.*//g" | sed '/^$/d' | uniq)

#add directory to grep Example grep -v '^PortalSites\|^BBC\|^def'
 filesystemrootfullpath=$(cat $vertical.ini | awk -F '::' '{print $1}' | sed "s/#.*//g" | sed '/^$/d' | uniq |  grep -v '^PortalSites' |  sed "s/\./\//g")

echo  "--------------------------------------------------------------------------------------------------------------------"
echo  "Function Export Execution on $HOST"
echo  "--------------------------------------------------------------------------------------------------------------------"

for i in $(echo "$filesystemrootpath")
do
		mkdir "$i"
		chmod 777 "$i"

		#add directory to grep Example grep -v '^PortalSites\|^BBC\|^def'
		if (echo "$i" | grep -q '^PortalSites') && [[ -d "$i" ]] 
		then
			eomutil export /$i  ./$i   -backup  -sys  $CONN
		else 
			eomutil export /$filesystemrootfullpath  ./$i   -backup  -sys  $CONN
		fi

done


 	if [ $? -eq 0 ]
        then
                        printf "SUCCESS: $filesystemroot\n"
        else
                        printf "FAILED:  $filesystemroot\n"
                        exit 1
        fi


}

#create a backup
backup () {

cd "$workspace"

echo  "--------------------------------------------------------------------------------------------------------------------"
echo  "Function Backup Execution on $HOST"
echo  "--------------------------------------------------------------------------------------------------------------------"

cat $HOME/$market_content_workspace/$vertical.ini | while read LINE
do
        if (echo "$LINE" | grep -qv  '^#' )
	then
			export filesystemroot=$(echo $LINE | awk -F'.' '{print $1}')
                        export import_file_name=$(echo "$LINE" | awk -F'::' '{print $2 }')
                        sleep 1
                        export import_file_location=$(find ./$filesystemroot  -name "$import_file_name")
			
	for filename in `find $filesystemroot  -name "$import_file_name" -print`
		do
     			newFileName=${filename/\//-}
		       cp -p $filename $filename.bak

 		if [ $? -eq 0 ]
                then
                        printf "SUCCESS: Copy $filename $filename.bak\n"
                else
                        printf "FAILED:  Copy $filename $filename.bak\n"
                        exit 1
                fi

		done
	fi
done



printf "\n\n"

}


find_search_replace () {


cd "$workspace"


echo  "--------------------------------------------------------------------------------------------------------------------"
echo  "Function Find Search Replace Execution on $HOST"
echo  "--------------------------------------------------------------------------------------------------------------------"
#read each line in file
cat $HOME/$market_content_workspace/$vertical.ini | while read LINE
do



	if (echo "$LINE" | grep -v  '^#' ) 
	then

                        #key value pair system attributes | metadata | content
			export filesystemroot=$(echo $LINE | awk -F'.' '{print $1}')
			export filesystemrootimportpath=$(echo $LINE | awk -F'::' '{print $1}' | uniq |  grep -v  '^#' | sed "s/\./\//g")
                        export key=$(echo $LINE  | awk -F':::' '{print $2}' | awk -F'=' '{print $1}' )
                        export value=$(echo $LINE  | awk -F'=' '{print $2 }'  )
                        export import_file_name=$(echo "$LINE" | awk -F'::' '{print $2 }')
			sleep 1


 			if $(echo "$LINE" |  awk -F '.' '{print $2}' | grep -q "::") && (echo "$LINE" | grep -qv  '^#' )  
        		then
                		sitefoldername=$(echo "$LINE" | awk -F '.' '{print $2}' | awk -F'::' '{print $1}')
				sleep 1
                		cd "$workspace/$filesystemroot/$sitefoldername"
				export import_file_location=$(find . -name "$import_file_name")
				export import_file_location=$(echo "$import_file_location" | sed "s/\.\///g")
                		printf  "$sitefoldername\n"
                		printf "walter2000000\n"
        		elif $(echo "$LINE" |  awk -F '.' '{print $2}' | grep -qv "::") && (echo "$LINE" | grep -qv  '^#' )
        		then
                		cd "$workspace"
                		printf "walter2000\n"
				export import_file_location=$(find ./$filesystemroot -name "$import_file_name")
        		fi


			#element value if exist
			element_value=$(grep -oP "(?<=<$key>).*?(?=</$key>)" $import_file_location)
			element_replace=$(echo "$element_value" | awk -F':' '{print $2}')



			printf "FileSystemRoot == $filesystemroot\n"
			printf "Key == $key\n"
			printf "Value == $value\n"
			printf "Import File Name == $import_file_name\n"
 			printf "Import File From Location ==\n"
                        printf "$import_file_location\n"
			printf "\n"
			sleep 1



	if [[ !  -z "$element_replace" ]]
	then
 		printf "FOUND $element_replace in $import_file_location\n\n"
        fi

 	if  (echo "$value" | grep -qv '/') && [[ -z "${element_replace}" ]]  && [[ ! -z "$filesystemroot" ]] &&  [[ ! -z "$key" ]] &&  [[ !  -z "$value" ]] && [[ !  -z "$import_file_location" ]]
 	then
 		for i in $(echo "$import_file_location")
                do
			value_replace=$(cat "$i" | grep -w "$key" | awk -F'=' '{print $2}' | awk '{$1=$1}{ print }')

                sleep 1

		if [[ ! -z $value_replace ]] && (grep -w "$value_replace" $i)
                then
			sed -i "s/$value_replace/$value/g" $i
		fi


 		if [ $? -eq 0 ] &&  (grep -w "$value" $i) && (echo "$filesystemroot" | grep 'PortalSites')  
                then
                        echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $i\n"
                        IMPORT=$(echo "eomutil import $filesystemroot/$sitefoldername/$import_file_location $filesystemroot/$sitefoldername/$import_file_location  -backup  -sys   $CONN")
		fi

                if [ $? -eq 0 ] && (grep -w "$value" $i) && (echo "$filesystemroot" | grep -v 'PortalSites') 
                then
                        echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $i\n"
                  	IMPORT=$(echo "eomutil import $filesystemrootimportpath/$import_file_name $import_file_location -backup  -sys   $CONN")

                fi
		done

		for i in $(echo $import_file_location)
		do

		if (grep -w "$value" $i)
		then
			echo "$IMPORT" >> $workspace/import_validated.${NOW}
                        echo "sleep 5" >> $workspace/import_validated.${NOW}
		fi

		done
                	echo " --------------------------------------------------------------------------------------------------------------------"
fi

 if  (echo "$value" | grep  '/' )  && [[  -z "${element_replace}" ]] && [[ !  -z "$import_file_location" ]] && [[ !  -z "$filesystemroot" ]] && [[ !  -z "$key" ]] &&  [[ !  -z "$value" ]] 
 then
		for i in $(echo "$import_file_location")
		#for i in $(find ./$filesystemroot  -name "$import_file_name"))
		do
 			value_replace=$(cat "$i" | grep -w "$key" | awk -F'=' '{print $2}' | awk '{$1=$1}{ print }')

                sleep 1

                        printf "walter 50000 $value_replace\n"

		if [[ ! -z "$value_replace" ]]
		then
                        sed -i "s!${value_replace}!$value!g"  $i
		fi

 			if [ $? -eq 0 ] &&  (grep -w  "$value" $i) 
                	then
				echo " --------------------------------------------------------------------------------------------------------------------"
                        	printf "SUCCESS: $value substitution in $i\n"
				IMPORT=$(echo "echo eomutil import walter $import_file_location $import_file_location -backup  -sys   $CONN")
                	fi
		done

		for i in $(echo $import_file_location)
		do
			echo "$IMPORT" >> $workspace/import_validated.${NOW}
                        echo "sleep 5" >> import_validated.${NOW}
		done
                        echo " --------------------------------------------------------------------------------------------------------------------"

###########################################################################################################################################################################
        if  (echo "$value" | grep -qv '/') && ( echo "${element_replace}"|grep -qv '/') && [[ !  -z "${element_replace}" ]]  && [[ ! -z "$filesystemroot" ]] &&  [[ ! -z "$key" ]] &&  [[ !  -z "$value" ]] && [[ !  -z "$import_file_location" ]]   
	then
                sleep 1

 	for i in $(echo "$element_replace")
             do
 		sed -i "s/${i}/$value/g" $i

 		if [ $? -eq 0 ] && (grep -w  "$value" $i) 
                then
                        echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $i\n"
                        IMPORT=$(echo "echo eomutil import ./$filesystemroot/$sitefoldername/$import_file_location ./$filesystemroot/$sitefoldername/$import_file_location  -backup  -sys   $CONN")
                elif [ $? -eq 0 ] &&  (grep -w  "$value" $i) 
                then
                        echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $i\n"
                        IMPORT=$(echo "echo eomutil import ./$filesystemrootimportpath/$import_file_name $filesystemroot/$import_file_location -backup  -sys   $CONN")
                fi

 	      done 

		for i in $(echo $import_file_location)
		do
 			echo "$IMPORT" >> $workspace/import_validated.${NOW}
			echo "sleep 5" >> $workspace/import_validated.${NOW}
		done
 		echo " --------------------------------------------------------------------------------------------------------------------"

         fi

# may need to add sed -i "s/$key.*/$value/g" $import_file_location
        
	elif  (echo "$value ${element_replace}" | grep  '/' )  && ( echo "${element_replace}" | grep  '/')  && [[ !  -z "${element_replace}" ]] && [[ !  -z "$import_file_location" ]] && [[ !  -z "$filesystemroot" ]] && [[ !  -z "$key" ]] &&  [[ !  -z "$value" ]] && [[ ! -z "$import_file_location" ]] 
	then
	
		sleep 1

	for i in $(echo "$element_replace")
		do
			sed -i "s!${i}!$value!g"  $i

 		if [ $? -eq 0 ] &&  (grep -w  "$value" $i) 
                then
                        echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $i\n"
                        IMPORT=$(echo "echo eomutil import ./$filesystemroot/$sitefoldername/$import_file_location ./$filesystemroot/$sitefoldername/$import_file_location  -backup  -sys   $CONN")
                elif [ $? -eq 0 ] &&  (grep -w  "$value" $i) 
                then
                        echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $i\n"
                        IMPORT=$(echo "echo eomutil import ./$filesystemrootimportpath/$import_file_name $filesystemroot/$import_file_location -backup  -sys   $CONN")
                fi

		done

		for i in $(echo "$import_file_location")
		do
 			echo "$IMPORT" >> $workspace/import_validated.${NOW}
			echo "sleep 5" >> $workspace/import_validated.${NOW}
		done
 			echo " --------------------------------------------------------------------------------------------------------------------"
fi # I walter hicks
fi
done

printf "\n\n"

}

validation ()  {
 echo " --------------------------------------------------------------------------------------------------------------------"
 echo "Validation Function Execution\n"
 echo "---------------------------------------------------------------------------------------------------------------------"

cat $HOME/$market_content_workspace/$vertical.ini | while read LINE
do

 if $(echo "$LINE" | awk -F '.' '{print $3}' | grep '::')
 then
        sitefoldername=$(echo "$LINE" | awk -F '.' '{print $2}')
        cd "$workspace/$sitefoldername"
 else
        cd "$workspace"
 fi

        if (echo "$LINE" | grep -qv  '^#' )
        then

 			export filesystemroot=$(echo $LINE | awk -F'.' '{print $1}')
                        export value=$(echo $LINE  | awk -F'=' '{print $2 }'  )
                        export import_file_name=$(echo "$LINE" | awk -F'::' '{print $2 }')
                        sleep 1
                        export import_file_location=$(find ./$filesystemroot  -name "$import_file_name")

      	#for filename in `find $filesystemroot  -name "$import_file_name" -print`
	for filename in $(echo "$import_file_location")
       	do
                         	diff -s $filename $filename.bak  
	if [ $? -ne 0 ] # && (grep -w  "$value" $filename) && [[ ! -z $filename ]] 
	then
			printf "SUCCESS: $filename updated\n"
	else
 			printf "NOT REQUIRED: $filename updated\n"
	fi
	done
fi
done

}

import () {

cd "$workspace"

echo " --------------------------------------------------------------------------------------------------------------------"
printf "Function Importing on $HOST\n"
echo " --------------------------------------------------------------------------------------------------------------------"

	#for object in $(cat /methode/meth01/tmp/walter/CMGT/import |  awk -F'.' '{print $1}' | uniq | grep -v  '^#' )
if [[ -e import_validated.${NOW}  ]] && [[ ! -z import_validated.${NOW} ]] 
then

#remove duplicate lines
	perl -i -nle 'unless($hash{$_}++){print $_}'  import_validated.${NOW}

	cat import_validated.${NOW}

	#execute import
	chmod 775 import_validated.${NOW}
	printf "exit\n" >> ./import_validated.${NOW}
	./import_validated.${NOW} >> ./import_results.${NOW}

	printf "\n"
	cat import_results.${NOW}
#if (grep -i 'error\|failure' import_results.${NOW})
#then
#	printf "Import failed check logs https://dplutladm1.ddtc.cmgdigital.com/replication/logs\n"
#fi 

else
        printf "File ./import_validated.${NOW} DOES NOT EXIST or NULL\n" 
        exit 1
fi


termin=$(date +"%s")
difftimelps=$(($termin-$begin))
printf "\n"
echo " --------------------------------------------------------------------------------------------------------------------"
echo "$(($difftimelps / 60)) minutes and $(($difftimelps % 60)) seconds elapsed for Script Execution"
echo " --------------------------------------------------------------------------------------------------------------------"



}


#Functions
export_eomdb_object
backup
find_search_replace
#validation is handle in find_search_replace 
import
