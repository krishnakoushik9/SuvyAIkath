package com.example.medha_ai.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.medha_ai.MainActivity
// R class will be generated during build

class KnowledgeBiteWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Start the service to update the widget periodically
        val intent = Intent(context, WidgetUpdateService::class.java)
        context.startService(intent)
    }

    override fun onDisabled(context: Context) {
        // Stop the service when the last widget is removed
        val intent = Intent(context, WidgetUpdateService::class.java)
        context.stopService(intent)
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(
                context.packageName,
                context.resources.getIdentifier("knowledge_bite_widget", "layout", context.packageName)
            )
            
            // Set up the pending intent to open the app when clicked
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val widgetContainerId = context.resources.getIdentifier("widget_container", "id", context.packageName)
            views.setOnClickPendingIntent(widgetContainerId, pendingIntent)
            
            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
            
            // Trigger an update
            updateWidgetContent(context)
        }
        
        fun updateWidgetContent(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, KnowledgeBiteWidget::class.java)
            )
            
            for (appWidgetId in appWidgetIds) {
                val views = RemoteViews(
                context.packageName,
                context.resources.getIdentifier("knowledge_bite_widget", "layout", context.packageName)
            )
                
                // Set up the pending intent to open the app when clicked
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                val widgetContainerId = context.resources.getIdentifier("widget_container", "id", context.packageName)
            views.setOnClickPendingIntent(widgetContainerId, pendingIntent)
                
                // Update the widget
                appWidgetManager.partiallyUpdateAppWidget(appWidgetId, views)
            }
        }
    }
}
