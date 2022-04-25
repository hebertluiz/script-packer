#!/bin/bash

HEADER='
Author: Hebert L Silva | https://github.com/hebertluiz
License: MIT

'
BRIEF='
Simple script/environment to build a self extracting shellscript installer

'

programname=$0
VERBOSE=false

function verbose () {
    $VERBOSE && printf "%s -| VERBOSE: %s\n" "$(date +%D\ %T)" "$*" 1>&2
}

function error () {
    printf "%s -| ERROR: %s\n" "$(date +%D\ %T)" "$*" 1>&2
}

function usage () {
    echo "$HEADER"
    echo "Usage: $programname [-vD|-h] <-i outfile.tar.gz> <-d </dir/to/pack/>"  
    echo "  -i <FILEPATH>"  
    echo "  -d <FILEPATH>   Source directory for the package"  
    echo "  -v              Show verbose output"
    echo "  -D              Show debug output  "
}

#### Parsing OPTS
while getopts ":i:d:vhD" opt; do
    case ${opt} in 
        i) #opt Install outfile
            outfile_package="$OPTARG"
        ;;
        d) # dir to pack
            dir_to_pack="$OPTARG"
        ;; 
        v) 
            VERBOSE=true
        ;;
        D) 
            VERBOSE=true
            set -vx
        ;;
        h) 
            echo "$BRIEF" 1>&2
            usage 1>&2
        ;;
        \?) 
            error "Invalid Option: -$OPTARG" 
            usage 1>&2
        ;;
    esac
done

verbose "Checking Options:"
verbose "Outfile: $outfile_package"
verbose "Dir To Pack: $dir_to_pack"

## check if we can write to output file 
if [ -z "$outfile_package" ];
then 
    error Invalid outfile
    usage
    exit 1
else
    : # TODO Check if file exists to prevent overwrite.
fi

if [ ! -d "$dir_to_pack" ];
then 
    error Source dir does not exist
    usage
    exit 1
fi


# TODO Generate Tar file from $dir_to_pack
# TODO Covert Tarfile to base64 
# TODO Pack the base64 inside the shellscript
# TODO Generate a MD5 SUM of file to compare

# shellcheck disable=SC2034  # Unused variables left temporarily
template_bootstrap_script="template-run.sh"; 
# shellcheck disable=SC2034
packed_file=install.tar.gz



exit 0

