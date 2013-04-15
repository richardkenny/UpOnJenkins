#!/bin/sh
# Ensure the SDK is in the Jenkins user's system path
PATH=/usr/local/bin/ant/bin:$PATH

##############################################
#This is all just logging information, doesn't execute anything
##############################################
#echo build number
echo $BUILD_NUMBER

# Create a date/version log file
echo BUILD-DATE\: > HudsonBuildData.html
date >> HudsonBuildData.html
echo "
" >> HudsonBuildData.html
echo BUILD-TAG\: $BUILD_TAG >> HudsonBuildData.html
echo "
" >> HudsonBuildData.html
echo BUILD-ID\: $BUILD_ID >> HudsonBuildData.html
echo "
" >> HudsonBuildData.html

# Create a JSON version of the Build Data
echo "{" > HudsonBuildData.json
echo \"build_date\"\:\"$(date)\", >> HudsonBuildData.json
echo \"build_tag\"\:\"$BUILD_TAG\",>> HudsonBuildData.json
echo \"build_id\"\:\"$BUILD_ID\" >> HudsonBuildData.json
echo "}" >> HudsonBuildData.json

cp HudsonBuildData.json UpOnJenkins/HudsonBuildData.json 
cp HudsonBuildData.html UpOnJenkins/HudsonBuildData.html
cp HudsonBuildData.html UpOnJenkins/HudsonBuildData.html
##############################################


# Change to the Jenkins workspace directory for ProjectName
cd UpOnJenkins
# Set the app version to be the build number
sed -e 's/android:versionCode="1" android:versionName="1.0"/android:versionCode="'${BUILD_NUMBER}'" android:versionName="'${BUILD_NUMBER}'"/g' AndroidManifest.xml > manifest.tmp && mv manifest.tmp AndroidManifest.xml

#What does this do?
/android-sdk-macosx/tools/android --verbose update project --path .


# clean the target
ant clean

# Execute the build (debug or release... as a jenkins parameter
ant ${ENVIRONMENT}


# Go back a directory
cd ..
ls UpOnJenkins/bin
#
#mv UpOnJenkins/bin/UpOnJenkins-${ENVIRONMENT}.apk UpOnJenkins.apk
#mv UpOnJenkins/bin/MainActivity-release-unsigned.apk UpOnJenkins.apk

##############################################
#Add to build the test project
##############################################
# Change to the Jenkins workspace directory for ProjectNameTests
#cd TestDirectoryName 
#/android-sdk-macosx/tools/android update test-project -m ../ProjectName -p ./
#ant clean

# Execute the build
#ant ${ENVIRONMENT}

# Go back a directory
#cd .. 
##############################################

if [ "$ENVIRONMENT" == "debug" ]; then
# Load the ProjectName apk
/android-sdk-macosx/platform-tools/adb install -r ProjectName/bin/ProjectName-debug.apk
# Load the JenkinsTest Robotium Test Application apk
#/android-sdk-macosx/platform-tools/adb install -r ProjectNameTests/bin/ProjectNameTests-debug.apk
fi

if [ "$ENVIRONMENT" == "release" ]; then
# Load the UpOnJenkins apk
/android-sdk-macosx/platform-tools/adb install -r ProjectName/bin/MainActivity-release-unsigned.apk
# load the Visit Tracking Robotium Test Application apk
#/android-sdk-macosx/platform-tools/adb install -r ProjectNameTests/bin/ProjectNameTests-release-unsigned.apk
fi

# display devices
/android-sdk-macosx/platform-tools/adb devices 

# execute the test
#/android-sdk-macosx/platform-tools/adb shell am instrument -w com.compuware.projectname.test/com.zutubi.android.junitreport.JUnitReportTestRunner
#/android-sdk-macosx/platform-tools/adb pull /data/data/com.compuware.projectname/files/junit-report.xml $WORKSPACE/ProjectNameTests/reports/junit-report.xml 

# kill the emulator - this doesn't work on windows
#/android-sdk-macosx/platform-tools/adb -s emulator-5554 emu kill

## repeat for additional emulators