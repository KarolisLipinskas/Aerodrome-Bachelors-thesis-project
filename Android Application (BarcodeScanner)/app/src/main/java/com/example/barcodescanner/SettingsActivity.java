package com.example.barcodescanner;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AlertDialog;

public class SettingsActivity extends AppCompatActivity {

    private EditText ipEditText, instanceEditText;
    private Button saveButton, backButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        ipEditText = findViewById(R.id.edit_ip);
        instanceEditText = findViewById(R.id.edit_instance);
        saveButton = findViewById(R.id.button_save);
        backButton = findViewById(R.id.button_back);

        // Load previously saved values
        SharedPreferences prefs = getSharedPreferences("AppSettings", MODE_PRIVATE);
        ipEditText.setText(prefs.getString("ip", ""));
        instanceEditText.setText(prefs.getString("instance", "NAV_2500CU0_W1"));

        saveButton.setOnClickListener(v -> {
            SharedPreferences.Editor editor = prefs.edit();
            editor.putString("ip", ipEditText.getText().toString());
            editor.putString("instance", instanceEditText.getText().toString());
            editor.apply(); // Save persistently

            // Show confirmation message
            new AlertDialog.Builder(SettingsActivity.this)
                    .setTitle("Settings Saved")
                    .setMessage("IP / Domain Name: " + ipEditText.getText().toString() + "\nServer Instance: " + instanceEditText.getText().toString())
                    .setPositiveButton("OK", null)
                    .show();
        });

        backButton.setOnClickListener(v -> finish());
    }
}
