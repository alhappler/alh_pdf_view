package com.example.alh_pdf_view

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AlhPdfViewFactory constructor(_messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private val messenger: BinaryMessenger = _messenger

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<*, *>?
        return AlhPdfView(context, messenger = messenger, creationParams = creationParams, id = viewId)
    }

}
