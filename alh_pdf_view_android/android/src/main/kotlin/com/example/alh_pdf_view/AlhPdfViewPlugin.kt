package com.example.alh_pdf_view

import io.flutter.embedding.engine.plugins.FlutterPlugin

class AlhPdfViewPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding
                .platformViewRegistry
                .registerViewFactory("alh_pdf_view", AlhPdfViewFactory(binding.binaryMessenger))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}