package com.tianyou.luaevent;

import android.util.Log;

import com.tencent.gcloud.voice.GCloudVoiceEngine;
import com.tencent.gcloud.voice.IGCloudVoiceNotify;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Timer;
import java.util.TimerTask;


/**
 * Created by bearluo on 2017/8/22.
 */

public class IGCloudVoiceNotifyHelper implements IGCloudVoiceNotify{
    private static boolean isRun = false;
    public static void startPoll(){
        if(!isRun) {
            isRun = true;
            //timer to poll
            TimerTask task = new TimerTask() {
                public void run() {
                    GCloudVoiceEngine.getInstance().Poll();
                }
            };
            Timer timer = new Timer(true);
            timer.schedule(task, 500, 500);
        }
    }

    @Override
    public void OnJoinRoom(int i, String s, int i1) {

    }

    @Override
    public void OnStatusUpdate(int status, String roomName, int memberID) {
        Log.i("IGCloudVoiceNotify", String.format("OnStatusUpdate  status=%d roomName:%s memberID:%d",status,roomName,memberID));
    }

    @Override
    public void OnQuitRoom(int i, String s) {

    }

    @Override
    public void OnMemberVoice(int[] members, int count) {
        String str = "OnMemberVoice Callback ";
        for (int i = 0; i < count; ++i) {
            str += " memberid:" + members[2 * i];
            str += " state:" + members[2 * i + 1];
        }
        Log.i("IGCloudVoiceNotify", "OnMemberVoice CallBack " + "count:" + count + "members" + str);
    }

    @Override
    public void OnUploadFile(int code, String filePath, String fileID) {
        JSONObject object = new JSONObject();
        try {
            object.put("ret",Contants.ret.success);
            object.put("method","OnUploadFile");
            object.put("code",code);
            object.put("filePath",filePath);
            object.put("fileID",fileID);
            Log.i("IGCloudVoiceNotify",object.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        LuaEventProxy.getInstance().dispatchEvent(Contants.gCloudVoice,object.toString());
    }

    @Override
    public void OnDownloadFile(int code, String filePath, String fileID) {
        Log.i("IGCloudVoiceNotify", "OnDownloadFile CallBack code=" + code);
        JSONObject object = new JSONObject();
        try {
            object.put("ret",Contants.ret.success);
            object.put("method","OnDownloadFile");
            object.put("code",code);
            object.put("filePath",filePath);
            object.put("fileID",fileID);
            Log.i("IGCloudVoiceNotify",object.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        LuaEventProxy.getInstance().dispatchEvent(Contants.gCloudVoice,object.toString());
    }

    @Override
    public void OnPlayRecordedFile(int code, String filePath) {
        JSONObject object = new JSONObject();
        try {
            object.put("ret",Contants.ret.success);
            object.put("method","OnPlayRecordedFile");
            object.put("code",code);
            object.put("filePath",filePath);
            Log.i(" ",object.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        LuaEventProxy.getInstance().dispatchEvent(Contants.gCloudVoice,object.toString());
    }

    @Override
    public void OnApplyMessageKey(int code) {
        Log.i("IGCloudVoiceNotify", "OnApplyMessageKey CallBack code=" + code);
        JSONObject object = new JSONObject();
        try {
            object.put("ret",Contants.ret.success);
            object.put("method","OnApplyMessageKey");
            object.put("code",code);
            Log.i("IGCloudVoiceNotify",object.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        LuaEventProxy.getInstance().dispatchEvent(Contants.gCloudVoice,object.toString());
    }

    @Override
    public void OnSpeechToText(int i, String s, String s1) {

    }

    @Override
    public void OnRecording(char[] chars, int nDataLength) {
        Log.i("IGCloudVoiceNotify","OnRecording CallBack nDataLength:" + nDataLength);
    }

    @Override
    public void OnStreamSpeechToText(int i, int i1, String s) {

    }
}
