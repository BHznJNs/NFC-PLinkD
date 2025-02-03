package org.nfc_plinkd.bhznjns

import android.media.MediaMetadataRetriever

class VideoMetadataHelper {
    /**
     * Get the rotation angle (in degree) for the given video
     *
     * @param videoPath
     * @return Rotation angle 0、90、180、270; returns 0 if error
     */
    fun getRotation(videoPath: String): Int {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(videoPath)
            val rotationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
            rotationString?.toInt() ?: 0
        } catch (e: Exception) {
            e.printStackTrace()
            0
        } finally {
            retriever.release()
        }
    }
}