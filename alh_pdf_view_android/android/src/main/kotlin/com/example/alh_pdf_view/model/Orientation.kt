package com.example.alh_pdf_view.model

enum class Orientation {
    PORTRAIT,
    LANDSCAPE;

    companion object {
        fun fromString(value: String?): Orientation? {
            return when (value) {
                "Orientation.portrait" -> PORTRAIT
                "Orientation.landscape" -> LANDSCAPE
                else -> null
            }
        }
    }
}