package io.ghyeok.channel.flutter

import android.app.Application
import android.content.Context
import androidx.annotation.NonNull
import com.zoyi.channel.plugin.android.ChannelIO
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.EventChannel

/** FlutterChannelIoPlugin */
public class ChannelPlugin : FlutterPlugin, ActivityAware {

  private lateinit var channel: MethodChannel
  private lateinit var eventChannel: EventChannel

  private lateinit var handler: MethodCallHandlerImpl

  companion object {

    const val CHANNEL_NAME = "GwonHyeok/flutter_channel_io"
    const val EVENT_NAME = "GwonHyeok/flutter_channel_io_event"
    
    var event : EventChannel.EventSink? = null;
    var count :  Int = 0;
    
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channelPlugin = ChannelPlugin()
      channelPlugin.setupChannel(registrar.messenger(), registrar.context())
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    setupChannel(flutterPluginBinding.binaryMessenger, flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun setupChannel(messenger: BinaryMessenger, context: Context) {
    channel = MethodChannel(messenger, CHANNEL_NAME)
    handler = MethodCallHandlerImpl(context)
    channel.setMethodCallHandler(handler)

    val eventHandler = EventHandler(context);
    eventChannel = EventChannel(messenger, EVENT_NAME);
    eventChannel.setStreamHandler(eventHandler);

    // Initialize ChannelIO
    val application = context.applicationContext as Application
    ChannelIO.initialize(application)
    ChannelIO.setChannelPluginListener(eventHandler)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.handler.activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    this.handler.activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.handler.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.handler.activity = null
  }
}