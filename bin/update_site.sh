#!/bin/bash

# update_site.sh - export every version of files in a github repo to date-stamped directory tree

ABS=$(readlink -f $0)
DIR=$(dirname $ABS)
REPO=$DIR/../../pcdm
DEST=$DIR/../_site

TMP_F=$( mktemp )

function export_versions
{
  LATEST=""
  FILE=$1
  BASE_FILE=$( basename "$FILE" .rdf )
  read LINE
  while [ "$LINE" ]; do
    # export file at that version
    HASH=$( echo "$LINE" | cut -d\  -f1 )
    cd $REPO
    git show $HASH:$FILE > $TMP_F
    DATE=$( grep versionInfo $TMP_F | sed -e's/<\/.*//' -e's/.*>//' )

    # copy file to date-stamped directory
    echo "$FILE@$HASH -> $DEST/$DATE/$BASE_FILE.rdf"
    mkdir -p $DEST/$DATE
    cp $TMP_F $DEST/$DATE/$BASE_FILE.rdf
    cp -v $REPO/*.xsl $DEST/$DATE/

    # make sure there is a .xml version
    cd $DEST/$DATE
    if [ ! -f $BASE_FILE.xml ]; then
      ln -s $BASE_FILE.rdf $BASE_FILE.xml
    fi

    # if this is the first version, record as current version
    if [ ! -f "$DEST/$BASE_FILE.rdf" ]; then
      cd $DEST
      ln -s $DATE/$BASE_FILE.rdf $DEST/$BASE_FILE.rdf
      ln -s $DATE/$BASE_FILE.rdf $DEST/$BASE_FILE.xml
    fi

    # get next line
    read LINE
  done
}

# create or clear destination
if [ ! -d $DEST ]; then
  mkdir $DEST
else
  rm -f $DEST/*.*
fi

# copy index
cp $DIR/index.html $DEST/

# make a list of rdf files
cp $REPO/*.xsl $DEST/
cd $REPO
FILES=$(find * -type f -name "*.rdf")

# export datestamped versions of every rdf file
for f in $FILES; do
  echo "$f"
  git log --format="%H %as" $f | export_versions $f
done
