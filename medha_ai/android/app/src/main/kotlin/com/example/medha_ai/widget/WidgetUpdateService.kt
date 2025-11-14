package com.example.medha_ai.widget

import android.app.PendingIntent
import android.app.Service
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import com.example.medha_ai.MainActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.*

class WidgetUpdateService : Service() {
    private val job = Job()
    private val serviceScope = CoroutineScope(Dispatchers.Main + job)
    
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground()
        startUpdateLoop()
        return START_STICKY
    }

    private fun startForeground() {
        val notification = NotificationCompat.Builder(this, "knowledge_bites")
            .setContentTitle("Knowledge Bites")
            .setContentText("Updating educational content...")
            .setSmallIcon(applicationContext.resources.getIdentifier("ic_launcher", "mipmap", packageName))
            .setOngoing(true)
            .build()
        
        startForeground(1, notification)
    }

    private fun startUpdateLoop() {
        serviceScope.launch {
            while (true) {
                updateWidget()
                delay(5 * 60 * 1000) // Update every 5 minutes
            }
        }
    }

    private fun updateWidget() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            ComponentName(this, KnowledgeBiteWidget::class.java)
        )

        // Update all widgets
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(
                packageName,
                resources.getIdentifier("knowledge_bite_widget", "layout", packageName)
            )
            
            // Set up the pending intent to open the app when clicked
            val intent = Intent(this, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                this, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val widgetContainerId = resources.getIdentifier("widget_container", "id", packageName)
            views.setOnClickPendingIntent(widgetContainerId, pendingIntent)
            
            // Get a new fact (in a real app, you'd fetch this from your data source)
            val fact = getRandomFact()
            val widgetContentId = resources.getIdentifier("widget_content", "id", packageName)
            views.setTextViewText(widgetContentId, fact)
            
            // Update the widget
            appWidgetManager.partiallyUpdateAppWidget(appWidgetId, views)
        }
    }

    private fun getRandomFact(): String {
        val facts = listOf(
            "Did you know? Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still perfectly good to eat!",
            "A group of flamingos is called a 'flamboyance'. Now that's a fancy party!",
            "Octopuses have three hearts, nine brains, and blue blood. Two hearts pump blood to the gills, while the third pumps it to the rest of the body.",
            "The shortest war in history was between Britain and Zanzibar on August 27, 1896. Zanzibar surrendered after 38 minutes!",
            "A day on Venus is longer than a year on Venus. It takes Venus longer to rotate once on its axis than to complete one orbit around the Sun!"
        )
        return facts.random()
    }

    override fun onDestroy() {
        super.onDestroy()
        job.cancel()
    }
}
