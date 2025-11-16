# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules - keep everything
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Web3 specific rules - keep everything
-keep class org.web3j.** { *; }
-keep class org.web3dart.** { *; }
-keep class web3dart.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepnames class * implements java.io.Serializable

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# Keep annotations
-keepattributes *Annotation*

# Keep data for analytics to work
-keep class com.google.android.gms.analytics.** { *; }
-keep class com.google.android.gms.measurement.** { *; }

# Keep data for Firebase to work
-keep class com.google.firebase.** { *; }

# Keep data for Google Play Services
-keep class com.google.android.gms.** { *; }

# Keep data for AndroidX
-keep class androidx.** { *; }

# Keep data for Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }

# Keep data for HTTP client
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Keep data for JSON parsing
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }

# Keep data for image loading
-keep class com.bumptech.glide.** { *; }

# Keep data for video player
-keep class com.google.android.exoplayer2.** { *; }

# Keep data for camera
-keep class androidx.camera.** { *; }

# Keep data for shared preferences
-keep class android.content.SharedPreferences { *; }

# Keep data for secure storage
-keep class androidx.security.crypto.** { *; }

# Keep data for Hive
-keep class hive.** { *; }
-keep class com.hivedb.** { *; }

# Keep data for Logger
-keep class com.logger.** { *; }

# Keep data for Toast
-keep class android.widget.Toast { *; }

# Keep data for URL launcher
-keep class android.content.Intent { *; }

# Keep data for package info
-keep class android.content.pm.PackageInfo { *; }

# Keep data for device info
-keep class android.os.Build { *; }

# Keep data for notifications (if enabled)
#-keep class androidx.core.app.NotificationCompat { *; }
#-keep class android.app.Notification { *; }

# Keep data for HTML parsing
-keep class org.jsoup.** { *; }

# Keep data for drag and drop
-keep class androidx.recyclerview.widget.** { *; }

# Keep data for SVG
-keep class com.caverock.androidsvg.** { *; }

# Keep data for photo view
-keep class com.github.chrisbanes.photoview.** { *; }

# Keep data for shimmer
-keep class com.facebook.shimmer.** { *; }

# Keep data for staggered grid view
-keep class com.staggeredgridview.** { *; }

# Keep data for lottie
-keep class com.airbnb.lottie.** { *; }

# Keep data for animations
-keep class androidx.transition.** { *; }

# Keep data for cached network image
-keep class com.github.bumptech.glide.** { *; }

# Keep data for provider
-keep class androidx.lifecycle.** { *; }

# Keep data for riverpod
-keep class riverpod.** { *; }

# Keep data for go_router
-keep class go_router.** { *; }

# Keep data for dio
-keep class dio.** { *; }

# Keep data for retrofit
-keep class retrofit2.** { *; }

# Keep data for intl
-keep class intl.** { *; }

# Keep data for url_launcher
-keep class url_launcher.** { *; }

# Keep data for package_info_plus
-keep class package_info_plus.** { *; }

# Keep data for device_info_plus
-keep class device_info_plus.** { *; }

# Keep data for flutter_secure_storage
-keep class flutter_secure_storage.** { *; }

# Keep data for fluttertoast
-keep class fluttertoast.** { *; }

# Keep data for http
-keep class http.** { *; }

# Keep data for html
-keep class html.** { *; }

# Keep data for cupertino_icons
-keep class cupertino_icons.** { *; }

# Keep data for flutter_svg
-keep class flutter_svg.** { *; }

# Keep data for photo_view
-keep class photo_view.** { *; }

# Keep data for logger
-keep class logger.** { *; }

# Keep data for build_runner
-keep class build_runner.** { *; }

# Keep data for json_serializable
-keep class json_serializable.** { *; }

# Keep data for retrofit_generator
-keep class retrofit_generator.** { *; }

# Keep data for hive_generator
-keep class hive_generator.** { *; }
