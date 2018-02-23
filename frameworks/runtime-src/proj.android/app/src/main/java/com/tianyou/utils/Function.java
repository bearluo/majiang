package com.tianyou.utils;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.BatteryManager;
import android.os.Build;
import android.telephony.CellInfo;
import android.telephony.CellInfoCdma;
import android.telephony.CellInfoGsm;
import android.telephony.CellInfoLte;
import android.telephony.CellInfoWcdma;
import android.telephony.CellSignalStrength;
import android.telephony.CellSignalStrengthCdma;
import android.telephony.CellSignalStrengthGsm;
import android.telephony.CellSignalStrengthLte;
import android.telephony.TelephonyManager;
import org.json.JSONObject;


/**
 * Created by bearluo on 2017/6/8.
 */

public class Function {
    public static JSONObject getLoginCommentData(JSONObject jsonObject, Activity activity) {

//        phone = params.phone,
//                device_no = params.device_no,
//                devicename = params.devicename,
//                imsi = params.imsi,
//                imei = params.imei,
//                macid = params.macid,
//                pixel = params.pixel,
//                nettype = params.nettype,
//                osversion = params.osversion,
        TelephonyManager tm =(TelephonyManager) activity.getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
        String phone = tm.getLine1Number();
        String devicename = Build.PRODUCT;
        return jsonObject;
    }
    /*
    充电状态值
    int BATTERY_STATUS_CHARGING = 2	充电中
    int BATTERY_STATUS_DISCHARGING = 3	放电中
    int BATTERY_STATUS_NOT_CHARGING = 4	未充电
    int BATTERY_STATUS_FULL = 5	已充满
    int BATTERY_STATUS_UNKNOWN = 1	状态未知
    充电的方式
    int BATTERY_PLUGGED_AC = 1	使用充电器充电
    int BATTERY_PLUGGED_USB = 2	使用USB充电
    int BATTERY_PLUGGED_WIRELESS = 4	使用无线方式充电
     */

    public static int getBatterypercentage(Activity activity){
        JSONObject jsonObject = new JSONObject();
        IntentFilter filter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent batteryStatus = activity.registerReceiver(null, filter);
        int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1); //获取当前电量
        int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1); //电量的总刻度
//        int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, BatteryManager.BATTERY_STATUS_UNKNOWN);//当前的充电状态
//        int plug = batteryStatus.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);//当前的充电方式
        return (level*100)/scale;
    }

    /**
     *
     * @param activity
     * @return 0-4
     */
    public static int getWIFISignalStrength(Activity activity){
        WifiManager wifiManager = (WifiManager) activity.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo = wifiManager.getConnectionInfo();
        //获得信号强度值
        int numberOfLevels = 5;
        int level = WifiManager.calculateSignalLevel(wifiInfo.getRssi(), numberOfLevels);
        return level;
    }

    /**
     *
     * @param activity
     * @return 0-4
     */
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    public static int getTeleSignalStrength(Activity activity) {
        final Context context = activity.getApplicationContext();

        int level = 0;

        final TelephonyManager tm = (TelephonyManager) context.getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
        for (final CellInfo info : tm.getAllCellInfo()) {
            if (info instanceof CellInfoGsm) {
                final CellSignalStrengthGsm gsm = ((CellInfoGsm) info).getCellSignalStrength();
                level = gsm.getLevel();
            } else if (info instanceof CellInfoCdma) {
                final CellSignalStrengthCdma cdma = ((CellInfoCdma) info).getCellSignalStrength();
                level = cdma.getLevel();
            } else if (info instanceof CellInfoLte) {
                final CellSignalStrengthLte lte = ((CellInfoLte) info).getCellSignalStrength();
                level = lte.getLevel();
            } else if (info instanceof CellInfoWcdma) {
                final CellSignalStrength wcdma = ((CellInfoWcdma) info).getCellSignalStrength();
                level = wcdma.getLevel();
            }
        }
        return level;
    }

    /**
     * 获取当前的网络状态 ：没有网络-0：WIFI网络1：4G网络-4：3G网络-3：2G网络-2
     * 自定义
     *
     * @param context
     * @return
     */
    public static int getAPNType(Context context) {
        //结果返回值
        int netType = 0;
        //获取手机所有连接管理对象
        ConnectivityManager manager = (ConnectivityManager) context.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        //获取NetworkInfo对象
        NetworkInfo networkInfo = manager.getActiveNetworkInfo();
        //NetworkInfo对象为空 则代表没有网络
        if (networkInfo == null) {
            return netType;
        }
        //否则 NetworkInfo对象不为空 则获取该networkInfo的类型
        int nType = networkInfo.getType();
        if (nType == ConnectivityManager.TYPE_WIFI) {
            //WIFI
            netType = 1;
        } else if (nType == ConnectivityManager.TYPE_MOBILE) {
            int nSubType = networkInfo.getSubtype();
            TelephonyManager telephonyManager = (TelephonyManager) context.getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
            //3G   联通的3G为UMTS或HSDPA 电信的3G为EVDO
            if (nSubType == TelephonyManager.NETWORK_TYPE_LTE
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 4;
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_UMTS
                    || nSubType == TelephonyManager.NETWORK_TYPE_HSDPA
                    || nSubType == TelephonyManager.NETWORK_TYPE_EVDO_0
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 3;
                //2G 移动和联通的2G为GPRS或EGDE，电信的2G为CDMA
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_GPRS
                    || nSubType == TelephonyManager.NETWORK_TYPE_EDGE
                    || nSubType == TelephonyManager.NETWORK_TYPE_CDMA
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 2;
            } else {
                netType = 2;
            }
        }
        return netType;
    }

}
