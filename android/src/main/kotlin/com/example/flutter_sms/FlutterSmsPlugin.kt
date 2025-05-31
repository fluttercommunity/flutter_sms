package com.example.flutter_sms

import android.annotation.TargetApi
import android.app.Activity
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.telephony.SmsManager
import android.telephony.TelephonyManager
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
// import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterSmsPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
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
                    "A device may be unable to send messages if it does not support messaging or if it is not currently configured to send messages. This only applies to the ability to send text messages via iMessage, SMS, and MMS.")
            return
          }
          val message = call.argument<String?>("message") ?: ""
          val recipients = call.argument<String?>("recipients") ?: ""
          val sendDirect = call.argument<Boolean?>("sendDirect") ?: false
          sendSMS(result, recipients, message!!, sendDirect)
        }
        "canSendSMS" -> result.success(canSendSMS())
        else -> result.notImplemented()
    }
  }

  @TargetApi(Build.VERSION_CODES.ECLAIR)
  private fun canSendSMS(): Boolean {
    return try {
      // Check if we can create an SMS intent
      val intent = Intent(Intent.ACTION_SENDTO)
      intent.data = Uri.parse("smsto:")
      val activityInfo = intent.resolveActivityInfo(activity!!.packageManager, intent.flags.toInt())
      
      // If we can resolve the SMS intent, we can send SMS
      if (activityInfo != null && activityInfo.exported) {
        return true
      }
      
      // Alternative check: try to get SmsManager
      try {
        val smsManager = SmsManager.getDefault()
        // If we can get SmsManager without exception, we can likely send SMS
        return true
      } catch (e: SecurityException) {
        Log.w("FlutterSms", "SecurityException when checking SmsManager: ${e.message}")
        return false
      } catch (e: Exception) {
        Log.w("FlutterSms", "Exception when checking SmsManager: ${e.message}")
        return false
      }
    } catch (e: Exception) {
      Log.e("FlutterSms", "Error checking SMS capability: ${e.message}")
      false
    }
  }

  private fun sendSMS(result: Result, phones: String, message: String, sendDirect: Boolean) {
    if (sendDirect) {
      sendSMSDirect(result, phones, message);
    }
    else {
      sendSMSDialog(result, phones, message);
    }
  }

  // private fun sendSMSDirect(result: Result, phones: String, message: String) {
  //   try {
  //     // SmsManager is android.telephony
  //     val sentIntent = PendingIntent.getBroadcast(activity, 0, Intent("SMS_SENT_ACTION"), PendingIntent.FLAG_IMMUTABLE)
  //     val mSmsManager = SmsManager.getDefault()
  //     val numbers = phones.split(";")

  //     for (num in numbers) {
  //       Log.d("Flutter SMS", "msg.length() : " + message.toByteArray().size)
  //       if (message.toByteArray().size > 80) {
  //         val partMessage = mSmsManager.divideMessage(message)
  //         mSmsManager.sendMultipartTextMessage(num, null, partMessage, null, null)
  //       } else {
  //         mSmsManager.sendTextMessage(num, null, message, sentIntent, null)
  //       }
  //     }

  //     result.success("SMS Sent!")
  //   } catch (e: SecurityException) {
  //     result.error("permission_denied", "SMS permission denied: ${e.message}", null)
  //   } catch (e: Exception) {
  //     result.error("send_failed", "Failed to send SMS: ${e.message}", null)
  //   }
  // }

private fun sendSMSDirect(result: Result, phones: String, message: String) {
    try {
        // Create PendingIntent with FLAG_IMMUTABLE for Android 12+ compatibility
        val sentIntent = PendingIntent.getBroadcast(
            activity, 
            0, 
            Intent("SMS_SENT_ACTION"), 
            PendingIntent.FLAG_IMMUTABLE
        )
        
        val smsManager = SmsManager.getDefault()
        val numbers = phones.split(";")
        
        for (num in numbers) {
            val trimmedNum = num.trim()
            if (trimmedNum.isEmpty()) continue
            
            Log.d("Flutter SMS", "Message length (bytes): ${message.toByteArray().size}")
            
            // Use more accurate SMS length calculation (160 chars for GSM 7-bit)
            if (message.length > 160 || message.toByteArray().size > 160) {
                val partMessages = smsManager.divideMessage(message)
                
                // Create sent and delivery intents for multipart messages
                val sentIntents = arrayListOf<PendingIntent>()
                val deliveryIntents = arrayListOf<PendingIntent>()
                
                repeat(partMessages.size) { index ->
                    sentIntents.add(
                        PendingIntent.getBroadcast(
                            activity,
                            index,
                            Intent("SMS_SENT_ACTION"),
                            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                        )
                    )
                }
                
                smsManager.sendMultipartTextMessage(
                    trimmedNum,
                    null,
                    partMessages,
                    sentIntents,
                    deliveryIntents.takeIf { it.isNotEmpty() }
                )
            } else {
                smsManager.sendTextMessage(
                    trimmedNum,
                    null,
                    message,
                    sentIntent,
                    null
                )
            }
        }
        
        result.success("SMS Sent!")
        
    } catch (e: SecurityException) {
        Log.e("Flutter SMS", "Security exception: ${e.message}")
        result.error("permission_denied", "SMS permission denied: ${e.message}", null)
    } catch (e: IllegalArgumentException) {
        Log.e("Flutter SMS", "Invalid argument: ${e.message}")
        result.error("invalid_argument", "Invalid SMS parameters: ${e.message}", null)
    } catch (e: Exception) {
        Log.e("Flutter SMS", "SMS send failed: ${e.message}")
        result.error("send_failed", "Failed to send SMS: ${e.message}", null)
    }
}

  private fun sendSMSDialog(result: Result, phones: String, message: String) {
    try {
      val intent = Intent(Intent.ACTION_SENDTO)
      intent.data = Uri.parse("smsto:$phones")
      intent.putExtra("sms_body", message)
      intent.putExtra(Intent.EXTRA_TEXT, message)
      activity?.startActivityForResult(intent, REQUEST_CODE_SEND_SMS)
      result.success("SMS Sent!")
    } catch (e: Exception) {
      result.error("intent_failed", "Failed to open SMS app: ${e.message}", null)
    }
  }
}