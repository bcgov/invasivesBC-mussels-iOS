# Inspect

This application is for the field-based recording of watercraft inspections for Zebra and Quagga Mussels in British Columbia, Canada.&nbsp;

Anyone with a `BCeID` or `idir` can log into the application, but only users with the following roles can create and submit entries.
- `Officer Mussel Inspect App`
- `Admin Mussel Inspect App`
- `Admin`

To grant access to the inspect application:
1) Go to the [invasivesBC](https://invasivesbc.pathfinder.gov.bc.ca/admin) web app and log-in as `Admin Mussel Inspect App` or `Admin`.
2) Ope the Admin tab.
3) Find the user that you want to give access to and give them the `Officer Mussel Inspect App` role.

# Setup Instructions

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

You may need to update the Signing & Capabilities to be able to run the application
1) Open the `Project Navigator`
2) Click the top most icon `ipad`
3) Select 'iPad' under `Targets`
3) Select the `Signing & Capabilities` tab
4) Here you may need to sign-in or select the appropriate team.

## Tests
The application's tests are [in this folder.](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipadTests)
To run all tests, 
1) Open the project in Xcode ( `ipad.xcworkspace` ) 
2) Click `Product` -> `Test` from Xcode's top menu.

You can run individual tests by selecting the `Show the test navigator` tab on the left menu bar of Xcode. 

# [Forms](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form)
The forms in the app are created with the help of a framework created for this application called [`InputGroupView`](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form) which allows us to create and edit the forms quickly and directly from the code.&nbsp;

- Fields for the Watercraft Inspection form are defined [here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Models/Waterfract%20Inspection/Form%20Fields).
- Fields for the shift form are defined [here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Models/Shift/Form%20Fields).

These files have functions that return the fields for each section of the forms. here you can:
- change the placement of the fields by changing the order in which the fields are creared or by changing the function (section) that the fields are included in.
- change the type of field that's displayed by changing a single line of code.
- change the width size of each field by changing the width value.

This framework also allows you to change the look of all fields of a centain type, for example text fields, by changing a single xib file.&nbsp;

[There are a lot of time saving advantages to using this framework in an agile enviorment and you can find more details about this framework here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form)

# Deploy

The Pipeline for this application was created by [Jason](https://github.com/jleach) using [Azure](https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/xcode?view=azure-devops).
This pipeline allows developers to sign and deploy the application to [App Store Connect](https://appstoreconnect.apple.com/login) without having the elevated permission on the BC Government Apple account.
Alternatively, you could sign the compiled IPA using [this mobile signing tool](https://signing-web-devhub-prod.pathfinder.gov.bc.ca/?intention=LOGIN#error=login_required), and upload through xcode.

### Using the Pipeline
You can upload your builds to `App Store Connect` through the pipeline by merging a pull request from `master`, by following the steps below.
Note: `Build` number will be handled by the pipeline, but you need to update the `version` yourself after each app store release.
 1) Create a pull request to `master` to trigger a build on the pipeline.
 2) Check the status of the build [here](https://fullboar.visualstudio.com/Invasive%20Species%20BC/_build?definitionId=10&_a=summary).
 3) When the build is successful, merge your pull request.
 
 This will trigger another build [here](https://fullboar.visualstudio.com/Invasive%20Species%20BC/_build?definitionId=10&_a=summary), but this time it will also uplod the build to [App Store Connect](https://appstoreconnect.apple.com/login).
 Then you can [login into App store Connect](https://appstoreconnect.apple.com/login) and deploy a testflight build or create an App Store submission. 
