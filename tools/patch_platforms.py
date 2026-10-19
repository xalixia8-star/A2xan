#!/usr/bin/env python3
"""Menerapkan konfigurasi Vaulte ke folder android/ dan ios/ hasil `flutter create`.

Idempoten: aman dijalankan berulang kali. Mendukung build.gradle.kts maupun
build.gradle (Groovy).
"""
import pathlib
import plistlib
import re
import shutil
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
ANDROID = ROOT / "android"
IOS = ROOT / "ios"
PLATFORM = ROOT / "platform"


def read(p):
    return p.read_text(encoding="utf-8")


def write(p, s):
    p.write_text(s, encoding="utf-8")


# ----------------------------------------------------------------- Android

def patch_manifest():
    p = ANDROID / "app/src/main/AndroidManifest.xml"
    s = read(p)
    if "USE_BIOMETRIC" not in s:
        s = s.replace(
            "<application",
            '<uses-permission android:name="android.permission.USE_BIOMETRIC"/>\n'
            "    <application",
            1,
        )
    # Tanpa backup cloud (data terenkripsi tetap tidak boleh ikut ter-backup).
    if "android:allowBackup" not in s:
        s = s.replace("<application", '<application android:allowBackup="false"', 1)
    if "EnableImpeller" not in s:
        s = s.replace(
            "</application>",
            '    <meta-data android:name="io.flutter.embedding.android.EnableImpeller"'
            ' android:value="true"/>\n    </application>',
            1,
        )
    # Aplikasi ini tidak memakai internet: pastikan tidak ada izin INTERNET.
    s = re.sub(r'\s*<uses-permission android:name="android.permission.INTERNET"\s*/>', "", s)
    write(p, s)


def patch_main_activity():
    kotlin_root = ANDROID / "app/src/main/kotlin"
    for old in kotlin_root.rglob("MainActivity.*"):
        old.unlink()
    target = kotlin_root / "com/vaulte/vaulte"
    target.mkdir(parents=True, exist_ok=True)
    shutil.copy(PLATFORM / "android/MainActivity.kt", target / "MainActivity.kt")
    # Hapus java/ lama bila ada.
    java_root = ANDROID / "app/src/main/java"
    if java_root.exists():
        for old in java_root.rglob("MainActivity.*"):
            old.unlink()


def patch_styles():
    # local_auth butuh tema AppCompat.
    for p in (ANDROID / "app/src/main/res").glob("values*/styles.xml"):
        s = read(p)
        s2 = re.sub(
            r'parent="@android:style/Theme\.(Light|Black|DeviceDefault)[A-Za-z.]*"',
            'parent="Theme.AppCompat.DayNight.NoActionBar"',
            s,
        )
        if s2 != s:
            write(p, s2)
    for p in (ANDROID / "app/src/main/res").glob("drawable*/launch_background.xml"):
        shutil.copy(PLATFORM / "android/launch_background.xml", p)


def insert_after_plugins(src, header, imports=""):
    """Sisipkan header setelah blok plugins {} (wajib paling atas di Gradle)."""
    m = re.search(r"^plugins\s*\{.*?^\}\s*\n", src, flags=re.S | re.M)
    if not m:
        sys.exit("blok plugins {} tidak ditemukan di build.gradle")
    return imports + src[: m.end()] + "\n" + header + src[m.end():]


def patch_gradle():
    kts = ANDROID / "app/build.gradle.kts"
    groovy = ANDROID / "app/build.gradle"
    if kts.exists():
        patch_gradle_kts(kts)
    elif groovy.exists():
        patch_gradle_groovy(groovy)
    else:
        sys.exit("build.gradle(.kts) tidak ditemukan")
    patch_proguard_and_props()


def patch_proguard_and_props():
    props = ANDROID / "gradle.properties"
    s = read(props) if props.exists() else ""
    if "android.enableR8.fullMode" not in s:
        s += "\nandroid.enableR8.fullMode=true\n"
        write(props, s)


def patch_gradle_kts(p):
    s = read(p)
    if "vaulteSigning" in s:
        return
    s = s.replace("flutter.minSdkVersion", "23")
    imports = "import java.util.Properties\nimport java.io.FileInputStream\n\n"
    header = '''// vaulteSigning: baca key.properties bila ada (dibuat oleh CI dari GitHub Secrets).
val keyProps = Properties()
val keyPropsFile = rootProject.file("key.properties")
val hasReleaseKey = keyPropsFile.exists()
if (hasReleaseKey) keyProps.load(FileInputStream(keyPropsFile))

'''
    s = insert_after_plugins(s, header, imports)
    signing = '''    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keyProps["keyAlias"] as String
                keyPassword = keyProps["keyPassword"] as String
                storeFile = file(keyProps["storeFile"] as String)
                storePassword = keyProps["storePassword"] as String
            }
        }
    }

'''
    s = s.replace("    buildTypes {", signing + "    buildTypes {", 1)
    s = re.sub(
        r"signingConfig\s*=\s*signingConfigs\.getByName\(\"debug\"\)",
        'signingConfig = if (hasReleaseKey) signingConfigs.getByName("release") '
        'else signingConfigs.getByName("debug")',
        s,
    )
    write(p, s)


def patch_gradle_groovy(p):
    s = read(p)
    if "vaulteSigning" in s:
        return
    s = s.replace("flutter.minSdkVersion", "23")
    header = '''// vaulteSigning
def keyProps = new Properties()
def keyPropsFile = rootProject.file("key.properties")
def hasReleaseKey = keyPropsFile.exists()
if (hasReleaseKey) { keyProps.load(new FileInputStream(keyPropsFile)) }

'''
    s = insert_after_plugins(s, header)
    signing = '''    signingConfigs {
        if (hasReleaseKey) {
            release {
                keyAlias keyProps["keyAlias"]
                keyPassword keyProps["keyPassword"]
                storeFile file(keyProps["storeFile"])
                storePassword keyProps["storePassword"]
            }
        }
    }

'''
    s = s.replace("    buildTypes {", signing + "    buildTypes {", 1)
    s = re.sub(
        r"signingConfig\s+signingConfigs\.debug",
        "signingConfig hasReleaseKey ? signingConfigs.release : signingConfigs.debug",
        s,
    )
    write(p, s)


# --------------------------------------------------------------------- iOS

def patch_ios():
    p = IOS / "Runner/Info.plist"
    with open(p, "rb") as f:
        d = plistlib.load(f)
    d["CADisableMinimumFrameDurationOnPhone"] = True  # ProMotion 120 Hz
    d["NSFaceIDUsageDescription"] = (
        "Vaulte memakai Face ID untuk membuka vault Anda dengan cepat dan aman."
    )
    d["FLTEnableImpeller"] = True
    d["UIUserInterfaceStyle"] = "Dark"
    d["CFBundleDisplayName"] = "Vaulte"
    d["ITSAppUsesNonExemptEncryption"] = False
    with open(p, "wb") as f:
        plistlib.dump(d, f)

    pod = IOS / "Podfile"
    if pod.exists():
        s = read(pod)
        s = re.sub(r"^#\s*platform :ios, '[0-9.]+'", "platform :ios, '13.0'", s, flags=re.M)
        if not re.search(r"^platform :ios", s, flags=re.M):
            s = "platform :ios, '13.0'\n" + s
        write(pod, s)


def patch_android_label():
    p = ANDROID / "app/src/main/AndroidManifest.xml"
    s = read(p)
    s = re.sub(r'android:label="[^"]*"', 'android:label="Vaulte"', s, count=1)
    write(p, s)


if __name__ == "__main__":
    if not ANDROID.exists() or not IOS.exists():
        sys.exit("Jalankan `flutter create` dulu (lihat tools/bootstrap.sh).")
    patch_manifest()
    patch_android_label()
    patch_main_activity()
    patch_styles()
    patch_gradle()
    patch_ios()
    print("Platform dipatch.")
