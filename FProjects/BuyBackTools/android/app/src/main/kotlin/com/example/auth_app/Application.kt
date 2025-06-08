package com.example.auth_app

import android.app.Application
import android.util.Log

class Application : Application() {
    override fun onCreate() {
        try {
            super.onCreate()
            // Initialize any required services here
        } catch (e: Exception) {
            Log.e("Application", "Error in onCreate: ${e.message}", e)
        }
    }
} 