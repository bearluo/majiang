package com.tianyou.cangzhoumajiang.wxapi;

import android.app.Activity;
import android.os.Bundle;

import com.tianyou.wechat.WechatHelper;

/**
 * Created by bearluo on 2017/8/3.
 */

public class WXEntryActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WechatHelper.getInstance().handleIntent(getIntent(),this);
    }
}
