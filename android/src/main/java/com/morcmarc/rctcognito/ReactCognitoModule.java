package com.morcmarc.rctcognito;

import android.content.Context;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import com.amazonaws.auth.CognitoCachingCredentialsProvider;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.regions.RegionUtils;
import com.amazonaws.mobileconnectors.cognito.CognitoSyncManager;
import com.amazonaws.mobileconnectors.cognito.Dataset;
import com.amazonaws.mobileconnectors.cognito.DefaultSyncCallback;

public class ReactCognitoModule extends ReactContextBaseJavaModule
{
    private Context mActivityContext;
    private CognitoCachingCredentialsProvider cognitoCredentialsProvider;
    private CognitoSyncManager cognitoClient;

    public ReactCognitoModule(ReactApplicationContext reactContext, Context activityContext)
    {
        super(reactContext);
        mActivityContext = activityContext;
    }

    @Override
    public String getName()
    {
        return "ReactCognito";
    }

    @ReactMethod
    public void initCredentialsProvider(String identityPoolId, String token, String region)
    {
        RegionUtils regionUtils = new RegionUtils();
        Region awsRegion = regionUtils.getRegion(region);
        
        cognitoCredentialsProvider = new CognitoCachingCredentialsProvider(
            mActivityContext.getApplicationContext(),
            identityPoolId,
            // awsRegion);
            Regions.EU_WEST_1);

        cognitoClient = new CognitoSyncManager(
            mActivityContext.getApplicationContext(),
            // awsRegion,
            Regions.EU_WEST_1,
            cognitoCredentialsProvider);
    }

    @ReactMethod
    public void syncData(String datasetName, String key, String value)
    {
        Dataset dataset = cognitoClient.openOrCreateDataset(datasetName);
        dataset.put(key, value);
        dataset.synchronize(new DefaultSyncCallback());
    }
}