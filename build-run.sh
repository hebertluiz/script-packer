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

source ./functions/log_console.sh


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
while getopts ":f:d:o:p:v:hD" opt; do
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
            VERBOSE="$OPTARG"
        ;;
        D) # set debug and verbose 
            # VERBOSE=10
            set -x
        ;;
        h) # show help and info
            echo "$BRIEF" 1>&2
            usage "" 1>&2
            exit 0
        ;;
        \?) # Generic case for invalid options 
            usage error 1>&2
            error 3 "-$OPTARG is not a valid option: " 
        ;;
        :) # Case for empty values
            if [ "$OPTARG" = 'v' ]
            then
                VERBOSE=1
            else
                error 4 "-$OPTARG requires an argument"
            fi
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
    error 1 "File $outfile_name is not empty"

fi



## Check input files
if [ -z "$tar_to_pack" ]; 
then 
    PACK_DIR=true 
    verbose 1 "Selecting directory $dir_to_pack"
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
    verbose 1 "Selecting file $tar_to_pack"
    if [ ! -r "$tar_to_pack" ]
    then
        error 1 "Cant read $tar_to_pack"
    fi

    if ! tar tf "$tar_to_pack"  &>/dev/null 
    then
        error 1 "Invalid Tar File $tar_to_pack"
    fi 
    
fi


outfile="$outfile_path/${outfile_name:-run.sh}"
[ -z "$package_name" ] && package_name="packaged-run.sh"

verbose 1 "Setting output to $outfile"
verbose 1 "Package Name: $package_name"

# shellcheck disable=SC2034  # Unused variables left temporarily
template_bootstrap_script="template-run.sh" 
# shellcheck disable=SC2034
packed_file=package.tar.gz


WORKDIR=$(mktemp -d)
cd "$WORKDIR" || error 1 "Cant create $WORKDIR" 
verbose 1 "Working on directory $WORKDIR"

## Packing files if needed 
if $PACK_DIR 
then 
    # TODO Generate Tar file from $dir_to_pack 
    verbose 2 "Creating file $packed_file"
    verbose 0 "Compressing files..."
    tar cf "$packed_file" "$dir_to_pack"
else
    verbose 1 "Coping $tar_to_pack to temporary directory"
    verbose 0 "Coping file..."
    \cp -a "$tar_to_pack" "$packed_file"
fi

verbose 1 "Creating MDSUM of $packed_file"
MDSUM=$(md5sum $packed_file | cut -d ' ' -f 1)
verbose 2 "File $packed_file MDSUM=$MDSUM"

# TODO Embed the file after the script in run.sh
# TODO Replace RUN_SCRIPT
# TODO Replace OUTFILE_NAME
# TODO Compress the outfile if needed 


rm -rf "$WORKDIR"
verbose 1 "Removed $WORKDIR"
exit 0

