package de.volzo.tapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;

public class BootCompletedReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Logger.info("Boot completed");

//        Intent startIntent = new Intent(context, MainActivity.class);
//        startIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//        context.startActivity(startIntent);

        PackageManager pm = context.getPackageManager();
        Intent startIntent = pm.getLaunchIntentForPackage(context.getPackageName());
        context.startActivity(startIntent);
    }
}