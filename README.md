# invasivesBC- Mussels

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
