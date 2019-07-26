package de.volzo.tapp;

import android.hardware.Camera;

import com.sony.scalar.hardware.CameraEx;

public class CameraController implements
        Camera.AutoFocusCallback,
        Camera.ShutterCallback,
        Camera.PictureCallback {

    private CameraEx camera;

    public CameraController() {
        Logger.info("CameraController init");
    }

    public void openCamera() {
        camera = CameraEx.open(0, null);
        Logger.info("camera opened");

//        camera.setErrorCallback(this);
        // camera.setCaptureStatusListener(this);
    }

    public void focus() {
        camera.getNormalCamera().autoFocus(this);
        Logger.info("AF start");
    }

    @Override
    public void onAutoFocus(boolean b, Camera camera) {
        Logger.info("AF callback");
    }

    public void trigger() {
        camera.getNormalCamera().takePicture(this, this, this);
    }

    @Override
    public void onShutter() {
        Logger.info("shutter callback");
    }

    @Override
    public void onPictureTaken(byte[] bytes, Camera camera) {
        Logger.info("picture callback");
    }

    public void closeCamera() {
        camera.release();
        camera = null;

        Logger.info("close done");
    }

    // ---------------------------------------- Listener -------------------------------------------

//    @Override
//    public void onEnd(int i, int i1, CameraEx cameraEx) {
//        Logger.info("OnCaptureStatusListener onEnd");
//    }
//
//    @Override
//    public void onStart(int i, CameraEx cameraEx) {
//        Logger.info("OnCaptureStatusListener onStart");
//
//    }
}

