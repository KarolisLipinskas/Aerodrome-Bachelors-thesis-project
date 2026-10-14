package com.example.barcodescanner;

import android.Manifest;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import android.util.Log;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AlertDialog;
import androidx.camera.core.*;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.barcode.*;
import com.google.mlkit.vision.barcode.common.Barcode;
import com.google.mlkit.vision.common.InputImage;

import org.json.JSONObject;
import org.json.JSONArray;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;

public class ScannerActivity extends AppCompatActivity {
    private static final int CAMERA_REQUEST_CODE = 1001;
    private PreviewView previewView;
    private TextView barcodeInfo;
    private Button confirmButton, cancelButton;
    private String scannedValue = "";
    String boardingNo;
    String etag;
    SharedPreferences prefs;
    String ConnectionIP;
    String ServerInstance;

    private ExecutorService cameraExecutor;
    private boolean hasScanned = false;

    @androidx.camera.core.ExperimentalGetImage
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scanner);

        previewView = findViewById(R.id.previewView);
        barcodeInfo = findViewById(R.id.barcode_info);
        confirmButton = findViewById(R.id.button_confirm);
        cancelButton = findViewById(R.id.button_cancel);

        cameraExecutor = Executors.newSingleThreadExecutor();

        confirmButton.setEnabled(false);   // CHANGE to true for testing

        prefs = getSharedPreferences("AppSettings", MODE_PRIVATE);
        ConnectionIP = prefs.getString("ip", "");
        ServerInstance = prefs.getString("instance", "NAV_2500CU0_W1");

        confirmButton.setOnClickListener(v -> {
            ExecutorService executor = Executors.newSingleThreadExecutor();
            Handler handler = new Handler(Looper.getMainLooper());
            executor.execute(() -> {
                boolean success =
                        sendRequest("GET", scannedValue, "") &&
                    sendRequest("PATCH", scannedValue, "Is_API_Call") &&
                    sendRequest("GET", scannedValue, "") &&
                    sendRequest("PATCH", scannedValue, "Is_Present");
                handler.post(() -> {
                    showResult(success ? "successful" : "failed");
                });
            });
        });

        cancelButton.setOnClickListener(v -> finish());

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED) {
            startCamera();
        } else {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.CAMERA},
                    CAMERA_REQUEST_CODE);
        }
    }

    @androidx.camera.core.ExperimentalGetImage
    private void startCamera() {
        ListenableFuture<ProcessCameraProvider> cameraProviderFuture =
                ProcessCameraProvider.getInstance(this);

        cameraProviderFuture.addListener(() -> {
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();

                Preview preview = new Preview.Builder().build();
                preview.setSurfaceProvider(previewView.getSurfaceProvider());

                Log.d("CameraX", "Preview surface provider set to PreviewView");

                ImageAnalysis imageAnalysis =
                        new ImageAnalysis.Builder()
                                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                .build();

                imageAnalysis.setAnalyzer(cameraExecutor, imageProxy -> {
                    scanBarcodes(imageProxy);
                });

                CameraSelector cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA;

                cameraProvider.unbindAll();
                cameraProvider.bindToLifecycle(this, cameraSelector, preview, imageAnalysis);

                Log.d("CameraX", "Camera provider bound successfully");

            } catch (ExecutionException | InterruptedException e) {
                Log.e("CameraX", "Error initializing CameraX", e);
            }
        }, ContextCompat.getMainExecutor(this));
    }

    @androidx.camera.core.ExperimentalGetImage
    private void scanBarcodes(ImageProxy imageProxy) {
        @androidx.camera.core.ExperimentalGetImage
        ImageProxy.PlaneProxy[] planes = imageProxy.getPlanes();
        if (imageProxy.getImage() != null && !hasScanned) {
            InputImage image =
                    InputImage.fromMediaImage(imageProxy.getImage(), imageProxy.getImageInfo().getRotationDegrees());

            //BarcodeScanner scanner = BarcodeScanning.getClient();

            BarcodeScannerOptions options =
                    new BarcodeScannerOptions.Builder()
                            .setBarcodeFormats(Barcode.FORMAT_CODE_128)
                            .build();

            BarcodeScanner scanner = BarcodeScanning.getClient(options);

            scanner.process(image)
                    .addOnSuccessListener(barcodes -> {
                        if (!barcodes.isEmpty()) {
                            Barcode barcode = barcodes.get(0);
                            scannedValue = barcode.getRawValue();
                            hasScanned = true;
                            runOnUiThread(() -> {
                                barcodeInfo.setText(scannedValue);
                                confirmButton.setEnabled(true);
                            });
                        }
                    })
                    .addOnFailureListener(Throwable::printStackTrace)
                    .addOnCompleteListener(task -> imageProxy.close());
        } else {
            imageProxy.close();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        cameraExecutor.shutdown();
    }

    @androidx.camera.core.ExperimentalGetImage
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        if (requestCode == CAMERA_REQUEST_CODE &&
                grantResults.length > 0 &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            startCamera();
        } else {
            Toast.makeText(this, "Camera permission is required", Toast.LENGTH_LONG).show();
            finish();
        }
    }

    private boolean sendRequest(String method, String barcode, String patchField) {
        try {
            String url;
            if (method.equals("GET"))
                url = "http://" + ConnectionIP + ":7047/" + ServerInstance + "/ODataV4/Company('CRONUS%20International%20Ltd.')/BoardingList?$filter=Registration_No eq '" + barcode + "'";
            else
                url = "http://" + ConnectionIP + ":7047/" + ServerInstance + "/ODataV4/Company('CRONUS%20International%20Ltd.')/BoardingList('" + boardingNo + "')";
            HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();

            // Auth
            String credentials = "Agent:Agent1-2";
            String basicAuth = "Basic " + Base64.encodeToString(credentials.getBytes(), Base64.NO_WRAP);
            connection.setRequestProperty("Authorization", basicAuth);

            connection.setRequestMethod(method);
            connection.setRequestProperty("Accept", "application/json");

            if (method.equals("PATCH")) {
                connection.setDoOutput(true);
                connection.setRequestProperty("Content-Type", "application/json");
                connection.setRequestProperty("If-Match", etag);  // Required for OData PATCH

                JSONObject patchBody = new JSONObject();
                patchBody.put(patchField, true);

                try (OutputStream os = connection.getOutputStream()) {
                    byte[] input = patchBody.toString().getBytes("utf-8");
                    os.write(input, 0, input.length);
                }
            }

            int responseCode = connection.getResponseCode();

            if (method.equals("GET") && responseCode == 200) {
                InputStream inputStream = connection.getInputStream();
                String response = new BufferedReader(new InputStreamReader(inputStream))
                        .lines().collect(Collectors.joining("\n"));

                Log.d("DEBUG", "JSON Response: " + response);

                JSONObject json = new JSONObject(response);
                JSONArray valueArray = json.getJSONArray("value");

                if (valueArray.length() > 0) {
                    JSONObject item = valueArray.getJSONObject(0);
                    boardingNo = item.getString("Boarding_No");
                    etag = item.getString("@odata.etag"); // Use this for PATCH
                } else
                    return false;
            }

            return responseCode == 200;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void showResult(String resultMessage) {
        new AlertDialog.Builder(this)
                .setTitle(resultMessage.equals("successful") ? "Success" : "Failure")
                .setMessage("Operation was " + resultMessage)
                .setPositiveButton("OK", (dialog, which) -> {
                    Intent intent = new Intent(this, MainActivity.class); // Your initial screen
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                    finish();
                })
                .show();
    }
}
