cd buildArchive
sudo cp -a ../options.plist .
sudo zip -r unsigned.zip options.plist App.xcarchive
