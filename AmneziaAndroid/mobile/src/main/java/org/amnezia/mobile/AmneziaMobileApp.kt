package org.amnezia.mobile

import android.app.Application
import org.amnezia.mobile.viewmodel.MobileAppState

class AmneziaMobileApp : Application() {
    lateinit var appState: MobileAppState
        private set

    override fun onCreate() {
        super.onCreate()
        instance = this
        appState = MobileAppState(this)
    }

    companion object {
        lateinit var instance: AmneziaMobileApp
            private set
    }
}
