#!/bin/bash  

begin=$(date +"%s")
bak=$(echo bak)

cd /methode/meth01/tmp/walter
HOME='/methode/meth01/tmp/walter'
NCD_CONTENT=NCD_CONTENT-10-19-2016-20-36-01
market_content_workspace=Athens-Radio-CONTENT-11-29-2016-09-19-58

#Site Replication Process

NOW=$(date +"%m-%d-%Y-%H-%M-%S")
#exec > $HOME/$market_content_workspace/logs//$market_content.log.$NOW 2>&1
SERVER_FILE=$HOME/server.xml
HOST=$(hostname)

env=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(1))}' | cut -f3 -d_)
env_description=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(1))}')
market=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(2))}')
existing_market_content=$(cat $HOME/$market_content_workspace/myValues |  awk 'BEGIN{FS=","}; {print($(3))}')
site_folder_name=$(cat $HOME/$market_content_workspace/myValues | awk 'BEGIN{FS=","}; {print($(NF))}' )
tmp_folder='/methode/meth01/tmp'
backup_ext=$(echo 'bkfiles')
backup_folder="${site_folder_name}_${backup_ext}"
site_replicationn_ini=$(cat $HOME/$market_content_workspace/site-replication.ini)

#method connection string
CONN="-EOMUser system -EOMPassword syscoxpwd -EOMRepositoryIor /methode/meth01/ior/eomdb1.ior"
CONN_REPO=$(echo $CONN | cut  -f5-6 -d" ")


#remove all empty lines
	sed -i '/^$/d' /methode/meth01/tmp/walter/CMGT/site-replication.ini 

#remove import file
#rm import_validated

printf "#!/bin/bash -e\n" > import_validated.${NOW}

#create a backup
backup () {

echo  "--------------------------------------------------------------------------------------------------------------------"
echo  "Function Backup Execution"
echo  "--------------------------------------------------------------------------------------------------------------------"
cat /methode/meth01/tmp/walter/CMGT/site-replication.ini | while read LINE
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
echo  "--------------------------------------------------------------------------------------------------------------------\n"
echo  "Function Find Search Replace Execution"
echo  "--------------------------------------------------------------------------------------------------------------------\n"
#read each line in file
cat /methode/meth01/tmp/walter/CMGT/site-replication.ini | while read LINE
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
                        export import_file_location=$(find ./$filesystemroot  -name "$import_file_name")

			#element value if exist
			element_value=$(grep -oP "(?<=<$key>).*?(?=</$key>)" $import_file_location)
			element_replace=$(echo "$element_value" | awk -F':' '{print $2}')



			printf "FileSystemRoot = $filesystemroot\n"
			printf "Key = $key\n"
			printf "Value = $value\n"
			printf "Import File Name = $import_file_name\n"
			printf "Import File From Location = $import_file_location\n"
			printf "\n"
			sleep 1


	if [[ !  -z "$element_replace" ]]
	then
 		printf "Element $element_replace found in $import_file_location\n\n"
        fi

 	if [[   -z "$element_replace" ]]
        then
                printf "Found  $import_file_location\n\n"
        fi
###########################################################################################################################################################################
 if  (echo "$value" | grep -qv '/') && [[ -z "${element_replace}" ]]  && [[ ! -z "$filesystemroot" ]] &&  [[ ! -z "$key" ]] &&  [[ !  -z "$value" ]] && [[ !  -z "$import_file_location" ]]
 then
 		for i in $(echo "$import_file_location")
                do
			value_replace=$(cat "$i" | grep -w "$key" | awk -F'=' '{print $2}' | awk '{$1=$1}{ print }')

                printf "walter  value_replace walter200  ${value} "
                sleep 1

                printf "walter 10000 $element_multiple_replace\n"
		if [[ ! -z $value_replace ]]
                then

		sed -i "s/$value_replace/$value/g" $import_file_location
		fi

		done

                if [ $? -eq 0 ]
                then
			echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $import_file_location\n"
                else
			echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "FAILED: $value substitution  in $import_file_location\n"
                        exit 1
                fi
 
        if (grep -w "$value" $import_file_location)
        then
                        printf "SUCCESS $value updated in\n"
			printf " $import_file_location\n"
for i in $(echo $import_file_location)
do
                        echo "replace eomutil import ./$filesystemrootimportpath/$import_file_name $i -backup  -sys   $CONN" >> import_validated.${NOW}
                        echo "sleep 5" >> import_validated.${NOW}
done
                echo " --------------------------------------------------------------------------------------------------------------------"
         fi
fi

#########################################################################################################################################################################
 if  (echo "$value" | grep  '/' )  && [[  -z "${element_replace}" ]] && [[ !  -z "$import_file_location" ]] && [[ !  -z "$filesystemroot" ]] && [[ !  -z "$key" ]] &&  [[ !  -z "$value" ]] 
 then
		for i in $(echo "$import_file_location")
		do
 			value_replace=$(cat "$i" | grep -w "$key" | awk -F'=' '{print $2}' | awk '{$1=$1}{ print }')

                sleep 1
                #element_multiple_replace=$(echo "${element_replace}" | head -1)

                        printf "walter 50000 $value_replace\n"

		if [[ ! -z $value_replace ]]
		then
                        sed -i "s!${value_replace}!$value!g"  $import_file_location
		fi

		done


 			if [ $? -eq 0 ]
                	then
				echo " --------------------------------------------------------------------------------------------------------------------"
                        	printf "SUCCESS: $value substitution in $import_file_location\n"
                	else
				echo " --------------------------------------------------------------------------------------------------------------------"
                        	printf "FAILED: $value substitution  in $import_file_location\n"
                        exit 1
                	fi


                if (grep -w "$value" $import_file_location)
                then
                        printf "SUCCESS: $value updated in\n"
			printf " $import_file_location\n"

		for i in $(echo $import_file_location)
		do
                        echo "replace eomutil import ./$filesystemrootimportpath/$import_file_name $i -backup  -sys   $CONN\n" >> import_validated.${NOW}
                        echo "sleep 5" >> import_validated.${NOW}
		done
                        echo " --------------------------------------------------------------------------------------------------------------------"
                fi

fi

###########################################################################################################################################################################
        if  (echo "$value" | grep -qv '/') && ( echo "${element_replace}"|grep -qv '/') && [[ !  -z "${element_replace}" ]]  && [[ ! -z "$filesystemroot" ]] &&  [[ ! -z "$key" ]] &&  [[ !  -z "$value" ]] && [[ !  -z "$import_file_location" ]]   
	then
		printf "walter  ${element_replace} walter200  ${value} "
                sleep 1

#		element_multiple_replace=$(echo "${element_replace}" | head -1)
 	for i in $(echo $element_replace)
             do
                printf "walter 40000 $element_multiple_replace\n"
 		sed -i "s/${i}/$value/g" $import_file_location
             done

		if [ $? -eq 0 ]
                then
			echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $import_file_location\n"
                else
			echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "FAILED $value substitution in $import_file_location\n"
                        exit 1
                fi

  
	if (grep -w "$value" $import_file_location)
        then
                        printf "SUCCESS: $value updated in\n"
			printf " $import_file_location\n"

		for i in $(echo $import_file_location)
		do
                        echo "replace eomutil import ./$filesystemrootimportpath/$import_file_name $i -backup  -sys   $CONN" >> import_validated
			echo "sleep 5" >> import_validated
		done
 		echo " --------------------------------------------------------------------------------------------------------------------"
         fi

                #sed -i "s/${element_multiple_replace}/$value/g" $import_file_location
# may need to add sed -i "s/$key.*/$value/g" $import_file_location
        
	elif  (echo "$value ${element_replace}" | grep  '/' )  && ( echo "${element_replace}"|grep  '/')  && [[ !  -z "${element_replace}" ]] && [[ !  -z "$import_file_location" ]] && [[ !  -z "$filesystemroot" ]] && [[ !  -z "$key" ]] &&  [[ !  -z "$value" ]] && [[ ! -z "$import_file_location" ]] 
	then
		sleep 1
		#element_multiple_replace=$(echo "${element_replace}" | head -1)

	for i in $(echo $element_replace)
		do
			printf "walter 20000 $element_multiple_replace\n"
			sed -i "s!${i}!$value!g"  $import_file_location
		done

		if [ $? -eq 0 ]
                then
			echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "SUCCESS: $value substitution in $import_file_location\n"
                else
			echo " --------------------------------------------------------------------------------------------------------------------"
                        printf "FAILED: $value substitution in $import_file_location\n"
                        exit 1
                fi

  		if (grep -w "$value" $import_file_location)
                then
                        printf "SUCCESS: $value updated in\n"
			printf " $import_file_location\n"

		for i in $(echo $import_file_location)
		do
 			echo "replace eomutil import ./$filesystemrootimportpath/$import_file_name $i -backup  -sys   $CONN\n" >> import_validated
			echo "sleep 5" >> import_validated 
		done
 			echo " --------------------------------------------------------------------------------------------------------------------"
                fi




#	if  (echo "$value" | grep  '/' ) && (echo "$element_replace" | grep  '/') && [[ ! -z  "$element_replace" ]]
#	then
#			sed -i "s!$element_replace!$value!g"  $import_file_location
#        fi

# 	if   (echo "$value" | grep -v  '/' ) &&  (echo "$element_replace" | grep -v  '/') && [[ ! -z  "$element_replace" ]]  
#	then
#			sed -i "s/$element_replace/$value/g"  $import_file_location 
#	fi

fi
fi
done

printf "\n\n"

}


validation ()  {
 echo " --------------------------------------------------------------------------------------------------------------------"
 echo "Validation Function Execution\n"
 echo "---------------------------------------------------------------------------------------------------------------------"

cat /methode/meth01/tmp/walter/CMGT/site-replication.ini | while read LINE
do
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
	if [ $? -ne 0 ] # && (grep -w  "$value" $filename) 
	then
			printf "SUCCESS: $filename updated\n"
	fi
	done
fi
done

}

import () {

echo " --------------------------------------------------------------------------------------------------------------------"
printf "Function Importing EOMDB Objects in file import_validated.${NOW} \n"
echo " --------------------------------------------------------------------------------------------------------------------"

	#for object in $(cat /methode/meth01/tmp/walter/CMGT/import |  awk -F'.' '{print $1}' | uniq | grep -v  '^#' )
if [[ -e import_validated.${NOW}  ]] && [[ ! -z import_validated.${NOW} ]] 
then

	printf "EOMDB Objects importing.......\n\n"
	cat import_validated.${NOW}

	#execute import
	chmod 775 import_validated.${NOW}
	./import_validated.${NOW}
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
backup
find_search_replace
#validation
import
