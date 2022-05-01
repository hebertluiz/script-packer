#!/bin/bash
WORKDIR=$( mktemp -d )
 
#find last line +1

SCRIPT_END=$( awk '
  BEGIN { err=1; } 
  /^\w*___END_OF_SHELL_SCRIPT___\w*$/ { print NR+1; err=0; exit 0; } 
  END { if (err==1) print "?"; }
' "$0" )
 
# check for error
 
if [ "$SCRIPT_END" == '?' ]
then
   echo Can\'t find embedded file
   exit 1
fi
# Extract file
tail -n +"$SCRIPT_END" "$0" >"$WORKDIR/OUTFILE_NAME"
 
# Do something with the file
echo Here\'s your file:
tar zxf OUTFILE_NAME
"$WORKDIR/RUN_SCRIPT"
echo Deleting...
rm -r "$WORKDIR"
exit 0

## MD5SUM-FILE

# Here's the end of the script followed by the embedded file
___END_OF_SHELL_SCRIPT___