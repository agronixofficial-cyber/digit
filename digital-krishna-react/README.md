<div align="center">
<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# Run and deploy your AI Studio app

This contains everything you need to run your app locally.

View your app in AI Studio: https://ai.studio/apps/drive/1w3vW6KCQcQgXAUTI5lchSraXvvR8iuTn

## Run Locally

**Prerequisites:**  Node.js


1. Install dependencies:
   `npm install`
2. Set the `GEMINI_API_KEY` in [.env.local](.env.local) to your Gemini API key
3. Run the app:
   `npm run dev`

## Build Android App

**Prerequisites:** Java, Android SDK

1. Install dependencies (if not already):
   `npm install`
2. Sync the Android project:
   `npx cap sync android`
3. Build the APK:
   `cd android && ./gradlew assembleDebug`
   (or open the `android` folder in Android Studio and run the app)
   
The APK will be located at `android/app/build/outputs/apk/debug/app-debug.apk`.
