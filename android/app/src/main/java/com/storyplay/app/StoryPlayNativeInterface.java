package com.storyplay.app;

import android.app.Activity;
import android.webkit.JavascriptInterface;

/** Plain WebView JS bridge so the app page can ask native code to install an update. */
public class StoryPlayNativeInterface {
    private final Activity activity;

    public StoryPlayNativeInterface(Activity activity) {
        this.activity = activity;
    }

    @JavascriptInterface
    public void installApk(String url) {
        install(url);
    }

    @JavascriptInterface
    public void installUpdate(String url) {
        install(url);
    }

    @JavascriptInterface
    public void install(String url) {
        if (url == null || url.isEmpty()) return;
        ApkInstaller.downloadAndInstall(activity, url);
    }

    @JavascriptInterface
    public void update(String url) {
        install(url);
    }
}
