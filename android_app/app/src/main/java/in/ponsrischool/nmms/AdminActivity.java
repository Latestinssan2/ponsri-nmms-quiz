package in.ponsrischool.nmms;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.appcompat.app.AppCompatActivity;

public class AdminActivity extends AppCompatActivity {
    private WebView adminWebView;
    private static final String ADMIN_URL = "https://nmms.ponsrischool.in";

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        adminWebView = findViewById(R.id.webview);
        WebSettings settings = adminWebView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(true);

        adminWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                // Trigger opening Admin modal directly once loaded
                adminWebView.evaluateJavascript("if (typeof openAdminModal === 'function') openAdminModal();", null);
            }
        });

        adminWebView.loadUrl(ADMIN_URL);
    }
}
