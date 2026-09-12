package org.amnezia.tv

import android.app.Application
import org.amnezia.tv.viewmodel.TvAppState

class AmneziaTvApp : Application() {
    lateinit var appState: TvAppState
        private set

    override fun onCreate() {
        super.onCreate()
        instance = this
        appState = TvAppState(this)
    }

    companion object {
        lateinit var instance: AmneziaTvApp
            private set
    }
}
