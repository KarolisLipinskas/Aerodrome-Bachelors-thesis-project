package com.example.barcodescanner;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    Button startButton, exitButton, settingsButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        startButton = findViewById(R.id.button_start);
        settingsButton = findViewById(R.id.button_connection_settings);
        exitButton = findViewById(R.id.button_exit);

        startButton.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, ScannerActivity.class);
            startActivity(intent);
        });

        settingsButton.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, SettingsActivity.class);
            startActivity(intent);
        });

        exitButton.setOnClickListener(v -> finishAffinity());
    }
}