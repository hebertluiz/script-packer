#!/bin/bash 

## Error types
declare -A errors
errors[0]="Generic Error   "
errors[1]="File Error      "
errors[2]="Running as root "
errors[3]="Invalid Argument"



function error () {
    if [ "$1" -ne 0 ];
    then 
        printf "%s -[%s] %s\n" "$(date +%D\ %T)" "${errors[$1]}" "$2" 1>&2
        exit "$1"
    else 
        printf "%s -[%s] %s\n" "$(date +%D\ %T)" "${errors[$1]}" "$2" 1>&2
    fi
}


declare -A levels
levels[0]="INFO"
levels[1]="NOTICE"
levels[2]="ALERT"
levels[3]="TRACE"
levels[4]="ERROR"


VERBOSE=0
function verbose () {
    # $1 - level
    # $2 - msg 
    # $3 - error
    if [ "$1" -ge "1" ]
    then 
        [ "$1" -le "$VERBOSE" ] && printf "%s -[%s] %s\n" "$(date +%D\ %T)" "${levels[$1]}" "$2" 1>&2
    else 
        printf "%s\n" "$2" 1>&2
    fi
}

