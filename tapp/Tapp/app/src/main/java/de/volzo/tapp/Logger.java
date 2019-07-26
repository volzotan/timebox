package de.volzo.tapp;

import android.os.Environment;
import android.util.Log;

import java.io.*;

public class Logger {
    public static File getFile() {
        return new File(Environment.getExternalStorageDirectory(), "TAPP/LOG.TXT");
    }

    protected static void log(String msg) {
        try {
            getFile().getParentFile().mkdirs();
            BufferedWriter writer = new BufferedWriter(new FileWriter(getFile(), true));
            writer.append(msg);
            writer.newLine();
            writer.close();
        } catch (IOException e) {}
    }
    protected static void log(String type, String msg) { log("[" + type + "] " + msg); }

    public static void info(String msg) {
        log("INFO", msg);
        Log.i("GENERIC", msg);
    }

    public static void error(String msg) {
        log("ERROR", msg);
        Log.e("GENERIC", msg);
    }
}