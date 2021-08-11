package io.ghyeok.channel.flutter

import android.content.Context
import com.zoyi.channel.plugin.android.ChannelPluginListener
import com.zoyi.channel.plugin.android.model.etc.PushEvent
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class EventHandler(private val context: Context) : EventChannel.StreamHandler , ChannelPluginListener {

//    private var event : EventChannel.EventSink? = null;
//    private var count :  Int = 0;

    override fun onListen(p0: Any?, _event: EventChannel.EventSink) {
        ChannelPlugin.event = _event;
        ChannelPlugin.event?.success(ChannelPlugin.count);
    }

    override fun onCancel(p0: Any) {
        ChannelPlugin.event = null
    }

    override fun onChangeBadge(_count: Int) {
        ChannelPlugin.count = _count;
        if( ChannelPlugin.event !=null)
            ChannelPlugin.event?.success(_count);
    }

    override fun willShowMessenger() {}
    override fun willHideMessenger() {}
    override fun onReceivePush(pushEvent: PushEvent?) {}
    override fun onClickChatLink(url: String?): Boolean {return false}
    override fun onChangeProfile(key: String?,  value: Any?) {}
}