package com.example.alh_pdf_view

import android.content.Context
import android.view.View
import androidx.annotation.NonNull
import com.example.alh_pdf_view.model.AlhPdfViewConfiguration
import com.example.alh_pdf_view.model.Orientation
import com.github.barteksc.pdfviewer.PDFView
import com.github.barteksc.pdfviewer.util.Constants
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File


/** AlhPdfViewerPlugin */
internal class AlhPdfView(
    context: Context?,
    id: Int,
    messenger: BinaryMessenger,
    creationParams: Map<*, *>?
) : MethodChannel.MethodCallHandler, PlatformView {
    private var pdfView: PDFView = PDFView(context, null)

    // This channel is called by user actions, e. g. when to update the current page
    private var alhPdfViewChannel: MethodChannel = MethodChannel(messenger, "alh_pdf_view_$id")

    // This channel is only called inside the package and should not be used by the user, e. g. it handles updated configuration values
    private var alhPdfChannel: MethodChannel = MethodChannel(messenger, "alh_pdf_$id")

    private lateinit var lastOrientation: Orientation
    private lateinit var alhPdfViewConfiguration: AlhPdfViewConfiguration

    init {
        alhPdfViewChannel.setMethodCallHandler(this)
        alhPdfChannel.setMethodCallHandler(this)

        if (creationParams != null) {
            alhPdfViewConfiguration = AlhPdfViewConfiguration.fromArguments(creationParams)

            Constants.PRELOAD_OFFSET = 3
            Constants.PART_SIZE = 600f // to fix bluriness after zooming

            loadPdfView(alhPdfViewConfiguration.defaultPage)
        }
    }

    override fun getView(): View {
        return pdfView
    }

    override fun dispose() {
        alhPdfViewChannel.setMethodCallHandler(null)
        alhPdfChannel.setMethodCallHandler(null)
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
            "setOrientation" -> handleOrientationChange(call.arguments as Map<*, *>, result)
            else -> result.notImplemented()
        }
    }

    private fun loadPdfView(defaultPage: Int) {
        val pdfViewConfigurator = if (alhPdfViewConfiguration.filePath != null) {
            pdfView.fromFile(File(alhPdfViewConfiguration.filePath!!))
        } else {
            pdfView.fromBytes(alhPdfViewConfiguration.bytes)
        }

        pdfView.setBackgroundColor(alhPdfViewConfiguration.backgroundColor)
        pdfView.minZoom = alhPdfViewConfiguration.minZoom
        pdfView.maxZoom = alhPdfViewConfiguration.maxZoom

        pdfViewConfigurator
            .enableAnnotationRendering(true)
            .enableSwipe(alhPdfViewConfiguration.enableSwipe)
            .pageFitPolicy(alhPdfViewConfiguration.fitPolicy)
            .fitEachPage(alhPdfViewConfiguration.fitEachPage)
            .swipeHorizontal(alhPdfViewConfiguration.swipeHorizontal)
            .password(alhPdfViewConfiguration.password)
            .nightMode(alhPdfViewConfiguration.nightMode)
            .autoSpacing(alhPdfViewConfiguration.autoSpacing)
            .pageFling(alhPdfViewConfiguration.pageFling)
            .pageSnap(alhPdfViewConfiguration.pageSnap)
            .enableDoubletap(alhPdfViewConfiguration.enableDoubleTap)
            .defaultPage(defaultPage)
            .onPageChange { page, total ->
                val args: MutableMap<String, Any> = HashMap()
                args["page"] = page
                args["total"] = total
                alhPdfViewChannel.invokeMethod("onPageChanged", args)
            }
            .onError { throwable ->
                val args: MutableMap<String, Any> = HashMap()
                args["error"] = throwable.toString()
                alhPdfViewChannel.invokeMethod("onError", args)
            }
            .onPageError { page, throwable ->
                val args: MutableMap<String, Any> = HashMap()
                args["page"] = page
                args["error"] = throwable.toString()
                alhPdfViewChannel.invokeMethod("onPageError", args)
            }
            .onRender { pages ->
                if (alhPdfViewConfiguration.defaultZoomFactor > 0) {
                    pdfView.zoomWithAnimation(alhPdfViewConfiguration.defaultZoomFactor.toFloat())
                }
                val args: MutableMap<String, Any> = HashMap()
                args["pages"] = pages
                alhPdfViewChannel.invokeMethod("onRender", args)
            }
            .load()
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
        val newZoom = alhPdfViewConfiguration.defaultZoomFactor.toFloat()
        pdfView.zoomWithAnimation(newZoom)
        result.success(true)
    }

    private fun setZoom(call: MethodCall, result: MethodChannel.Result) {
        val zoom = call.argument<Any>("newZoom") as Double
        pdfView.zoomWithAnimation(zoom.toFloat())
        result.success(null)
    }

    private fun getZoom(result: MethodChannel.Result) {
        val zoom = pdfView.zoom.toDouble()
        result.success(zoom)
    }

    /**
     * Fixing the bug having a white screen when changing the orientation.
     *
     * This method reloads the PDF when the orientation changed.
     * The last page will still be shown but the current zoom value is reset.
     */
    private fun handleOrientationChange(arguments: Map<*, *>, result: MethodChannel.Result) {
        val newDeviceOrientation = Orientation.fromString(arguments["orientation"] as String)

        if (newDeviceOrientation != null) {
            if (this::lastOrientation.isInitialized && newDeviceOrientation != lastOrientation) {
                alhPdfViewConfiguration = AlhPdfViewConfiguration.fromArguments(arguments)
                loadPdfView(defaultPage = pdfView.currentPage)
            }
            lastOrientation = newDeviceOrientation
        }
        result.success(null)
    }
}
