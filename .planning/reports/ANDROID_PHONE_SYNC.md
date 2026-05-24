# Android Phone Sync Commands

This document contains the commands to copy app data from your phone to your laptop and to install/update the APK on the phone.

## 1) Verify the phone is connected

```bash
adb devices
```

Expected output should show your phone in `device` state.

## 2) Identify the package name of the app

Use a filter that matches your app name:

```bash
adb shell pm list packages | grep -i todo
```

or:

```bash
adb shell pm list packages | grep -i gsd
```

The package name will look like:

- `package:com.example.gsd_todo`
- `package:com.yourname.gsd_todo`

Use only the package portion after `package:` for later commands.

## 3) Copy app internal data from the phone to the laptop

### Recommended if the app is debuggable
Replace `<PACKAGE>` with your app package name.

```bash
adb shell run-as <PACKAGE> tar -czf /sdcard/app_data.tar.gz .
adb pull /sdcard/app_data.tar.gz ./phone_app_data.tar.gz
adb shell rm /sdcard/app_data.tar.gz
```

This creates a compressed archive of the app's internal data directory and pulls it to your laptop.

## 4) Copy app files from external app storage

If the app stores data under external storage, use:

```bash
adb pull /sdcard/Android/data/<PACKAGE>/files ./phone_app_data_files
```

If your app writes elsewhere in external storage, update the source path accordingly.

## 5) Verify access if `run-as` fails

```bash
adb shell run-as <PACKAGE> ls /data/data/<PACKAGE>
```

If this returns `Permission denied`, the app is not accessible via `run-as`. In that case, use external storage copy or reinstall a debuggable build.

## 6) Install or update the APK on the phone

After building the latest APK on your laptop, run:

```bash
adb install -r path/to/your_app.apk
```

Common options:

- `-r` : replace existing app
- `-g` : grant all runtime permissions
- `-d` : allow downgrade if the new APK has a lower version code

Example:

```bash
adb install -r ./GSDTodo_1.apk
```

## 7) If the install fails due to signature mismatch

```bash
adb uninstall <PACKAGE>
adb install ./GSDTodo_1.apk
```

This removes the existing app and installs the new build.

## 8) Optional: confirm the APK package name before install

```bash
aapt dump badging path/to/your_app.apk | grep package:
```

This is useful if you want to verify the package name inside the APK.

## 9) Quick workflow summary

1. `adb devices`
2. `adb shell pm list packages | grep -i todo`
3. `adb shell run-as <PACKAGE> tar -czf /sdcard/app_data.tar.gz .`
4. `adb pull /sdcard/app_data.tar.gz ./phone_app_data.tar.gz`
5. Build latest APK on laptop
6. `adb install -r ./GSDTodo_1.apk`

## 10) Discover desktop `user://` path in Godot

If you want to locate the exact desktop `user://` folder used by this Godot project, run this from the Godot project root.

If the `godot` command is not installed in your shell PATH, use the full Godot app executable path instead.

### If `godot` is available:

```bash
godot --path . --script - <<'EOF'
print(ProjectSettings.globalize_path("user://tasks/"))
EOF
```

### If `godot` is not on PATH (macOS fallback):

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path . --script - <<'EOF'
print(ProjectSettings.globalize_path("user://tasks/"))
EOF
```

If your `Godot.app` is installed in a different location, replace `/Applications/Godot.app/Contents/MacOS/Godot` with the actual path to the Godot binary.

That will print the absolute path where Godot resolves `user://tasks/` on your laptop.

## Notes

- `adb` is the main tool for phone-to-laptop data transfer and APK installation.
- If the app is not debuggable, `run-as` may not work and you must rely on external storage paths.
- If you need, I can also add a restore section showing how to unpack and restore the pulled app data. 