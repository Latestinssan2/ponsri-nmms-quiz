package in.ponsrischool.nmms;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.NotificationCompat;

public class MainActivity extends AppCompatActivity {

    private WebView webView;
    private ProgressBar progressBar;
    private int strikeCount = 0;
    private static final int MAX_STRIKES = 3;
    private boolean isTestRunning = false;
    private static final String PORTAL_URL = "https://nmms.ponsrischool.in";
    private static final String CHANNEL_ID = "nmms_live_channel";

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Keep Screen Awake permanently while taking test (unless hardware power button is pressed)
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webview);
        progressBar = findViewById(R.id.progressBar);

        createNotificationChannel();

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(true);
        settings.setSupportZoom(false);
        settings.setBuiltInZoomControls(false);
        settings.setCacheMode(WebSettings.LOAD_DEFAULT);

        // Native Android Bridge for Anti-Cheat and Notifications
        webView.addJavascriptInterface(new WebAppInterface(this), "AndroidApp");

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                progressBar.setVisibility(View.GONE);
                // Inject App Marker so web UI knows it is running inside the secure app
                webView.evaluateJavascript("window.IS_SECURE_ANDROID_APP = true;", null);
            }
        });

        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                if (newProgress < 100) {
                    progressBar.setVisibility(View.VISIBLE);
                    progressBar.setProgress(newProgress);
                } else {
                    progressBar.setVisibility(View.GONE);
                }
            }
        });

        webView.loadUrl(PORTAL_URL);
    }

    @Override
    protected void onPause() {
        super.onPause();
        // Triggered when user minimizes app, switches apps, or locks screen
        if (isTestRunning) {
            strikeCount++;
            int remaining = MAX_STRIKES - strikeCount;

            if (strikeCount >= MAX_STRIKES) {
                // Auto-submit quiz in WebView
                runOnUiThread(() -> {
                    Toast.makeText(this, "🚨 ૩ વખત એપ બહાર નીકળવા બદલ કસોટી આપમેળે જમા થઈ ગઈ છે!", Toast.LENGTH_LONG).show();
                    webView.evaluateJavascript("if (typeof submitQuiz === 'function') submitQuiz(true);", null);
                });
            } else {
                runOnUiThread(() -> {
                    showWarningDialog(strikeCount, remaining);
                });
            }
        }
    }

    private void showWarningDialog(int strike, int remaining) {
        new AlertDialog.Builder(this)
                .setTitle("⚠️ સુરક્ષા ચેતવણી (" + strike + "/" + MAX_STRIKES + ")")
                .setMessage("કસોટી દરમિયાન એપ મિનિમાઇઝ કરવી અથવા સ્ક્રીન બંધ કરવી સખત પ્રતિબંધિત છે!\n\nજો તમે વધુ " + remaining + " વખત આવું કરશો તો કસોટી આપમેળે જમા થઈ જશે.")
                .setPositiveButton("સમજાયું", null)
                .setCancelable(false)
                .show();
    }

    @Override
    public void onBackPressed() {
        if (isTestRunning) {
            new AlertDialog.Builder(this)
                    .setTitle("કસોટી ચાલુ છે!")
                    .setMessage("શું તમે કસોટી જમા કર્યા વગર બહાર નીકળવા માંગો છો?")
                    .setPositiveButton("કસોટી જમા કરો", (dialog, which) -> {
                        webView.evaluateJavascript("if (typeof submitQuiz === 'function') submitQuiz(true);", null);
                    })
                    .setNegativeButton("પાછા જાઓ", null)
                    .show();
        } else if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "NMMS Live Test Notifications",
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("નવી NMMS લાઈવ કસોટી માટે નોટિફિકેશન");
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    public void triggerLiveNotification(String title, String message) {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.app_logo)
                .setContentTitle(title)
                .setContentText(message)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true);

        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (manager != null) {
            manager.notify(101, builder.build());
        }
    }

    // JavaScript Interface to receive commands from portal
    public class WebAppInterface {
        Context mContext;

        WebAppInterface(Context c) {
            mContext = c;
        }

        @JavascriptInterface
        public void setTestRunning(boolean running) {
            isTestRunning = running;
            if (running) {
                strikeCount = 0;
            }
        }

        @JavascriptInterface
        public void notifyQuizLive(String title, String message) {
            triggerLiveNotification(title, message);
        }
    }
}
