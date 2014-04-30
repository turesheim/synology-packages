#!/bin/bash

# Download the Apache Archiva bundle if it is not already present
if [ ! -f apache-archiva-2.0.1-bin.tar.gz ]; then
	curl -O http://apache.uib.no/archiva/2.0.1/binaries/apache-archiva-2.0.1-bin.tar.gz
fi

# Clean up from last round
rm -rf src
rm -f Archiva-x64-*-bin.spk
rm -f package.tgz

# Prepare to modify the Archive distribution
tar -xzf apache-archiva-2.0.1-bin.tar.gz

# Change the folder name to something more useful when called from the scripts
mv apache-archiva-2.0.1 src

# Remove working folders, we'll move and recreate them
rmdir src/logs
rmdir src/temp

# Install a suitable wrapper binary
cp wrapper-Lix-ow-32 src/bin/

# Create a token for the installer to handle
sed -e 's/wrapper.java.command=java/wrapper.java.command=__JAVA_COMMAND__/g' \
    -i .original ./src/conf/wrapper.conf

# Create the package.tgz
COPYFILE_DISABLE=1 tar -cpzf package.tgz src scripts ui

# Assign a build number
if [ -f ./build.number ]; then
	buildNumber=$(<build.number)
else
	buildNumber=1
fi
buildNumber=$[$buildNumber+1]

# Write the version number
version=2.0.1-$buildNumber
sed 's/VERSION/'$version'/g' INFO.template > INFO

# Create the Synology package
COPYFILE_DISABLE=1 tar -cpzf Archiva-x64-2.0.1-$buildNumber-bin.spk scripts WIZARD_UIFILES INFO package.tgz

#Bump the build number
if [ "$?" -eq "0" ]; then
	echo $buildNumber > ./build.number
fi
