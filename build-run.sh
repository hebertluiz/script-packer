#!/bin/bash

## Text 
HEADER='Author: Hebert L Silva | https://github.com/hebertluiz
License: MIT
'
BRIEF='Script Packer:
    Simple script/environment to build a self extracting shellscript installer
'
## Global variables
programname=$0
VERBOSE=0


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


function verbose () {
    if [ "$1" -ge "1" ]
    then 
        printf "%s -[%s] %s\n" "$(date +%D\ %T)" "${levels[$1]}" "$2" 1>&2
    else 
        printf "%s\n" "$2" 1>&2
    fi
}

function usage () {
    [ "$1" = "error" ] || echo "$HEADER"
    cat << USAGE_MSG
Usage: $programname [-vDc|-h] [-p PACKAGE_NAME ] 
    [-o run.sh ] <-d </dir/to/pack/>|-f <TARFILE_PATH>>  

Comand-line Options:
    -c                      Compress outfile with gzip
    -d <DIR_PATH>           Source directory for the package  
    -f <TARFILE_PATH>       Tar file to embed into script outfile
    -h                      Show this help message
    -o <FILE_PATH>          Outfile, optional. Will be set as <PACKAGE_NAME->run.sh  
    -p <PACKAGE_NAME>       Name of output package
    -v                      Show verbose output
    -D                      Show debug output (implies verbose on)
USAGE_MSG


}

#### Parsing OPTS
while getopts "f:d:o:p:v:hD" opt; do
    case ${opt} in 
        p) #opt packagename
            package_name="${OPTARG:-package}"
        ;;
        o) #opt Install outfile

            # FIXME Better outfile path sanitizing 
            outfile_name="$(basename "$OPTARG")"
            unsafe_path="$(dirname "$OPTARG")"
            outfile_path="${unsafe_path:-.}"
            unset unsafe_path

        ;;
        d) # dir to pack
            dir_to_pack="$OPTARG"
        ;; 
        f) # tar file to include in script
            tar_to_pack="$OPTARG"
        ;;
        v) # set verbose output
            if [ "$OPTARG" = ':' ];
            then 
                VERBOSE++ 
            fi
        ;;
        D) # set debug and verbose 
            VERBOSE=true
            set -vx
        ;;
        h) # show help and info
            echo "$BRIEF" 1>&2
            usage "" 1>&2
            exit 0
        ;;
        \?) # Generic case for invalid options 
            usage error 1>&2
            error 3 "Invalid Option: -$OPTARG" 
        ;;
    esac
done
shift $((OPTIND -1))

if [ "$(id -u)" -eq '0' ];
then
    error 2 "Not supported"
fi

## Check output file
# Preventing actin on / (root)
[ -z "$outfile_path" ] && outfile_path='.'

if ! err="$(touch "$outfile_path/$outfile_name" 2>&1)";
then 
    error 0 "Cant create Outfile: $outfile_name"
    error 1 "Reason: $err"

elif [ -s "$outfile_path/${outfile_name:-run.sh}" ]
then 
    # TODO Check if file exists to prevent overwrite.
    error 1 "File $outfile_name is not empty"

fi

outfile="$outfile_path/${outfile_name:-run.sh}"


## Check input files
if [ -z "$tar_to_pack" ]; 
then 
    PACK_DIR=true 
    
    if [ ! -d "$dir_to_pack" ];
    then 
        error 1 "Source dir does not exist"
    fi

    if [ ! -r "$dir_to_pack" ];
    then 
        error 1 "Fail to read files in source directory" 
    fi
else
    
    PACK_DIR=false
    if [ ! -r "$tar_to_pack" ]
    then
        error 1 "Cant read $tar_to_pack"
    fi

    if ! tar tf "$tar_to_pack" 
    then
        error 1 "Invalid Tar File $tar_to_pack"
    fi 
    
fi


# TODO Generate Tar file from $dir_to_pack
# TODO Covert Tarfile to base64 
# TODO Pack the base64 inside the shellscript
# TODO Generate a MD5 SUM of file to compare

# shellcheck disable=SC2034  # Unused variables left temporarily
template_bootstrap_script="template-run.sh"; 
# shellcheck disable=SC2034
packed_file=package.tar.gz

echo "Outfile: $outfile"
echo "Package Name: $package_name"

if $PACK_DIR 
then 
    echo "Dir To Pack: $dir_to_pack"
else
    echo "Tar To Pack: $tar_to_pack"
fi



exit 0

