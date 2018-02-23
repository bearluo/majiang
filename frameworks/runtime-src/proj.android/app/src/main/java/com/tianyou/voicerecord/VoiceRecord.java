package com.tianyou.voicerecord;

import android.media.MediaRecorder;
import android.util.Log;

import com.tianyou.luaevent.Contants;
import com.tianyou.luaevent.LuaEventProxy;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

/**
 * Created by bearluo on 2017/8/1.
 */

public class VoiceRecord {
    private MediaRecorder mRecorder = null;
    private RefreshVolomeTvTh mRefreshVolomeTvTh = null;
    private boolean mRunning = false;
    private static VoiceRecord instance = new VoiceRecord();
    private static String TAG = VoiceRecord.class.getSimpleName();
    public static VoiceRecord getInstance(){
        return instance;
    }

    public void startRecording(String fileName,String what) {
        Log.i(TAG,"startRecording");
        stopRecording();
        mRecorder = new MediaRecorder();
        //设置音源为Micphone
        mRecorder.setAudioChannels(1);
        mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        mRecorder.setAudioSamplingRate(8000);
        //设置封装格式
        mRecorder.setOutputFormat(MediaRecorder.OutputFormat.AMR_NB);
        mRecorder.setOutputFile(fileName);
        //设置编码格式
        mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
        try {
            mRecorder.prepare();
            mRecorder.start();
            mRefreshVolomeTvTh = new RefreshVolomeTvTh();
            mRefreshVolomeTvTh.start();
            mRunning = true;
        } catch (IOException e) {
            Log.e(TAG, "prepare() failed" + e.toString());
            fail("prepare() failed",what);
        }
    }

    public void stopRecording(){
        Log.i(TAG,"stopRecording");
        if (mRecorder != null) {
            mRecorder.release();
            mRecorder = null;
        }
        mRunning = false;
    }

    private class RefreshVolomeTvTh extends Thread {

        @Override
        public void run() {
            super.run();
            while (mRunning) {
                try {
                    // 1 - 32767 範圍
                    float ret = mRecorder.getMaxAmplitude();
                    if (ret < 1) ret = 1;
                    if (ret > 32767) ret = 32767;
                    JSONObject object = new JSONObject();
                    try {
                        object.put("level",ret/32767);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    Log.i(TAG,object.toString());
                    LuaEventProxy.getInstance().dispatchEvent(Contants.voiceRecordDecibels,object.toString());

                    sleep(1000);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void fail(String error,String what) {
        JSONObject object = new JSONObject();
        try {
            object.put("ret",3);
            object.put("what",what);
            object.put("error",error);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        LuaEventProxy.getInstance().dispatchEvent(Contants.voiceRecord,object.toString());
    }
}
