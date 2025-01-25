-keep class com.razorpay.** { *; }
-keepclassmembers class * {
    @proguard.annotation.Keep <methods>;
}
-dontwarn com.razorpay.**
