# invasivesBC- Mussels



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
