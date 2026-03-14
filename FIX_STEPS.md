# ✅ Fix Steps — Run This First!

## The Problem
Gradle daemon crash caused by JVM memory flags incompatible with your Java version.

---

## Step 1 — Clean old Gradle cache (IMPORTANT)

Open **PowerShell as Administrator** and run:

```powershell
# Stop all Gradle daemons
cd C:\Users\Administrator\Downloads\pdf_master_pro_v3\pdf_master_v3
.\gradlew --stop 2>$null; true

# Delete broken Gradle 7.5 cache
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\wrapper\dists\gradle-7.5-all" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\wrapper\dists\gradle-7.6.3-all" -ErrorAction SilentlyContinue

# Clear Flutter build cache
flutter clean
```

---

## Step 2 — Get packages

```powershell
flutter pub get
```

---

## Step 3 — Run

```powershell
flutter run
```

Gradle 7.6.3 will download automatically (~100MB, one time only).

---

## If it still fails — Manual Gradle fix

Open this file in Notepad:
```
C:\Users\Administrator\.gradle\gradle.properties
```

Add this line (create the file if it doesn't exist):
```
org.gradle.jvmargs=-Xmx1536m -Dfile.encoding=UTF-8
org.gradle.daemon=false
```

Then run again:
```powershell
flutter run
```

---

## If you get "SDK location not found"

Create this file inside the `android` folder:
```
android\local.properties
```

With this content (adjust path to your Android SDK):
```
sdk.dir=C\:\\Users\\Administrator\\AppData\\Local\\Android\\Sdk
flutter.sdk=C\:\\flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

---

## Build APK (after flutter run works)

```powershell
flutter build apk --release
# APK is at: build\app\outputs\flutter-apk\app-release.apk
```
