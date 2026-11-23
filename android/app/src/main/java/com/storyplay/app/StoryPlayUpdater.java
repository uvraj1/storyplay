package com.storyplay.app;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/** Capacitor plugin so the app page can ask native code to install an update. */
@CapacitorPlugin(name = "StoryPlayUpdater")
public class StoryPlayUpdater extends Plugin {
    @PluginMethod
    public void installUpdate(PluginCall call) {
        install(call);
    }

    @PluginMethod
    public void installApk(PluginCall call) {
        install(call);
    }

    @PluginMethod
    public void install(PluginCall call) {
        String url = call.getString("url");
        if (url == null) url = call.getString("apkUrl");
        if (url == null) url = call.getString("apk_url");
        if (url == null || url.isEmpty()) {
            call.reject("Missing apk url");
            return;
        }
        ApkInstaller.downloadAndInstall(getActivity(), url);
        JSObject ret = new JSObject();
        ret.put("started", true);
        call.resolve(ret);
    }
}
