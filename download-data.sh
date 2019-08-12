
set -e
set -o pipefail

# Use the OpenPBTA bucket as the default.
URL=${BASEURL:-https://s3.amazonaws.com/kf-openaccess-us-east-1-prd-pbta/data}
RELEASE=${REL:-release-v2-20190809}

# The md5sum file provides our single point of truth for which files are in a release.
curl --create-dirs $URL/$RELEASE/md5sum.txt -o data/$RELEASE/md5sum.txt -z data/$RELEASE/md5sum.txt

# Consider the filenames in the md5sum file + release-notes.md
FILES=(`tr -s ' ' < data/$RELEASE/md5sum.txt | cut -d ' ' -f 2` release-notes.md)

# Download the items in FILES if newer than what's on server
for file in "${FILES[@]}"
do
  curl --create-dirs $URL/$RELEASE/$file -o data/$RELEASE/$file -z data/$RELEASE/$file
done

# Check the md5s for everything we downloaded except release-notes.md
cd data/$RELEASE
md5sum -c md5sum.txt
cd ../../

# Make symlinks in data/ to the files in the just downloaded release folder.
for file in "${FILES[@]}"
do
  ln -sfn $RELEASE/$file data/$file
done