#!/bin/bash

HOME='/var/www/html/replication'
cd $HOME/logs
 
LOGFILE=$(ls -t | head -1)

#cONVERT LOGS TO HTML
        echo "$LOGFILE converted from text to html format"
        sed -i "s/^.*$/&<br\/>/" $LOGFILE
        sed -i "s/Function/<h1>Function/g" $LOGFILE
        sed -i "/Function.*/ s/$/<\/h1>/" $LOGFILE
        sed -i "1 i <!DOCTYPE HTML>" $LOGFILE
        sed -i "2 i <html>" $LOGFILE
        sed -i "3 i <head>" $LOGFILE
        sed -i "4 i <body>" $LOGFILE
        sed -i '$a\ <\/html>' $LOGFILE
        sed -i '$a\ <\/head>' $LOGFILE
        sed -i '$a\ <\/body>' $LOGFILE
 	sed -i "s/FAILURE.*$/<font color=\"red\">&<br\/>/" $LOGFILE
	sed -i "s/email.*$/email<\/font>/" $LOGFILE
	sed -i "s/FOUND/<font color=\"DarkGreen\">.........................................................................FOUND<\/font>/" $LOGFILE
	sed -i "s/NOT-LOCATED/<font color=\"DarkGreen\">..........................................................NOT-LOCATED<\/font>/" $LOGFILE
	sed -i "s/UPDATED_TO/<font color=\"DarkViolet\">...........................................................UPDATED_TO<\/font>/" $LOGFILE
	sed -i "s/PASS VALIDATION/<font color=\"DarkBlue\">.........................................................................PASS VALIDATION<\/font>/" $LOGFILE
	sed -i "s/NULL VALUE/<font color=\"SandyBrown\">..................................................................NULL VALUE<\/font>/" $LOGFILE

sed -i "s/^< /<font color=red/<\/font>/ " $LOGFILE
<font color=red>< siteParent = np-alan<br/></font>
<font color=red>< siteParent = np-alan<br/></font>

	#remove after u update script
 	sed -i "s/^grep.*//g" $LOGFILE 


