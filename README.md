# React Native : AWS Cognito Module 

**Work in progress!**

`react-native-cognito` provides a [React Native](http://facebook.github.io/react-native/) module for integrating with [AWS Cognito](https://aws.amazon.com/cognito/).

**Features currently supported:**

* [x] dataset:synchronize

**Roadmap:**

* [ ] dataset:subscribe
* [ ] dataset:unsubscrib
* [ ] proper callbacks + events
* [ ] promises
* [ ] twitter auth support
* [ ] google auth support
* [ ] custom login support

## Supported Identity Providers

Currently the following identity providers are supported:

- Facebook

In development:

- Twitter
- Google

## Requirements

`react-native-cognito` does not handle authentication with identity providers such as Facebook. You have to use [react-native-facebook-login](https://github.com/magus/react-native-facebook-login) or similar to get a valid access token to use with `react-native-cognito`.

### AWS Mobile SDK

Make sure you install the AWS Mobile SDK. [https://aws.amazon.com/mobile/sdk/](http://docs.aws.amazon.com/mobile/sdkforios/developerguide/setup.html).

## Example Usage

```es6
import React from 'react-native';
import Cognito from 'react-native-cognito';
import LoginStore from '../stores/LoginStore';

let region = 'eu-west-1';
let identityPoolId = 'your_cognito_identity_pool_id';

class Demo extends React.Component {
    constructor() {
        // Load login credentials from flux store.
        this.state = LoginStore.getState();

        // Provide credentials to Cognito.
        Cognito.initCredentialsProvider(
            identityPoolId,
            this.state.credentials.token, // <- Facebook access token
            region);

        // Sync data
        Cognito.syncData('testDataset', 'hello', 'world', (err) => {
            // callback
            // handle errors etc
        });
    }
}
```

## Install -- iOS

First, install via npm:

```
$ npm install --save react-native-cognito
```

Add RCTCognito.xcodeproj to Libraries and add libRCTCognito.a to Link Binary With Libraries under Build Phases. More info and screenshots about how to do this is available in the [React Native documentation](https://facebook.github.io/react-native/docs/linking-libraries-ios.html#content).

**Next, select RCTCognito.xcodeproj and add your AWS SDK path to Framework Search Paths under Build Settings.**

## Install -- Android

*Disclaimer: experimental i.e., don't use*

### Step 1 - Gradle Settings

Edit `android/settings.gradle` and add the following lines:

```
...
include ':react-native-cognito'
project(':react-native-cognito').projectDir = new File(rootProject.projectDir, '../node-modules/react-native-cognito/android')
```

### Step 2 - Gradle Build

Edit `android/app/build.gradle`:

```
...
dependencies {
    ...
    compile project(':react-native-cognito')
}
```

### Step 3 - Register Package

Edit `android/app/src/main/java/com/myApp/MainActivity.java`.

```java
// Import package
import com.morcmarc.rctcognito.ReactCognitoPackage;

...

public class MainActivity extends Activity implements DefaultHardwareBackBtnHandler {
    ...
    
    // declare package
    private ReactCognitoPackage mReactCognitoPackage;

    ...
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mReactRootView = new ReactRootView(this);
        ...
        // Instantiate package
        mReactCognitoPackage = new ReactCognitoPackage(this);
        ...
        mReactInstanceManager = ReactInstanceManager.builder()
                .setApplication(getApplication())
                .setBundleAssetName("index.android.bundle")
                .setJSMainModuleName("index.android")

                // Register the package
                .addPackage(mReactCognitoPackage)

                .setUseDeveloperSupport(BuildConfig.DEBUG)
                .setInitialLifecycleState(LifecycleState.RESUMED)
                .build();
        ...
    }
}
```

### Step 4 - Permissions

You might have to add the following permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```
