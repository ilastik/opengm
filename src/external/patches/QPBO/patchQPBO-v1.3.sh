#!/bin/sh

# This script loads QPBO-LIB v 1.3 from http://pub.ist.ac.at/~vnk/software.html and applies a patch to make QPBO-LIB workable with openGM.
# See README.txt for details.

ZIP_FOLDER=../zip_files/
PATCH_FOLDER=./
QPBO_FILENAME=QPBO-v1.3.src.tar.gz
QPBO_URL=http://pub.ist.ac.at/~vnk/software/
QPBO_SOURCE_FOLDER=../../QPBO-v1.3.src-patched/
QPBO_PATCH_NAME=QPBO-v1.3.patch

# check if destination folder already exists
if [ -e "$QPBO_SOURCE_FOLDER" ]
then 
	echo "Source folder already exists, skipping patch."
	exit 0
else
    mkdir $QPBO_SOURCE_FOLDER
fi

# download QPBO
echo "Getting $QPBO_FILENAME from $QPBO_URL ..."
if [ -e "$ZIP_FOLDER$QPBO_FILENAME" ]
then
    echo "$QPBO_FILENAME already exists, skipping download."
else
    wget -q $QPBO_URL$QPBO_FILENAME -P $ZIP_FOLDER
fi

# check if download was successful
if [ -e "$ZIP_FOLDER$QPBO_FILENAME" ]
then :
else
    echo "Couldn't download $QPBO_FILENAME. Check if $QPBO_URL$QPBO_FILENAME is reachable!"
    exit 1
fi

# extract files
echo "Extracting files from $QPBO_FILENAME"
tar xfz $ZIP_FOLDER$QPBO_FILENAME -C $QPBO_SOURCE_FOLDER --strip-components 1
if [ "$?" = "0" ]
then :
else
    echo "Couldn't extract $QPBO_FILENAME."
    exit 1
fi

# run patch
echo "Patching files..."
patch -s -d $QPBO_SOURCE_FOLDER -p1 < $PATCH_FOLDER$QPBO_PATCH_NAME -N -r -
if [ "$?" = "0" ]
then 
    echo "Patching files done"
else
    echo "Couldn't run patch"
    exit 1
fi


# Combine all cpp files into a single translation unit to avoid linker errors on OS X.
# These errors should not exists because QPBO uses the 'inline' keyword in the appropriate places,
# but nonetheless, OS X complains.
#
# See, for example:
# 1. https://groups.google.com/forum/#!topic/pystruct/WWSF7AI6X6w
# 2. http://stackoverflow.com/questions/15298603/linking-errors-from-matlab-mex-library
#
# (In link 2, the user is trying to build MatLab bindings, but that is irrelevant to this error.)

# Note that our CMakeLists.txt file has already been modified to use COMBINED_QPBO.cpp
echo "Combining all QPBO source files into a single translation unit..."
cat ${QPBO_SOURCE_FOLDER}/QPBO*.cpp      > ${QPBO_SOURCE_FOLDER}/COMBINED_QPBO.cpp
cat ${QPBO_SOURCE_FOLDER}/instances.inc >> ${QPBO_SOURCE_FOLDER}/COMBINED_QPBO.cpp
echo "Finished combining QPBO source files."
