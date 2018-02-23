package com.tianyou.luaevent;

/**
 * Created by bearluo on 2017/6/5.
 */

public class Contants {
    public static String loginFacebook = "loginFacebook";
    public static String loginYouke = "loginYouke";
    public static String gpayConsume = "gpayConsume";   //google支付成功向服务器请求发货
	public static String voiceRecord = "voiceRecord";   //錄音廣播
    public static String voiceRecordDecibels = "voiceRecordDecibels";   //錄音分貝 百分比
    public static String wxShare = "wxShare";   //google支付成功向服务器请求发货
    public static String wxPay = "wxPay";   //google支付成功向服务器请求发货
    public static String wxLogin = "wxLogin";   //微信授权申请Auto
    public static String wxAutoLogin = "wxAutoLogin";   //微信授权申请
    public static String gCloudVoice = "gCloudVoice";   //qq语音
    public static String webpayCallback = "webpayCallback";   //web支付到账


    public static class ret {
        public static int success = 1;
        public static int cancel = 2;
        public static int fail = 3;
        public static int TimeOut = 4;
    };
}
