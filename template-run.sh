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
tail -n +"$SCRIPT_END" "$0" | base64 -d - >> "$WORKDIR/OUTFILE_NAME"

mdsum="$(grep MD5SUM- "$0" | cut -d \- -f 2)"
if [ ! "$mdsum" = "$(md5sum $WORKDIR/OUTFILE_NAME | cut -d ' ' -f 1)" ]
then
  echo "File currupted"
  exit 2
fi

# Do something with the file
echo Here\'s your file:

tar xf "$WORKDIR/OUTFILE_NAME"
"$WORKDIR/RUN_SCRIPT"

echo Deleting...
rm -r "$WORKDIR"
exit 0

## MD5SUM-FILE

# Here's the end of the script followed by the embedded file
___END_OF_SHELL_SCRIPT___
