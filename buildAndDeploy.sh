#!/bin/sh

xcodebuild -allowProvisioningUpdates -workspace ipad.xcworkspace -scheme ipad -configuration Release clean archive -archivePath buildArchive/App.xcarchive
xcodebuild -exportArchive -archivePath ./buildArchive/App.xcarchive -exportOptionsPlist exportOptions.plist -exportPath ./build -allowProvisioningUpdates
xcrun altool --upload-app -f build/Inspect.ipa --type ios -u $APP_STORE_USERNAME -p $APP_SPECIFIC_PASSWORD
