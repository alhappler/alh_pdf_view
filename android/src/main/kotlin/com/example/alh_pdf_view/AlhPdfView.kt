package com.example.alh_pdf_view

import android.content.Context
import android.view.View
import androidx.annotation.NonNull
import com.example.alh_pdf_view.model.AlhPdfViewConfiguration
import com.github.barteksc.pdfviewer.PDFView
import com.github.barteksc.pdfviewer.util.Constants
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File


/** AlhPdfViewerPlugin */
internal class AlhPdfView(
    context: Context,
    id: Int,
    messenger: BinaryMessenger,
    creationParams: Map<*, *>?
) : MethodChannel.MethodCallHandler, PlatformView {
    lateinit var configuration: AlhPdfViewConfiguration
    private var pdfView: PDFView = PDFView(context, null) // view.findViewById(R.id.pdfView)
    private var channel: MethodChannel = MethodChannel(messenger, "alh_pdf_view_$id")

    init {
        channel.setMethodCallHandler(this)

        if (creationParams != null) {
            configuration = AlhPdfViewConfiguration.fromArguments(creationParams)

            Constants.PRELOAD_OFFSET = 3
            Constants.PART_SIZE = 600f // to fix bluriness after zooming

            val pdfViewConfigurator = if (configuration.filePath != null) {
                pdfView.fromFile(File(configuration.filePath!!))
            } else {
                pdfView.fromBytes(configuration.bytes)
            }

            pdfView.setBackgroundColor(configuration.backgroundColor)

            pdfViewConfigurator
                .enableAnnotationRendering(true)
                .enableSwipe(configuration.enableSwipe)
                .pageFitPolicy(configuration.fitPolicy)
                .fitEachPage(configuration.fitEachPage)
                .swipeHorizontal(configuration.swipeHorizontal)
                .password(configuration.password)
                .nightMode(configuration.nightMode)
                .autoSpacing(configuration.autoSpacing)
                .pageFling(configuration.pageFling)
                .pageSnap(configuration.pageSnap)
                .enableDoubletap(configuration.enableDoubleTap)
                .defaultPage(configuration.defaultPage)
                .onPageChange { page, total ->
                    val args: MutableMap<String, Any> = HashMap()
                    args["page"] = page
                    args["total"] = total
                    channel.invokeMethod("onPageChanged", args)
                }
                .onError { throwable ->
                    val args: MutableMap<String, Any> = HashMap()
                    args["error"] = throwable.toString()
                    channel.invokeMethod("onError", args)
                }
                .onPageError { page, throwable ->
                    val args: MutableMap<String, Any> = HashMap()
                    args["page"] = page
                    args["error"] = throwable.toString()
                    channel.invokeMethod("onPageError", args)
                }
                .onRender { pages ->
                    if (configuration.defaultZoomFactor > 0) {
                        pdfView.zoomWithAnimation(configuration.defaultZoomFactor.toFloat())
                    }
                    val args: MutableMap<String, Any> = HashMap()
                    args["pages"] = pages
                    channel.invokeMethod("onRender", args)
                }
                .load()
        }
    }

    override fun getView(): View {
        return pdfView
    }

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "pageCount" -> getPageCount(result)
            "currentPage" -> getCurrentPage(result)
            "setPage" -> setPage(call, result, false)
            "setPageWithAnimation" -> setPage(call, result, true)
            "pageWidth" -> getPageWidth(result)
            "pageHeight" -> getPageHeight(result)
            "resetZoom" -> resetZoom(result)
            "setZoom" -> setZoom(call, result)
            "currentZoom" -> getZoom(result)
            else -> result.notImplemented()
        }
    }

    private fun getPageWidth(result: MethodChannel.Result) {
        val width = pdfView.width * pdfView.zoom
        result.success(width)
    }

    private fun getPageHeight(result: MethodChannel.Result) {
        val height = pdfView.height * pdfView.zoom
        result.success(height)
    }

    private fun getPageCount(result: MethodChannel.Result) {
        result.success(pdfView.pageCount)
    }

    private fun getCurrentPage(result: MethodChannel.Result) {
        result.success(pdfView.currentPage)
    }

    private fun setPage(call: MethodCall, result: MethodChannel.Result, withAnimation: Boolean) {
        val page = call.argument<Any>("page") as Int
        pdfView.jumpTo(page, withAnimation)
        result.success(true)
    }

    private fun resetZoom(result: MethodChannel.Result) {
        val newZoom = configuration.defaultZoomFactor.toFloat()
        pdfView.zoomWithAnimation(newZoom)
        result.success(true)
        channel.invokeMethod("onZoomChanged", mapOf("zoom" to newZoom))
    }

    private fun setZoom(call: MethodCall, result: MethodChannel.Result) {
        val zoom = call.argument<Any>("newZoom") as Double
        pdfView.zoomWithAnimation(zoom.toFloat())
        result.success(null);
        // using as callback to have the same logic as iOS when updating zoom
        channel.invokeMethod("onZoomChanged", mapOf("zoom" to zoom))
    }

    private fun getZoom(result: MethodChannel.Result) {
        val zoom = pdfView.zoom.toDouble()
        result.success(zoom)
    }
}
