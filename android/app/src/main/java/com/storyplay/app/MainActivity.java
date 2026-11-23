package com.storyplay.app;

import android.os.Bundle;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        registerPlugin(StoryPlayUpdater.class);
        StoryPlayNativeInterface nativeInterface = new StoryPlayNativeInterface(this);
        getBridge().getWebView().addJavascriptInterface(nativeInterface, "StoryPlayNative");
        getBridge().getWebView().addJavascriptInterface(nativeInterface, "AndroidBridge");
        getBridge().getWebView().addJavascriptInterface(nativeInterface, "AndroidUpdater");
    }
}
