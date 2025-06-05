import com.google.android.play.core.splitcompat.SplitCompat

override fun attachBaseContext(base: Context) {
    super.attachBaseContext(base)
    SplitCompat.install(this)
} 