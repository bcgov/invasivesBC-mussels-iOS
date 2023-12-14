# Inspect
[![img](https://img.shields.io/badge/Lifecycle-Maturing-007EC6)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

This application is for the field-based recording of watercraft inspections for Zebra and Quagga Mussels in British Columbia, Canada.&nbsp;

Anyone with a `BCeID` or `idir` can log into the application, but only users with the following roles can create and submit entries.
- `Officer Mussel Inspect App`
- `Admin Mussel Inspect App`
- `Admin`

To grant access to the inspect application:
1) Go to the [invasivesBC](https://invasivesbc.pathfinder.gov.bc.ca/admin) web app and log-in as `Admin Mussel Inspect App` or `Admin`.
2) Open the Admin tab.
3) Find the user that you want to give access to and give them the `Officer Mussel Inspect App` role.

# Setup

Before you begin, install [Cocoapods](https://cocoapods.org) on your machine if you don't have it yet.
```
sudo gem install cocoapods
```
Once you have installed the dependency manager, follow the setup instructions below. 

1) Clone [this](https://github.com/bcgov/invasivesBC-mussels-iOS) repo:
```
git clone https://github.com/bcgov/invasivesBC-mussels-iOS
```
2) Navigate to project folder:
```
cd invasivesBC-mussels-iOS
```
3)  Install Pods/Dependencies:
```
pod install
```
4) Open `ipad.xcworkspace` to open the project in Xcode.
```
open ipad.xcworkspace
```

*Note: Always use `ipad.xcworkspace` to open this project.

You may need to update the Signing & Capabilities to be able to run the application. More information in the [Provisioning Profile](#provisioning-profile-and-certificate) below.

## Simulator

You can run the app through the Simulator from Xcode. Ensure that the Simulator is also running with Rosetta active - this can be done by going to:

*Product* > *Destination* > *Destination Architectures* > *Show Rosetta Destinations*

Ensure that you’re running the simulator on **iPad (10th generation) (Rosetta)**

## Test
The application's tests are [in this folder.](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipadTests)
To run all tests, 
1) Open the project in Xcode ( `ipad.xcworkspace` ) 
2) Click `Product` -> `Test` from Xcode's top menu.

You can run individual tests by selecting the `Show the test navigator` tab on the left menu bar of Xcode.

*Note: You'll need to setup the environment variables under Schemes (Product -> Scheme -> Edit Scheme) and provide the values for TestIDIR and TestPassword. You can find the values in Openshift Secrets for dev.

# App Store Connect

You should be able to access [App Store Connect](https://appstoreconnect.apple.com/) using your BCGov email as the Apple ID login. If you're not already part of the INSPECT app on App Store Connect, request an invite from a team member using [Apple's instructions here](https://developer.apple.com/help/account/manage-your-team/invite-team-members/).


## Building the App

All changes merged into the `master` branch will create a new build in App Store Connect using GitHub Actions. This will also create a new build for testing in TestFlight.


### Build Version and Build Number

**You will** need to increment the Version in Xcode under *ipad* > *General* > *Identity* > *Build Number* **as well as in the GitHub Action** in [`main.yaml`](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/.github/workflows/main.yaml) as the `APP_BUILD_VERSION` env.

However, you **will not** need to increment the build number as that's done automaticall through GitHub Actions.

We use standard semantic versioning for the app in App Store Connect (`Major.Minor.Patch`) 


## Deploying the App

Once you've fully tested the app on TestFlight, you are now ready to deploy the app to the App Store.

1. Login to [App Store Connect](https://appstoreconnect.apple.com/) and select **My Apps** and choose **Inspect**. 
2. Navigate to the **App Store** tab. 
3. Select the "**+**" button beside iOS App to increment the next version of the app.
4. Type the next version number and Select **Create**. 
5. Update the **What’s New in This Version** text box with the changes outlined in the PR.
6. Scroll to **Build** and select the "**+**" button.
7. Choose the build you want to add and select **Next**. It should show the newly added build. 
8. Scroll to the App Review Information section.
    
    Because there’s not an IDIR for the Apple Testing team to use to review the app, we record a screen capture of the app (clicking all buttons, scrolling through the app, etc.) for the current version. We then upload it to [Google Drive](https://drive.google.com/drive/home) and share the link in the App Review Information section, or attach the video for Apple to review. You'll need to provide a short explanation of the recording.
    
    Feel free to use the template below:

    ```
    Here are a few notes of the screen recording: 
    - The videos are screen recordings of an iOS device (iPad Pro 12.9-inch 6th generation) running the app. 
    - The screen recordings were captured using xCode's Simulator's screen recording. 
    - The app was running locally using a local database. 
    - I attempted to interact with every button and form field that was available to the user beyond the login screen (the login was completed automatically as I has signed in earlier) 

    General notes: 
    - The application is to be used by research scientists, BC Government Conservation officers and external partners and sister agencies. 
    - This app uses a government identification system to authenticate users.  
    ```
    
    You can record your screen in the xCode Simulator through **File** > **Record Screen**

 
9. Scroll to **Version Release** and select **Manually release this version** if you want to release the version at your own discretion after the app is approved, otherwise you can select to **Automatically release the version as soon as it is approved by the Apple Review team**. 
10. Select **Add for Review**.
11. Once that’s added for review, you then need to select **Submit to App Review** to send the version to the App Store review team.
 
Once it’s successfully submitted, you should be given a confirmation screen with a Submission ID. On average, submitted app reviews should only take a few hours before being approved, although Apple indicates it can take up to 24 hours for a response.


## Provisioning Profile and Certificate

GitHub Actions will sign the app using BCGov's provisioning profile, which is issued from the **Developer Experience** team. A provisioning profile expires after about one year, so you may need to request a new provisioning profile. The file will have a `.mobileprovision` extension.

#### Add Provisioning Profile to Xcode

Once you receive the provisioning profile, you can drag-and-drop it to Xcode, where it will then appear under *ipad* > *Signing & Capabilities* > *iOS* > *Provisioning Profile***. Select the new Provisioning Profile in Xcode.

***Note: the `Status` in Xcode may show "no signing certificate", and that's because the Certificate is supplied by the BCGov Organization in the repo's [GitHub Actions secrets and variables](https://github.com/bcgov/invasivesBC-mussels-iOS/settings/secrets/actions).*

#### Add Provisioning Profile to the Repo's Secrets and Variables

Next, you will need to convert the provisioning profile file to Base64 and copy it to the repo's [GitHub Actions secrets and variables](https://github.com/bcgov/invasivesBC-mussels-iOS/settings/secrets/actions) as `IOS_PROVISION_PROFILE_BASE64`. Use the following command to convert the file to Base64 and copy it to your clipboard:

    base64 -i File_Name_Here.mobileprovision | pbcopy

Replace the `IOS_PROVISION_PROFILE_BASE64` secret.

#### Provisioning Profile in `.plist` files

You'll also need to update the strings for the provisioning **name** and **UUID** in the [`options.plist`](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/options.plist) and [`exportOptions.plist`](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/exportOptions.plist) files. You can print out the **Name** and **UUID** through the following command:

    security cms -D -i File_Name_Here.mobileprovision

And replace the values in the `.plist` files.

`options.plist`:
```plist
    <dict>
        <key>ca.bc.gov.InvasivesBC</key>
        <string>bb2b59b7-03d0-4b86-8d8a-c1b827bf923f</string>  <!-- update UUID here -->
    </dict>
```
`exportOptions.plist`:
```plist exportOptions.plist
    <dict>
        <key>ca.bc.gov.InvasivesBC</key>
        <string>InvasivesBC Muscles - 2023/24</string> <!-- update name here -->
    </dict>
```


(The provisioning **name** should be what appears in Xcode under *ipad* > *Signing & Capabilities* > *iOS* > *Provisioning Profile*.)

[**The Developer Experience team has more information on GitHub Actions and deploying to App Store Connect here**](https://mvp.developer.gov.bc.ca/docs/default/component/mobile-developer-guide/apple_app_signing/).


# Workflows

- Login ![Login](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/Workflow-login.jpg)
- Home ![Home](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/Workflow-home.jpg)
- Shift ![Shift](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/workflow-shift.jpeg)
- Inspection ![Inspection](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/Workflow-inspection.jpg)

# [Forms](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form)
The forms in the app are created with the help of a framework created for this application called [`InputGroupView`](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form) which allows us to create and edit the forms quickly and directly from the code.&nbsp;

- Fields for the Watercraft Inspection form are defined [here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Models/Waterfract%20Inspection/Form%20Fields).
- Fields for the shift form are defined [here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Models/Shift/Form%20Fields).

These files have functions that return the fields for each section of the forms. here you can:
- change the placement of the fields by changing the order in which the fields are creared or by changing the function (section) that the fields are included in.
- change the type of field that's displayed by changing a single line of code.
- change the width size of each field by changing the width value.


This framework also allows you to change the look of all fields of a centain type, for example text fields, by changing a single xib file.&nbsp;

[There are many time saving advantages to using this framework in an agile enviorment and you can find more details about this framework here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form)
