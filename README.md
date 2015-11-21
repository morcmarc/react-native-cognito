# React Native : AWS Cognito Module 

**Work in progress!**

`react-native-cognito` provides a [React Native](http://facebook.github.io/react-native/) module for integrating with [AWS Cognito](https://aws.amazon.com/cognito/).

## Supported Identity Providers

Currently the following identity providers are supported:

- Facebook

In development:

- Twitter
- Google

## Requirements

`react-native-cognito` does not handle authentication with identity providers such as Facebook. You have to use [react-native-facebook-login](https://github.com/magus/react-native-facebook-login) or similar to get a valid access token to use with `react-native-cognito`.

## Install -- iOS

First, install via npm:

```
$ npm install --save react-native-cognito
```

Add RCTCognito.xcodeproj to Libraries and add libRCTCognito.a to Link Binary With Libraries under Build Phases. More info and screenshots about how to do this is available in the [React Native documentation](https://facebook.github.io/react-native/docs/linking-libraries-ios.html#content).

## Install -- Android

Coming soon...

## Usage

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

        // Sync some data up to the cloud.
        Cognito.syncData('testDataset', 'hello', 'world');
    }
}
```
