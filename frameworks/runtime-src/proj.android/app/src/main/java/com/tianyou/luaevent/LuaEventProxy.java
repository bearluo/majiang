package com.tianyou.luaevent;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.os.Vibrator;
import android.util.Log;

import com.tencent.gcloud.voice.GCloudVoiceEngine;
import com.umeng.analytics.MobclickAgent;
import com.tianyou.utils.Function;
import com.tianyou.wechat.WechatHelper;
import com.tianyou.voicerecord.VoiceRecord;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayDeque;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Queue;

/**
 * Created by bearluo on 2017/6/5.
 */

public class LuaEventProxy {

    private static String TAG = LuaEventProxy.class.getSimpleName();
    private static LuaEventProxy instance = new LuaEventProxy();
    private Cocos2dxActivity activity;
    private static Queue<Runnable> queue = new ArrayDeque<>();
    public static LuaEventProxy getInstance(){
        return instance;
    }
    public void setCocos2dxActivity(final Cocos2dxActivity activity) {
        this.activity = activity;
    }
    public void dispatchEvent(final String event_cmd,final String params) {
        dispatchEvent(event_cmd,params,true);
    }

    public void dispatchEvent(final String event_cmd,final String params,final boolean runOnGLThread) {
        Runnable mRunnable = new Runnable(){
            @Override
            public void run() {
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("cmd",event_cmd);
                    jsonObject.put("params",params);
                    int ret = Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("native_event",jsonObject.toString());
                    Log.e(TAG, String.format("dispatchEvent: cmd %s ret %d",event_cmd,ret));
                } catch (JSONException e) {
//                    e.printStackTrace();
                    Log.e(TAG, String.format("dispatchEvent: cmd %s JSONException %s",event_cmd,e.getMessage()));
                }
            }
        };
        Log.i(TAG, String.format("dispatchEvent: cmd %s runOnGLThread %b",event_cmd,runOnGLThread));
        if (runOnGLThread) {
            queue.add(mRunnable);
        }else{
            mRunnable.run();
        }
    }

    public void dispatchQueueEvent() {
        while(!queue.isEmpty()) {
            Runnable mRunnable = queue.poll();
            activity.runOnGLThread(mRunnable);
        }
    }

    public static void getQueueEvent() {
        LuaEventProxy.getInstance().dispatchQueueEvent();
    }

    public static int getBatterypercentage() {
        return Function.getBatterypercentage(LuaEventProxy.getInstance().activity);
    }

    public static int getSignalStrength() {
        int type = Function.getAPNType(LuaEventProxy.getInstance().activity);
//        没有网络-0：WIFI网络1：4G网络-4：3G网络-3：2G网络-2
        if ( type == 0 ) return 0;
        if ( type == 1 ) return Function.getWIFISignalStrength(LuaEventProxy.getInstance().activity);
        return Function.getTeleSignalStrength(LuaEventProxy.getInstance().activity);
    }

    public static void onProfileSignIn(String Provider, String ID){
        Log.i(TAG,String.format("onProfileSignIn Provider:%s ID:%s",Provider,ID));
        if (ID.compareTo("") == 0) return;
        if ( Provider.compareTo("") == 0 )
            MobclickAgent.onProfileSignIn(ID);
        else
            MobclickAgent.onProfileSignIn(Provider,ID);
    }

    public static void onProfileSignOff() {
        Log.i(TAG,String.format("onProfileSignOff"));
        MobclickAgent.onProfileSignOff();
    }

    public static void onEvent(String eventId,String jsonStr) {
        Log.i(TAG,String.format("onEvent eventId:%s jsonStr:%s",eventId,jsonStr));
        if (eventId.compareTo("") == 0) return;

        if (jsonStr.compareTo("") == 0 || jsonStr.compareTo("null") == 0 ) {
            MobclickAgent.onEvent(LuaEventProxy.getInstance().activity, eventId);
            return;
        }

        HashMap<String,String> map = new HashMap<String,String>();
        try {
            JSONObject jsonObject= new JSONObject(jsonStr);
            for (Iterator<String> keys = jsonObject.keys(); keys.hasNext();) {
                String key = keys.next();
                System.out.println("key:" + key + "----------jo.get(key):"
                        + jsonObject.getString(key));
                map.put(key,jsonObject.getString(key));
            }
            MobclickAgent.onEvent(LuaEventProxy.getInstance().activity, eventId,map);
        } catch (JSONException e) {
//            e.printStackTrace();
            MobclickAgent.onEvent(LuaEventProxy.getInstance().activity, eventId);
        }
    }

    public static void onEventValue(String eventId,String jsonStr,int value) {
        Log.i(TAG,String.format("onEventValue eventId:%s jsonStr:%s value:%d",eventId,jsonStr,value));
        if (eventId.compareTo("") == 0) return;
        if (jsonStr.compareTo("") == 0 || jsonStr.compareTo("null") == 0) return;
        HashMap<String,String> map = new HashMap<String,String>();
        try {
            JSONObject jsonObject= new JSONObject(jsonStr);
            for (Iterator<String> keys = jsonObject.keys(); keys.hasNext();) {
                String key = keys.next();
                System.out.println("key:" + key + "----------jo.get(key):"
                        + jsonObject.getString(key));
                map.put(key,jsonObject.getString(key));
            }
            MobclickAgent.onEventValue(LuaEventProxy.getInstance().activity, eventId,map,value);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static void reportError(String error) {
        Log.i(TAG,String.format("reportError error:%s",error));
        if (error.compareTo("") == 0) return;
        MobclickAgent.reportError(LuaEventProxy.getInstance().activity, error);
    }

    public static void vibrate() {
        Vibrator vibrator = (Vibrator)LuaEventProxy.getInstance().activity.getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        long [] pattern = {100,400,100,400};   // 停止 开启 停止 开启
        vibrator.vibrate(pattern,-1);
    }
	
	public static void startRecord(String path,String what) {
        VoiceRecord.getInstance().startRecording(path, what);
    }
    public static void stopRecord() {
        VoiceRecord.getInstance().stopRecording();
    }

    public static void loginWx(String state) {
        WechatHelper.getInstance().sendAuthRequest(state);
    }
    public static void autoLoginWx(String refresh_token,String transaction) {
        WechatHelper.getInstance().autoLoginWx(refresh_token,transaction);
    }

    public static int loginGCloudVoice(String openId){
        Log.i(TAG,String.format("loginGCloudVoice openId:%s",openId));
        GCloudVoiceEngine.getInstance().SetAppInfo("1216780538","d175a49c831bac3a8b11489d4268d7de",openId);
        GCloudVoiceEngine.getInstance().Init();
        Log.i(TAG,String.format("SetNotify %d",GCloudVoiceEngine.getInstance().SetNotify(new IGCloudVoiceNotifyHelper())));
        GCloudVoiceEngine.getInstance().SetMode(1);
        IGCloudVoiceNotifyHelper.startPoll();
        return GCloudVoiceEngine.getInstance().ApplyMessageKey(10000);
    }

    public static int startRecording(String path) {
        Log.i(TAG,String.format("startRecording path:%s",path));
//        VoiceRecord.getInstance().startRecording(path + ".temp","VoiceRecord.temp");
        return GCloudVoiceEngine.getInstance().StartRecording(path);
    }

    public static int stopRecording() {
//        VoiceRecord.getInstance().stopRecording();
        return GCloudVoiceEngine.getInstance().StopRecording();
    }

    public static int uploadRecordedFile(String path) {
        Log.i(TAG,String.format("uploadRecordedFile path:%s",path));
        return GCloudVoiceEngine.getInstance().UploadRecordedFile(path,10000);
    }

    public static int downloadRecordedFile(String fileID,String downloadFilePath) {
        Log.i(TAG,String.format("downloadRecordedFile fileID:%s downloadFilePath:%s",fileID,downloadFilePath));
        return GCloudVoiceEngine.getInstance().DownloadRecordedFile(fileID,downloadFilePath,10000);
    }

    public static int playRecordedFile(String downloadFilePath) {
        Log.i(TAG,String.format("playRecordedFile downloadFilePath:%s",downloadFilePath));
        return GCloudVoiceEngine.getInstance().PlayRecordedFile(downloadFilePath);
    }

    public static int stopPlayFile () {
        return GCloudVoiceEngine.getInstance().StopPlayFile();
    }

    static public int copyToClipboard(final String text)
    {
        try
        {
            //Log.d("cocos2dx","copyToClipboard " + text);
            Runnable runnable = new Runnable() {
                public void run() {
                    android.content.ClipboardManager clipboard = (android.content.ClipboardManager) Cocos2dxActivity.getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                    android.content.ClipData clip = android.content.ClipData.newPlainText("Copied Text", text);
                    clipboard.setPrimaryClip(clip);
                }
            };
            //getSystemService运行所在线程必须执行过Looper.prepare()
            //否则会出现Can't create handler inside thread that has not called Looper.prepare()
            ((Cocos2dxActivity)Cocos2dxActivity.getContext()).runOnUiThread(runnable);

        }catch(Exception e){
            // Log.d("cocos2dx","copyToClipboard error");
            e.printStackTrace();
            return -1;
        }
        return 0;
    }
    public static int isWXAppInstalled() {
        return WechatHelper.getInstance().isWXAppInstalled() == true ? 1:0;
    }

    public static int shareBitmapToWx(String transaction, String bmpPath, String description, int scene) {
        return WechatHelper.getInstance().shareBitmapToWx(transaction, BitmapFactory.decodeFile(bmpPath),description,scene) == true ? 1:0;
    }

    public static int shareTextToWx(String transaction,String text,String description,int scene) {
        return WechatHelper.getInstance().shareTextToWx(transaction, text,description,scene) == true ? 1:0;
    }

    public static int shareWebToWx(String transaction,String url,String title,String description,String bmpPath,int scene) {
        Log.i("shareWebToWx",bmpPath);
        if (bmpPath.substring(0,7).compareTo("assets/") == 0) {
            try {
                return WechatHelper.getInstance().shareWebToWx(transaction, url,title,description,BitmapFactory.decodeStream(AppActivity.getActivity().getAssets().open(bmpPath.substring(7))),scene) == true ? 1:0;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return WechatHelper.getInstance().shareWebToWx(transaction, url,title,description,BitmapFactory.decodeFile(bmpPath),scene) == true ? 1:0;
    }

    public static void displayWebView(final int x,final int y,final int width,final int height) {
        AppActivity.getActivity().displayWebView(x,y,width,height);
    }

    public static void dismissWebView(){
        AppActivity.getActivity().dismissWebView();
    }

    public static void webViewLoadUrl(String url) {
        AppActivity.getActivity().loadUrl(url);
    }

    public static int isWebViewVisible() {
        return AppActivity.getActivity().isWebViewVisible() == true ? 1:0;
    }

    public static void webPayCallBack(String mch_id,String mch_order_id,String mch_order_date) {
        if (mch_id == null) mch_id="";
        if (mch_order_id == null) mch_order_id="";
        if (mch_order_date == null) mch_order_date="";
        JSONObject object = new JSONObject();
        try {
            object.put("ret",Contants.ret.success);
            object.put("mch_id",mch_id);
            object.put("mch_order_id",mch_order_id);
            object.put("mch_order_date",mch_order_date);
            Log.i("webPayCallBack",object.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        LuaEventProxy.getInstance().dispatchEvent(Contants.webpayCallback,object.toString());
    }
}
