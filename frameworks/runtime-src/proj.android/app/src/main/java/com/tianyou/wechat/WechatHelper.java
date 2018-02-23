package com.tianyou.wechat;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.util.Log;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXMusicObject;
import com.tencent.mm.opensdk.modelmsg.WXTextObject;
import com.tencent.mm.opensdk.modelmsg.WXVideoObject;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.tianyou.luaevent.Contants;
import com.tianyou.luaevent.LuaEventProxy;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Comparator;
import java.util.Map;
import java.util.TreeMap;

/**
 * Created by bearluo on 2017/8/3.
 */

public class WechatHelper {
    private static final String APP_ID = "wx73964edf31faa87b";
    private static final String PARTNER_ID = "";
    private static final String APP_SECRET = "a5b964b35ccb2ea9d9b32e1dc80e4980";
    private static final String access_token_url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + APP_ID + "&secret="+ APP_SECRET +"&code=CODE&grant_type=authorization_code";
    private static final String auth_url = "https://api.weixin.qq.com/sns/auth?access_token=ACCESS_TOKEN&openid=OPENID";
    private static final String refresh_token_url = "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=" + APP_ID + "&grant_type=refresh_token&refresh_token=REFRESH_TOKEN";
    private static final int THUMB_SIZE = 150;
    // 32KB, api doc:http:sinaweibosdk.github.io/weibo_android_sdk/doc/com/sina/weibo/sdk/api/BaseMediaObject.html#setThumbImage(Bitmap)
    private static int MAX_SIZE_THUMBNAIL_BYTE = 32768;

    // 2MB, api doc: http://sinaweibosdk.github.io/weibo_android_sdk/doc/com/sina/weibo/sdk/api/ImageObject.html#imageData
    private static int MAX_SIZE_LARGE_BYTE = 10485760;
    private IWXAPI api;
    private Activity mActivity;

    private static WechatHelper instance = new WechatHelper();
    private static String TAG = WechatHelper.class.getSimpleName();
    public static WechatHelper getInstance(){
        return instance;
    }

    public void regToWx(Activity activity) {
        api = WXAPIFactory.createWXAPI(activity,APP_ID,true);
        api.registerApp(APP_ID);
        mActivity = activity;
    }

    public void handleIntent(Intent intent,Activity activity) {
        Log.i(TAG,"IWXAPIEventHandler");
        api.handleIntent(intent,mIWXAPIEventHandler);
        activity.finish();
    }

    private Bitmap getThumbnail(Bitmap source,boolean isClear){
        if (source.getByteCount() > MAX_SIZE_THUMBNAIL_BYTE) {
            Bitmap thumbnailImg;
            double scale = Math.sqrt(1.0 * source.getByteCount() / MAX_SIZE_THUMBNAIL_BYTE);
            int scaledW = (int) (source.getWidth() / scale);
            int scaledH = (int) (source.getHeight() / scale);

            thumbnailImg = Bitmap.createScaledBitmap(source, scaledW, scaledH, true);
            if (isClear) source.recycle();
            source = thumbnailImg;
        }
        return source;
    }
    private Bitmap getLargeBitmap(Bitmap source,boolean isClear){
        if (source.getByteCount() > MAX_SIZE_LARGE_BYTE) {
            Bitmap largeImg;
            double scale = Math.sqrt(1.0 * source.getByteCount() / MAX_SIZE_LARGE_BYTE);
            int scaledW = (int) (source.getWidth() / scale);
            int scaledH = (int) (source.getHeight() / scale);

            largeImg = Bitmap.createScaledBitmap(source, scaledW, scaledH, true);
            if (isClear) source.recycle();
            source = largeImg;
        }
        return source;
    }

    public boolean isWXAppInstalled(){
        return api.isWXAppInstalled();
    }

    /**
     *
     * @param transaction 请求唯一标识
     * @param description 描述
     * @param text 文本
     * @param scene 微信场景
     */
    public boolean shareTextToWx(String transaction,String text,String description,int scene){
        WXTextObject textObject = new WXTextObject(text);
        WXMediaMessage msg = new WXMediaMessage();
        msg.mediaObject = textObject;
        msg.description = description;

        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = transaction;
        req.message = msg;
        req.scene = scene;
        return api.sendReq(req);
    }

    /**
     *
     * @param transaction 请求唯一标识
     * @param description 描述
     * @param bmp 图片
     * @param scene 微信场景
     */
    public boolean shareBitmapToWx(String transaction, Bitmap bmp, String description, int scene){
        WXImageObject imageObject = new WXImageObject(getLargeBitmap(bmp,false));

        WXMediaMessage msg = new WXMediaMessage();
        msg.mediaObject = imageObject;
        msg.description = description;

        Bitmap thumbBmp = getThumbnail(Bitmap.createScaledBitmap(bmp,THUMB_SIZE,THUMB_SIZE,true),true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp,true);

        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = transaction;
        req.message = msg;
        req.scene = scene;
        return api.sendReq(req);
    }

    /**
     *
     * @param transaction 请求唯一标识
     * @param url 音乐url地址
     * @param title 标题
     * @param description 描述
     * @param bmp 音乐缩略图
     * @param scene 微信场景
     */
    public void shareMusicToWx(String transaction,String url,String title,String description,Bitmap bmp,int scene){
        WXMusicObject musicObject = new WXMusicObject();
        musicObject.musicUrl = url;

        WXMediaMessage msg = new WXMediaMessage();
        msg.mediaObject = musicObject;
        msg.title = title;
        msg.description = description;

        Bitmap thumbBmp = getThumbnail(Bitmap.createScaledBitmap(bmp,THUMB_SIZE,THUMB_SIZE,true),true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp,true);

        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = transaction;
        req.message = msg;
        req.scene = scene;
        api.sendReq(req);
    }

    /**
     *
     * @param transaction 请求唯一标识
     * @param url 视频url地址
     * @param title 标题
     * @param description 描述
     * @param bmp 视频缩略图
     * @param scene 微信场景
     */
    public void shareVideoToWx(String transaction,String url,String title,String description,Bitmap bmp,int scene){
        WXVideoObject videoObject = new WXVideoObject();
        videoObject.videoUrl = url;

        WXMediaMessage msg = new WXMediaMessage();
        msg.mediaObject = videoObject;
        msg.title = title;
        msg.description = description;

        Bitmap thumbBmp = getThumbnail(Bitmap.createScaledBitmap(bmp,THUMB_SIZE,THUMB_SIZE,true),true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp,true);

        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = transaction;
        req.message = msg;
        req.scene = scene;
        api.sendReq(req);
    }

    /**
     *
     * @param transaction 请求唯一标识
     * @param url 网页url地址
     * @param title 标题
     * @param description 描述
     * @param bmp 网页缩略图
     * @param scene 微信场景
     */
    public boolean shareWebToWx(String transaction,String url,String title,String description,Bitmap bmp,int scene){
        WXWebpageObject webpageObject = new WXWebpageObject();
        webpageObject.webpageUrl = url;

        WXMediaMessage msg = new WXMediaMessage();
        msg.mediaObject = webpageObject;
        msg.title = title;
        msg.description = description;

        Bitmap thumbBmp = getThumbnail(Bitmap.createScaledBitmap(bmp,THUMB_SIZE,THUMB_SIZE,true),true);
        bmp.recycle();
        msg.thumbData = Util.bmpToByteArray(thumbBmp,true);

        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = transaction;
        req.message = msg;
        req.scene = scene;
        return api.sendReq(req);
    }

    /**
     * 微信支付
     * @param prepayId 预订单
     * @param packageValue 扩展字段 默认 Sign=WXPay
     */
    public void pay(String prepayId,String packageValue){
        PayReq request = new PayReq();
        request.appId = APP_ID;
        request.partnerId = PARTNER_ID;
        request.prepayId= prepayId;
        request.packageValue = packageValue;
        request.nonceStr= Util.getMessageDigest(String.valueOf(System.currentTimeMillis()).getBytes());
        request.timeStamp = String.valueOf(System.currentTimeMillis() / 1000);
        Map<String, String> map = new TreeMap<>(new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                return o1.compareTo(o2);
            }
        });
        map.put("appId", request.appId);
        map.put("partnerId", request.partnerId);
        map.put("prepayId", request.prepayId);
        map.put("packageValue", request.packageValue);
        map.put("nonceStr", request.nonceStr);
        map.put("timeStamp", request.timeStamp);
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> entry : map.entrySet()) {
            System.out.println(entry.getKey() + " " + entry.getValue());
            sb.append(entry.getKey());
            sb.append('=');
            sb.append(entry.getValue());
            sb.append('&');
        }
        request.sign = Util.getMessageDigest(sb.substring(0,sb.length()-1).getBytes()).toUpperCase();
        api.sendReq(request);
    }

    public void sendAuthRequest(String state)
    {
        //构造SendAuthReq结构体
        SendAuth.Req req = new SendAuth.Req();
        req.scope = "snsapi_userinfo";
        req.state = state;
        api.sendReq(req);
    }

    public void autoLoginWx(String refresh_token,final String transaction){
        String uri = refresh_token_url.replace("REFRESH_TOKEN", refresh_token);
        Log.e("autoLoginWx",uri);
        WXHttpGet httpGet  = new WXHttpGet(uri, new WXHttpGet.Callback() {
            @Override
            public void callback(String json) {
                JSONObject object = new JSONObject();
                if( json != null){
                    Log.e("WXHttpGet", json);
                    try {
                        object.put("ret", Contants.ret.success);
                        object.put("transaction",transaction);
                        object.put("data",json);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                else{
                    Log.e("WXHttpGet", "json is null");
                    try {
                        object.put("ret", Contants.ret.fail);
                        object.put("code", BaseResp.ErrCode.ERR_AUTH_DENIED);
                        object.put("error","json is null");
                        object.put("transaction",transaction);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                LuaEventProxy.getInstance().dispatchEvent(Contants.wxAutoLogin,object.toString());
            }
        });
        httpGet.Execute();
    }

    private static IWXAPIEventHandler mIWXAPIEventHandler = new IWXAPIEventHandler() {
        @Override
        public void onReq(BaseReq baseReq) {

        }

        @Override
        public void onResp(BaseResp baseResp) {
            Log.i("IWXAPIEventHandler",String.format("onResp Type %d",baseResp.getType()) );
            if(baseResp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
                onPay(baseResp);
            }else if(baseResp.getType() == ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX) {
                onShare(baseResp);
            }else if(baseResp.getType() == ConstantsAPI.COMMAND_SENDAUTH) {
                onLogin(baseResp);
            }
        }

        public void onPay(BaseResp baseResp) {
            switch (baseResp.errCode) {
                case BaseResp.ErrCode.ERR_OK:
                    {
                        JSONObject object = new JSONObject();
                        try {
                            object.put("ret",Contants.ret.success);
                            object.put("transaction",baseResp.transaction);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        LuaEventProxy.getInstance().dispatchEvent(Contants.wxPay,object.toString());
                    }
                    break;
                case BaseResp.ErrCode.ERR_USER_CANCEL:
                    {
                        JSONObject object = new JSONObject();
                        try {
                            object.put("ret",Contants.ret.cancel);
                            object.put("transaction",baseResp.transaction);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        LuaEventProxy.getInstance().dispatchEvent(Contants.wxPay,object.toString());
                    }
                    break;
                default:
                    {
                        JSONObject object = new JSONObject();
                        try {
                            object.put("ret",Contants.ret.fail);
                            object.put("code",baseResp.errCode);
                            object.put("error",baseResp.errStr);
                            object.put("transaction",baseResp.transaction);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        LuaEventProxy.getInstance().dispatchEvent(Contants.wxPay,object.toString());
                    }
                    break;
            }
        }

        public void onShare(BaseResp baseResp) {
            switch (baseResp.errCode) {
                case BaseResp.ErrCode.ERR_OK:
                    {
                        JSONObject object = new JSONObject();
                        try {
                            object.put("ret",Contants.ret.success);
                            object.put("transaction",baseResp.transaction);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        LuaEventProxy.getInstance().dispatchEvent(Contants.wxShare,object.toString());
                    }
                    break;
                case BaseResp.ErrCode.ERR_USER_CANCEL:
                    {
                        JSONObject object = new JSONObject();
                        try {
                            object.put("ret",Contants.ret.cancel);
                            object.put("transaction",baseResp.transaction);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        LuaEventProxy.getInstance().dispatchEvent(Contants.wxShare,object.toString());
                    }
                    break;
                default:
                    {
                        JSONObject object = new JSONObject();
                        try {
                            object.put("ret",Contants.ret.fail);
                            object.put("code",baseResp.errCode);
                            object.put("error",baseResp.errStr);
                            object.put("transaction",baseResp.transaction);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        LuaEventProxy.getInstance().dispatchEvent(Contants.wxShare,object.toString());
                    }
                    break;
            }
        }
        public void onLogin(final BaseResp baseResp) {
            final String state = ((SendAuth.Resp) baseResp).state;
            switch (baseResp.errCode) {
                case BaseResp.ErrCode.ERR_OK:
                {
                    String code = ((SendAuth.Resp) baseResp).code; //即为所需的code
                    String uri = access_token_url.replace("CODE", code);
                    Log.e("COMMAND_SENDAUTH",uri);
                    WXHttpGet httpGet  = new WXHttpGet(uri, new WXHttpGet.Callback() {
                        @Override
                        public void callback(String json) {
                            JSONObject object = new JSONObject();
                            if(json != null){
                                Log.e("WXHttpGet", json);
                                try {
                                    object.put("ret", Contants.ret.success);
                                    object.put("state",state);
                                    object.put("data",json);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                            else{
                                Log.e("WXHttpGet", "json is null");
                                try {
                                    object.put("ret", Contants.ret.fail);
                                    object.put("code", BaseResp.ErrCode.ERR_AUTH_DENIED);
                                    object.put("error","json is null");
                                    object.put("state",state);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                            LuaEventProxy.getInstance().dispatchEvent(Contants.wxLogin,object.toString());
                        }
                    });
                    httpGet.Execute();
                }
                break;
                case BaseResp.ErrCode.ERR_USER_CANCEL:
                {
                    JSONObject object = new JSONObject();
                    try {
                        object.put("ret",Contants.ret.cancel);
                        object.put("state",state);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    LuaEventProxy.getInstance().dispatchEvent(Contants.wxLogin,object.toString());
                }
                break;
                default:
                {
                    JSONObject object = new JSONObject();
                    try {
                        object.put("ret",Contants.ret.fail);
                        object.put("code",baseResp.errCode);
                        object.put("error",baseResp.errStr);
                        object.put("state",state);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    LuaEventProxy.getInstance().dispatchEvent(Contants.wxLogin,object.toString());
                }
                break;
            }
        }
    };
}
