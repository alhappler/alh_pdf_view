#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint alh_pdf_view_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'alh_pdf_view_ios'
  s.version          = '2.4.0'
  s.summary          = 'A Flutter plugin to display PDF files on iOS.'
  s.description      = <<-DESC
A Flutter plugin to display PDF files on iOS using the native PDFKit framework.
                       DESC
  s.homepage         = 'https://github.com/alhappler/alh_pdf_view'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'alhappler' => 'email@example.com' }
  s.source           = { :git => 'https://github.com/alhappler/alh_pdf_view.git', :tag => s.version.to_s }
  s.source_files = 'alh_pdf_view_ios/Sources/alh_pdf_view_ios/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
