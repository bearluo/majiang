package com.tianyou.youke;

import android.app.Activity;

import com.tianyou.luaevent.Contants;
import com.tianyou.luaevent.LuaEventProxy;
import com.tianyou.utils.Function;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by bearluo on 2017/6/2.
 */


public class YoukeProxy {

    private static YoukeProxy instance = new YoukeProxy();
    private static String TAG = YoukeProxy.class.getSimpleName();
    public static YoukeProxy getInstance(){
        return instance;
    }
    private static Activity mActivity;

    public void setActivity(Activity activity) {
        mActivity = activity;
    }

    public static void loginYouke(){
        JSONObject object = new JSONObject();
        try {
            object.put("ret", Contants.ret.success);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        LuaEventProxy.getInstance().dispatchEvent(com.tianyou.luaevent.Contants.loginYouke, Function.getLoginCommentData(object,mActivity).toString());
    }

}
