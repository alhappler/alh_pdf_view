package com.example.alh_pdf_view.model

import com.github.barteksc.pdfviewer.util.FitPolicy

class AlhPdfViewConfiguration(
    val filePath: String?,
    val bytes: ByteArray?,
    val autoSpacing: Boolean,
    val enableSwipe: Boolean,
    val fitEachPage: Boolean,
    val swipeHorizontal: Boolean,
    val password: String,
    val nightMode: Boolean,
    val pageFling: Boolean,
    val pageSnap: Boolean,
    val defaultPage: Int,
    val defaultZoomFactor: Double,
    val fitPolicy: FitPolicy,
    val backgroundColor: Int,
    val enableDoubleTap: Boolean,
    val minZoom: Float,
    val maxZoom: Float,
    val enableDefaultScrollHandle: Boolean
) {
    companion object {
        fun fromArguments(map: Map<*, *>): AlhPdfViewConfiguration {
            val filePath: String? = map["filePath"] as String?
            val bytes: ByteArray? = map["bytes"] as ByteArray?
            val autoSpacing: Boolean = map["autoSpacing"] as Boolean
            val enableSwipe: Boolean = map["enableSwipe"] as Boolean
            val fitEachPage: Boolean = map["fitEachPage"] as Boolean
            val swipeHorizontal: Boolean = map["swipeHorizontal"] as Boolean
            val password: String = map["password"] as String
            val nightMode: Boolean = map["nightMode"] as Boolean
            val pageFling: Boolean = map["pageFling"] as Boolean
            val pageSnap: Boolean = map["pageSnap"] as Boolean
            val defaultPage: Int = map["defaultPage"] as Int
            val defaultZoomFactor: Double = map["defaultZoomFactor"] as Double
            val fitPolicy: FitPolicy = fitPolicyFrom(map["fitPolicy"] as String)
            val backgroundColor: Int =
                if (map["backgroundColor"] is Int) (map["backgroundColor"] as Int) else (map["backgroundColor"] as Long).toInt()
            val enableDoubleTap = map["enableDoubleTap"] as Boolean
            val minZoom = map["minZoom"] as Double
            val maxZoom = map["maxZoom"] as Double
            val enableDefaultScrollHandle = map["enableDefaultScrollHandle"] as Boolean

            return AlhPdfViewConfiguration(
                filePath,
                bytes,
                autoSpacing,
                enableSwipe,
                fitEachPage,
                swipeHorizontal,
                password,
                nightMode,
                pageFling,
                pageSnap,
                defaultPage,
                defaultZoomFactor,
                fitPolicy,
                backgroundColor,
                enableDoubleTap,
                minZoom.toFloat(),
                maxZoom.toFloat(),
                enableDefaultScrollHandle
            )
        }

        /**
         * Looking for the correct [FitPolicy] depending on the value.
         *
         * Returns the default value [FitPolicy.BOTH] if no matching [String] was found.
         */
        private fun fitPolicyFrom(value: String): FitPolicy {
            return when (value) {
                "FitPolicy.width" -> FitPolicy.WIDTH
                "FitPolicy.height" -> FitPolicy.HEIGHT
                else -> FitPolicy.BOTH
            }
        }
    }
}