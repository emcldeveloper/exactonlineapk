package com.exactonline.exactonline

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.d("FCM", "📩 Message received: ${remoteMessage.notification?.body}")
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("FCM", "🔑 New token: $token")
    }
}
