package com.storyplay.app;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import androidx.core.content.FileProvider;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

/** Downloads an APK (native HTTP, no WebView CORS limits) and opens the Android installer. */
public class ApkInstaller {
    public static void downloadAndInstall(final Activity activity, final String apkUrl) {
        new Thread(new Runnable() {
            @Override public void run() {
                try {
                    File outFile = new File(activity.getExternalFilesDir(null), "storyplay-update.apk");
                    URL url = new URL(apkUrl);
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setConnectTimeout(30000);
                    conn.setReadTimeout(60000);
                    conn.setInstanceFollowRedirects(true);
                    conn.connect();
                    InputStream in = conn.getInputStream();
                    FileOutputStream out = new FileOutputStream(outFile);
                    byte[] buf = new byte[8192];
                    int n;
                    while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
                    out.flush();
                    out.close();
                    in.close();
                    conn.disconnect();
                    final File apk = outFile;
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override public void run() { launchInstaller(activity, apk); }
                    });
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    public static void launchInstaller(Activity activity, File apkFile) {
        try {
            Uri uri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".fileprovider", apkFile);
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(uri, "application/vnd.android.package-archive");
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_GRANT_READ_URI_PERMISSION);
            activity.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
