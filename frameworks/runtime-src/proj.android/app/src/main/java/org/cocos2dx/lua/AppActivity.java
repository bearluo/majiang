/****************************************************************************
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2011      Zynga Inc.
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.lua;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.tencent.gcloud.voice.GCloudVoiceEngine;
import com.umeng.analytics.MobclickAgent;
import com.tianyou.luaevent.LuaEventProxy;
import com.tianyou.cangzhoumajiang.R;
import com.tianyou.utils.ShortCutUtils;
import com.tianyou.wechat.WechatHelper;
import com.tianyou.youke.YoukeProxy;

public class AppActivity extends Cocos2dxActivity  {

    static final String TAG = "PokerApp";
    private WebView m_webView;
    private ProgressBar mProgressBar;

    private static AppActivity mAppActivity;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mAppActivity = this;
        LuaEventProxy.getInstance().setCocos2dxActivity(this);
        YoukeProxy.getInstance().setActivity(this);
        MobclickAgent.enableEncrypt(true);
        //  不锁屏 不休眠
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        saveVersionInfo();
        WechatHelper.getInstance().regToWx(this);
        // qq 语音
        GCloudVoiceEngine.getInstance().init(getApplicationContext(), this);
        initWebView();
    }

    void initWebView() {
        m_webView = new WebView((Cocos2dxActivity) Cocos2dxActivity.getContext());
        mProgressBar = new ProgressBar(Cocos2dxActivity.getContext(), null,
                android.R.attr.progressBarStyleHorizontal);
        LinearLayout.LayoutParams layoutParams1 = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 8);
        mProgressBar.setLayoutParams(layoutParams1);
        Drawable drawable = Cocos2dxActivity.getContext().getResources().getDrawable(
                R.drawable.progress_horizontal);
        mProgressBar.setProgressDrawable(drawable);
        m_webView.addView(mProgressBar);
//        mFrameLayout.addView(m_webView);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT);
        //可选的webview位置，x,y,width,height可任意填写，也可以做为函数参数传入。
        m_webView.setLayoutParams(layoutParams);

        addContentView(m_webView,layoutParams);
        //可选的webview配置
//                    m_webView.setBackgroundColor(0);
        m_webView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
        m_webView.getSettings().setAppCacheEnabled(false);
        m_webView.getSettings().setJavaScriptEnabled(true);

        m_webView.setWebViewClient(new WebViewClient(){
            public boolean shouldOverrideUrlLoading(final WebView view,final String url) {
                Log.i(TAG,String.format("displayWebView url:%s",url));
                Uri uri = Uri.parse(url);
                if (uri.getScheme().compareTo("weixin") == 0) {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                    startActivity(intent);
                    return true;
                }else if(uri.getScheme().compareTo("tianyoumajiang") == 0) {
                    if (uri.getHost().compareTo("webpaycallback") == 0) {
                        LuaEventProxy.getInstance().webPayCallBack(
                                uri.getQueryParameter("mch_id"),
                                uri.getQueryParameter("mch_order_id"),
                                uri.getQueryParameter("mch_order_date"));
                    }
                    return true;
                }
                return false;
            }
            public void onReceivedError(WebView view, int errorCode,String description, String failingUrl) {
                Log.i(TAG,String.format("onReceivedError description:%s",description));
            }
            public void onReceivedSslError(WebView view, android.webkit.SslErrorHandler handler, android.net.http.SslError error) {
                if(error.getPrimaryError() == android.net.http.SslError.SSL_INVALID ){// 校验过程遇到了bug
                    handler.proceed();
                }else{
                    handler.cancel();
                }
            }
        });
        m_webView.setWebChromeClient(new WebChromeClient(){
            public void onProgressChanged(WebView view, int newProgress) {
                Log.i(TAG,String.format("onProgressChanged newProgress:%d",newProgress));
                if (newProgress == 100) {
                    mProgressBar.setVisibility(View.GONE);
                } else {
                    if (mProgressBar.getVisibility() == View.GONE)
                        mProgressBar.setVisibility(View.VISIBLE);
                    mProgressBar.setProgress(newProgress);
                }
                super.onProgressChanged(view, newProgress);
            }
        });
        m_webView.setVisibility(View.GONE);
    }

    void complain(String message) {
        Log.e(TAG, "**** TrivialDrive Error: " + message);
        alert("Error: " + message);
    }

    void alert(String message) {
        AlertDialog.Builder bld = new AlertDialog.Builder(this);
        bld.setMessage(message);
        bld.setNeutralButton("OK", null);
        Log.d(TAG, "Showing alert dialog: " + message);
        bld.create().show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // google play requestCode 10001
        Log.d(TAG, "onActivityResult(" + requestCode + "," + resultCode + "," + data);

    }

    public void Toast(final String msg) {
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(AppActivity.this, msg, Toast.LENGTH_SHORT).show();
            }
        });
    }

    // We're being destroyed. It's important to dispose of the helper here!

    @Override
    protected void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
        GCloudVoiceEngine.getInstance().Resume();
        resumeWebView();
        Log.i(TAG,"PokerApp onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
        GCloudVoiceEngine.getInstance().Pause();
        pauseWebView();
        Log.i(TAG,"PokerApp onPause");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

         // very important:
        Log.d(TAG, "Destroying helper.");
    }

    private float getVersionCode() {
        float versionCode = 0f;
        try{
            versionCode = this.getPackageManager().getPackageInfo(this.getPackageName(),0).versionCode;
        }catch (PackageManager.NameNotFoundException e){
            e.printStackTrace();
        }
        return versionCode;
    }

    private void saveVersionInfo() {
        float nowVersionCode = getVersionCode();
        Log.i(TAG,"nowVersionCode" + nowVersionCode);

        SharedPreferences sp = getSharedPreferences("version_info",MODE_PRIVATE);
        float spVersionCode = sp.getFloat("version_code",0f);

        if(nowVersionCode > spVersionCode) {
//            ShortCutUtils.delShortcut(this,this);
            ShortCutUtils.addShortCut(this, getResources().getString(R.string.app_name),R.drawable.icon,"org.cocos2dx.lua.AppActivity");
            SharedPreferences.Editor editor = sp.edit();
            editor.putFloat("version_code",nowVersionCode);
            editor.commit();
        }
    }
    public void displayWebView(final int x,final int y,final int width,final int height) {
        Log.i(TAG,String.format("displayWebView x:%d y:%d width:%d height:%d",x,y,width,height));
        if (m_webView!=null) {
            this.runOnUiThread(new Runnable() {
                public void run() {
                    FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
                            FrameLayout.LayoutParams.WRAP_CONTENT);
                    layoutParams.leftMargin = x;
                    layoutParams.topMargin = y;
                    layoutParams.width = width;
                    layoutParams.height = height;
                    layoutParams.gravity = Gravity.TOP | Gravity.LEFT;
                    m_webView.setLayoutParams(layoutParams);
                    m_webView.setVisibility(View.VISIBLE);
                }
            });
        }
    }

    public void dismissWebView(){
        Log.i(TAG,String.format("dismissWebView"));
        if (m_webView!=null) {
            this.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    m_webView.setVisibility(View.GONE);
                }
            });
        }
    }

    public void loadUrl(final String url) {
        Log.i(TAG,"loadUrl");
        if (m_webView!=null) {
            Log.i(TAG,url);
            this.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    m_webView.loadUrl(url);
                }
            });
        }
    }

    public boolean isWebViewVisible() {
        if (m_webView!=null) {
            return m_webView.getVisibility() == View.VISIBLE;
        }
        return false;
    }

    public void pauseWebView() {
        if (m_webView!=null) {
            m_webView.onPause();
            m_webView.pauseTimers();
        }
    }

    public void resumeWebView() {
        if (m_webView!=null) {
            m_webView.onResume();
            m_webView.resumeTimers();
        }
    }

    public static AppActivity getActivity() {
        return mAppActivity;
    }
}
