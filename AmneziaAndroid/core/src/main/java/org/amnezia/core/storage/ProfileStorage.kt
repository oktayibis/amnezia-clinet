package org.amnezia.core.storage

import android.content.Context
import android.content.SharedPreferences
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.amnezia.core.models.ServerProfile

class ProfileStorage(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    @Synchronized
    fun loadProfiles(): List<ServerProfile> {
        val raw = prefs.getString(KEY_PROFILES, null) ?: return emptyList()
        return try {
            json.decodeFromString<List<ServerProfile>>(raw)
        } catch (e: Exception) {
            emptyList()
        }
    }

    @Synchronized
    fun saveProfiles(profiles: List<ServerProfile>) {
        val raw = json.encodeToString(profiles)
        prefs.edit().putString(KEY_PROFILES, raw).apply()
    }

    @Synchronized
    fun addProfile(profile: ServerProfile) {
        val existing = loadProfiles().toMutableList()
        existing.removeAll { it.id == profile.id }
        existing.add(0, profile)
        saveProfiles(existing)

        if (getSelectedProfileId() == null) {
            selectProfile(profile.id)
        }
    }

    @Synchronized
    fun updateProfile(profile: ServerProfile) {
        val existing = loadProfiles().toMutableList()
        val index = existing.indexOfFirst { it.id == profile.id }
        if (index != -1) {
            existing[index] = profile
            saveProfiles(existing)
        }
    }

    @Synchronized
    fun deleteProfile(id: String) {
        val existing = loadProfiles().toMutableList()
        existing.removeAll { it.id == id }
        saveProfiles(existing)

        if (getSelectedProfileId() == id) {
            selectProfile(existing.firstOrNull()?.id)
        }
    }

    @Synchronized
    fun getSelectedProfileId(): String? {
        return prefs.getString(KEY_SELECTED_ID, null)
    }

    @Synchronized
    fun selectProfile(id: String?) {
        if (id != null) {
            prefs.edit().putString(KEY_SELECTED_ID, id).apply()
        } else {
            prefs.edit().remove(KEY_SELECTED_ID).apply()
        }
    }

    @Synchronized
    fun selectedProfile(): ServerProfile? {
        val all = loadProfiles()
        if (all.isEmpty()) return null
        val selectedId = getSelectedProfileId() ?: return all.firstOrNull()
        return all.firstOrNull { it.id == selectedId } ?: all.firstOrNull()
    }

    companion object {
        private const val PREFS_NAME = "amnezia_profiles_prefs"
        private const val KEY_PROFILES = "amnezia_server_profiles"
        private const val KEY_SELECTED_ID = "amnezia_selected_profile_id"
    }
}
