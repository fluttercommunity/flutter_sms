package com.example.flutter_sms

import android.annotation.TargetApi
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.telephony.SmsManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterSmsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  // V1 embedding entry point. This is deprecated and will be removed in a future Flutter
  // release but we leave it here in case someone's app does not utilize the V2 embedding yet.
  companion object {
    private const val SENT_INTENT_ACTION = "SMS_SENT_ACTION"

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val inst = FlutterSmsPlugin()
      inst.activity = registrar.activity()
      inst.setupCallbackChannels(registrar.messenger())
    }
  }

  private lateinit var mChannel: MethodChannel
  private var activity: Activity? = null
  private val REQUEST_CODE_SEND_SMS = 205

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    setupCallbackChannels(flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    teardown()
  }

  private fun setupCallbackChannels(messenger: BinaryMessenger) {
    mChannel = MethodChannel(messenger, "flutter_sms")
    mChannel.setMethodCallHandler(this)
  }

  private fun teardown() {
    mChannel.setMethodCallHandler(null)
  }


  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "sendSMS" -> {
        if (!canSendSMS()) {
          result.error(
            "device_not_capable",
            "The current device is not capable of sending text messages.",
            "A device may be unable to send messages if it does not support messaging or if it is not currently configured to send messages. This only applies to the ability to send text messages via iMessage, SMS, and MMS.",
          )
          return
        }
        val message = call.argument<String?>("message") ?: ""
        val recipients = call.argument<String?>("recipients") ?: ""
        val sendDirect = call.argument<Boolean?>("sendDirect") ?: false

        if (!sendDirect && !canSendSMSViaApp()) {
          result.error(
            "app_to_send_sms_not_available",
            "The current device has not an app to send sms.",
            "To send a non direct sms, an sms application is required",
          )
          return
        }
        sendSMS(result, recipients, message!!, sendDirect)
      }
      "canSendSMS" -> result.success(canSendSMS())
      else -> result.notImplemented()
    }
  }

  @TargetApi(Build.VERSION_CODES.ECLAIR)
  private fun canSendSMS(): Boolean =
    activity!!.packageManager.hasSystemFeature(PackageManager.FEATURE_TELEPHONY)

  @TargetApi(Build.VERSION_CODES.ECLAIR)
  private fun canSendSMSViaApp(): Boolean {
    val intent = Intent(Intent.ACTION_SENDTO)
    intent.data = Uri.parse("smsto:")
    val activityInfo =
      intent.resolveActivityInfo(activity!!.packageManager, intent.flags.toInt())
    return canSendSMS() && !(activityInfo == null || !activityInfo.exported)
  }

  private fun sendSMS(result: Result, phones: String, message: String, sendDirect: Boolean) {
    if (sendDirect) {
      sendSMSDirect(result, phones, message);
    } else {
      sendSMSDialog(result, phones, message);
    }
  }

  private fun sendSMSDirect(result: Result, phones: String, message: String) {
    // SmsManager is android.telephony
    val sentIntent = PendingIntent.getBroadcast(
      activity,
      0,
      Intent(SENT_INTENT_ACTION),
      PendingIntent.FLAG_IMMUTABLE
    )

    activity?.registerReceiver(object : BroadcastReceiver() {
      override fun onReceive(context: Context, intent: Intent) {
        activity?.unregisterReceiver(this)
        when (resultCode) {
          Activity.RESULT_OK -> result.success("SMS Sent!")
          else -> result.error(
            "sent_sms_error",
            "Error sending the sms",
            "Error code $resultCode"
          )
        }
      }
    }, IntentFilter(SENT_INTENT_ACTION))

    val mSmsManager = SmsManager.getDefault()
    val numbers = phones.split(";")

    for (num in numbers) {
      Log.d("Flutter SMS", "msg.length() : " + message.toByteArray().size)
      if (message.toByteArray().size > 80) {
        val partMessage = mSmsManager.divideMessage(message)
        mSmsManager.sendMultipartTextMessage(num, null, partMessage, null, null)
      } else {
        mSmsManager.sendTextMessage(num, null, message, sentIntent, null)
      }
    }
  }

  private fun sendSMSDialog(result: Result, phones: String, message: String) {
    val intent = Intent(Intent.ACTION_SENDTO)
    intent.data = Uri.parse("smsto:$phones")
    intent.putExtra("sms_body", message)
    intent.putExtra(Intent.EXTRA_TEXT, message)
    activity?.startActivityForResult(intent, REQUEST_CODE_SEND_SMS)
    result.success("SMS Sent!")
  }
}
