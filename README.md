# Inspect
[![img](https://img.shields.io/badge/Lifecycle-Maturing-007EC6)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

This application is for the field-based recording of watercraft inspections for Zebra and Quagga Mussels in British Columbia, Canada.&nbsp;

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

*Note: Always use `ipad.xcworkspace` to open this project.*

5. In [AppRemoteAPIConst](ipad/Constants/AppRemoteAPIConst.swift), change the enum in `RemoteURLManager` to `.local`
```swift
class RemoteURLManager {
    var env: RemoteEnv = .dev
    static var `default` = {
        // Here We Can use Target Flag to customize
        // Switch Env 
        return RemoteURLManager(.local) // <--- change from .prod to .local
                                        // change BACK to .prod when pushing to master
    }()
```

*Note: do not push this change to* `master` *or to the App Store; use* `.dev` *for local testing, and push only for testing on TestFlight - more on this [below](#setting-up-a-testflight-build-for-dev)*

You may need to also update the Signing & Capabilities to be able to run the application. More information in the [Provisioning Profile](#provisioning-profile-and-certificate) below as well.

## Building Locally

Any local changes to a [Realm](https://realm.io/realm-swift/) model will require you increment the ipad build - the `Error with db change listener` log appears in the Xcode terminal on app startup when this issue occurs).

```
> Listening to database changes in AutoSync.
> Error with db change listener
> [...]
```

You can increment the build in
    
**ipad > General > Identity.**

## Simulator

You can run the app through the Simulator from Xcode. Ensure that the Simulator is also running with Rosetta active - this can be done by going to:

**Product > Destination > Destination Architectures > Show Rosetta Destinations**

Ensure that you’re running the simulator on **iPad (10th generation) (Rosetta)**

## Roles

Anyone with an `IDIR` can log into the application, but only users with the following roles can create and submit entries.
- `inspectAppOfficer`
- `inspectAppAdmin`
- `admin`

Roles are requested through the Inspect team or the [Sustainment Team](mailto:sustainment.team@gov.bc.ca).

The Inspect and Sustainment team provision roles through the [Common Hosted Single Sign-on (CSS) Dashboard](https://bcgov.github.io/sso-requests/my-dashboard/integrations). To assign a user a role, go to the dashboard and follow these steps:
1) Login with your IDIR to the [CSS Dashboard](https://bcgov.github.io/sso-requests/my-dashboard/integrations).
2) Select **InspectBC Mussels**
3) In **INTEGRATION DETAILS**, select the **Assign Users to Roles** tab.
4) Under **Search for a user based on the selection criteria below**, select the realm for the user: **Dev**, **Test**, or **Prod**.

    *Note: a local build will use the **Dev** realm for roles.*

5) Search for user by **First Name**, **Last Name**, or **Email**. Select that user from the table.

    If you can't find a user with the search functionality above, there is a button to **Search in IDIM Web Service Lookup** to add the user. After adding the user with the download button, search for them again and they should appear in the table.

6) Under **Assign User to a Role**, select any of the roles listed above (e.g. `inspectAppOfficer`).

**[More information about creating roles in the CSS Dashboard can be found here.](https://mvp.developer.gov.bc.ca/docs/default/component/css-docs/Creating-a-Role/)**

# App Store Connect

You should be able to access [App Store Connect](https://appstoreconnect.apple.com/) using your BC Government email as the Apple ID login. If you're not already part of the Inspect group on App Store Connect, request an invite from [Sustainment Team](mailto:sustainment.team@gov.bc.ca). More information about adding users to App Store Connect can be found in [Apple's documentation here](https://developer.apple.com/help/account/manage-your-team/invite-team-members/).


## Building the App

All changes merged into the `master` branch will automatically create a new build in App Store Connect using [GitHub Actions](.github/workflows/main.yaml). This will also create a new build for testing in TestFlight. More information about [TestFlight below](#testflight-app).

### Build Version and Build Number

If planning on releasing a new version of the app, you <ins>will</ins> need to increment the **version** in Xcode under

**ipad > General > Identity > Build Number**

**as well as in the GitHub Action** in [`main.yaml`](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/.github/workflows/main.yaml). This is the `APP_BUILD_VERSION` env.

*Note: We use standard semantic versioning for the app in App Store Connect (`Major.Minor.Patch`)*

You <ins>will not</ins> need to increment the **build** number when pushing to `master` as that is done automatically through GitHub Actions with each push. Do not push your local build increments.  

## TestFlight and User Testing

### Adding Testers

Testers can be added in [App Store Connect](https://appstoreconnect.apple.com/) by navigating to

**Apps > Inspect > TestFlight > Internal Testing (App Store Connect Users)**

This dashboard will show you all the available builds on the current or newest version of the app, as well as any testers. You can select the "+" beside **Testers** to send an invite to new testers.

A user will receive an email saying **Government of British Columbia has invited you to test Inspect** and have a button that says *View in TestFlight*. This will allow the user to open the app in TestFlight.

If a user opens TestFlight and sees a "Redeem code" prompt, they might need to find that email and open the app in TestFlight again, or you may need to remove the user from the **Testers** group in App Store Connect and re-invite them.

### TestFlight App

Test users will be notified by email of any new builds in TestFlight, as any new pushes to the `master` branch will generate a build in TestFlight. This will allow your Test Users to test the new changes on a physical iPad.

Note that the Inspect app can only be tested on an iPad through the [TestFlight app on the App Store](https://apps.apple.com/ca/app/testflight/id899247664) as the Inspect app is for iPads only.

A new build in TestFlight will send an email with the subject like: *Inspect 2.7 (401) for iOS is now available to test* and will have a link to open the new version in the TestFlight app.

### Setting up a TestFlight Build for Dev

If, for some reason, you do not need users to test on a physical iPad (not recommended), then you can do all your testing locally and push your changes with the `RemoteUrlManager` set to `.prod`.

However, if you want Test Users to test the changes on the iPad in the **Dev** realm (so they can test saving data against the Dev backend), then you'll need to push changes to `master` with `RemoteUrlManager` set to `.dev`.

```swift
class RemoteURLManager {
    var env: RemoteEnv = .dev
    static var `default` = {
        // Here We Can use Target Flag to customize
        // Switch Env 
        return RemoteURLManager(.dev) // <--- change to .dev for testing
                                      // change BACK to .prod afterwards
    }()
```

Please ensure that if you're pushing builds with a `.dev` extension to TestFlight, you explicitly mention them in the PR. This is to avoid mistakenly deploying these changes to the App Store when the application is configured to use the **Dev** realm. 

Therefore, once users have completed and approved the changes from the `.dev` build in TestFlight, you will need to make *another** PR against `master` where `RemoteUrlManager` has been set *back* to `.prod`. This can be tested again by Testers if you like, but this will be the production database so no data should be saved. This version and build can be added for review to be published to the App Store.

## Deploying the App

Once you've fully tested the app on TestFlight, you are now ready to deploy the app to the App Store.

1. **Make sure the app is set to look at** `.prod`**!**
2. Login to [App Store Connect](https://appstoreconnect.apple.com/) and select **My Apps** and choose **Inspect**. 
3. Navigate to the **App Store** tab. 
4. Select the "**+**" button beside iOS App to increment the next version of the app.
5. Type the next version number and Select **Create**. 
6. Update the **What’s New in This Version** text box with the changes outlined in the PR(s).
7. Scroll to **Build** and select the "**+**" button.
8. Choose the build you want to add and select **Next**. It should show the newly added build. 
9. Scroll to the App Review Information section.
    
    Because there’s not an IDIR for the Apple Testing team to use to review the app, we record a screen capture of the app (clicking all buttons, scrolling through the app, etc.) for the current version. We then attach the video for Apple to review, or upload it to [Google Drive](https://drive.google.com/drive/home) and share the link in the App Review Information section. You'll need to provide a short explanation of the recording.
    
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

 
10. Scroll to **Version Release** and select **Manually release this version** if you want to release the version at your own discretion after the app is approved, otherwise you can select to **Automatically release the version as soon as it is approved by the Apple Review team**. 
11. Select **Add for Review**.
12. Once that’s added for review, you then need to select **Submit to App Review** to send the version to the App Store review team.
 
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
- change the placement of the fields by changing the order in which the fields are created or by changing the function (section) that the fields are included in.
- change the type of field that's displayed by changing a single line of code.
- change the width size of each field by changing the width value.


This framework also allows you to change the look of all fields of a certain type, for example text fields, by changing a single `.xib` file.&nbsp;

[There are many time-saving advantages to using this framework in an agile environment and you can find more details about this framework here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form)
