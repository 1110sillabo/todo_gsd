GODOT_mobile_export.md

To interact with native phone features like sharing, email, or messaging in Godot, you have to bridge the gap between the **Godot Engine (C++/GDScript)** and the **Mobile OS (Java/Kotlin for Android, Swift/Obj-C for iOS)**.

Godot does not have a "Universal Share" button built into the core engine because every mobile OS handles permissions and "Intents" differently. Instead, you use the **"Plug-in"** pattern.

---

## 1. The Method: Godot Android/iOS Plugins

To "Share" something, you need to trigger a native system dialog (the "Share Sheet").

### For Android:

You use an **Android Plugin**. This allows GDScript to call a Java method that triggers an `Intent.ACTION_SEND`.

* **The "Verb":** `Engine.get_singleton("PluginName")`

### For iOS:

You use an **iOS Plugin** (usually distributed as a `.gdip` file). This calls the `UIActivityViewController`.

---

## 2. Using an Existing Solution (The Easy Way)

The most popular way to do this without writing native Java/Swift code yourself is using the **Godot Share** plugin (available on GitHub).

### Implementation in GDScript:

Once the plugin is installed, your code looks like this:

```gdscript
func _on_share_button_pressed():
    if Engine.has_singleton("GodotShare"):
        var share = Engine.get_singleton("GodotShare")
        
        # Sharing text/URL
        share.shareText("Check out my app!", "Look at this data: 12345", "https://myapp.com")
        
        # Sharing an image (e.g., a screenshot)
        var path = "user://screenshot.png"
        share.sharePic(ProjectSettings.globalize_path(path), "Share Score", "Look at my high score!")

```

---

## 3. How the "Bridge" Works

If you wanted to build this yourself, here is how the communication flows:

1. **GDScript:** Calls a method on a "Singleton."
2. **C++ Bridge:** Godot's engine passes that call to the native OS wrapper.
3. **Native Code:**
* **Android:** Creates an `Intent`.
* **iOS:** Creates a `UIActivityViewController`.


4. **System Dialog:** The phone pops up the menu with Email, WhatsApp, Slack, etc.

---

## 4. Deep Linking (Inter-App Communication)

If you specifically want to open *another* app (like opening a specific email address), you can use `OS.shell_open()`. This is the only "native" way Godot handles this without plugins.

* **To Open Email:** `OS.shell_open("mailto:support@example.com?subject=App%20Data&body=Hello")`
* **To Open WhatsApp:** `OS.shell_open("https://wa.me/123456789?text=Hello")`
* **To Open SMS:** `OS.shell_open("sms:+123456789&body=Check%20this%20out")`

---

## 5. Things to Watch Out For

* **Export Templates:** When using plugins, you **must** use "Custom Builds" in your Android Export settings. This allows Godot to compile the Java code into your `.apk`.
* **Scoped Storage (Android):** If you are sharing a file (like a PDF or Image), you have to save it to the "User" directory (`user://`) and then globalize the path so the external app has permission to read it.
* **Privacy Manifests (iOS):** In 2024+, Apple requires you to declare why you are interacting with other apps in your `Info.plist`.

### Summary of "Verbs" for Godot Mobile

| Action | Method | Difficulty |
| --- | --- | --- |
| **Open URL/Email** | `OS.shell_open()` | Easy (Built-in) |
| **Generic Share Sheet** | Third-party Plugin | Medium (Requires Export setup) |
| **Custom Integration** | Writing a `.gdap` / `.gdip` plugin | Hard (Requires Java/Swift) |

**Are you targeting a specific platform primarily (Android or iOS), or do you need a cross-platform solution?** (I can point you to the specific GitHub repository for the most up-to-date plugins for Godot 4.x).


Since you are targeting **Godot 4.6**, you have the advantage of a more mature GDExtension system. For sending a simple JSON note via email, you have two distinct paths depending on how much "ceremony" you want for the user.

---

## Path A: The "Light" Way (Built-in, No Plugins)

If you just want to open the user's default email app with the JSON data pre-filled in the body, you can use the **`mailto`** URI scheme. This is cross-platform and requires **zero plugins**.

* **The Verb:** `OS.shell_open()`
* **The Limitation:** URI strings have a character limit (usually around 2,000 characters). If your JSON note is massive, this will fail.

### GDScript Implementation

```gdscript
func send_note_via_email(note_title: String, note_content: String):
	var data = {
		"title": note_title,
		"body": note_content,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	# Convert dictionary to a JSON string
	var json_string = JSON.stringify(data)
	
	# Format the email parameters
	var subject = "My App Note: " + note_title.uri_encode()
	var body = "Here is my exported data:\n\n".uri_encode() + json_string.uri_encode()
	
	# Construct the full mailto link
	var mailto_url = "mailto:?subject=%s&body=%s" % [subject, body]
	
	# Trigger the phone's OS to open the email app
	OS.shell_open(mailto_url)

```

---

## Path B: The "Professional" Way (Native Sharing)

If you want the data to be sent as an **actual `.json` file attachment**, or if you want to give the user the choice between Email, WhatsApp, or Telegram, you must use a Native Plugin.

For Godot 4.6, the community standard is **GodotShare**.

### 1. Setup

* Download the **GodotShare** Android/iOS plugin.
* In Godot, go to **Project -> Export**.
* Ensure **"Use Custom Build"** is checked for Android.

### 2. Implementation (Sharing a File)

To send an attachment, you must first write the JSON to a temporary file in the `user://` directory.

```gdscript
func share_json_file(note_data: Dictionary):
	# 1. Prepare the JSON string
	var json_string = JSON.stringify(note_data, "\t")
	
	# 2. Save to a temporary file
	var file_path = "user://exported_note.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
	# 3. Use the Plugin to share
	if Engine.has_singleton("GodotShare"):
		var share = Engine.get_singleton("GodotShare")
		
		# We must convert 'user://' to an absolute OS path
		var absolute_path = ProjectSettings.globalize_path(file_path)
		
		# Trigger native share sheet
		share.shareFile(absolute_path, "Export Note", "Sharing my JSON note as an attachment.")
	else:
		print("Native sharing not available on this platform.")

```

---

## Comparison of the Two "Verbs"

| Feature | `OS.shell_open` (Mailto) | `GodotShare` (Native) |
| --- | --- | --- |
| **Format** | Plain Text in body. | **Actual .json file attachment.** |
| **Setup** | Immediate. | Requires Plugin & Custom Export. |
| **User Choice** | Only Email. | Email, Cloud Drive, Messaging apps. |
| **Reliability** | Fails if text is too long. | Very reliable for any file size. |

### Technical Tip for Godot 4.6

When sharing files on **Android**, Godot uses a `FileProvider` to give other apps (like Gmail) permission to read your app's internal files. If you write your own plugin or use an older one, ensure it targets **Android API 34+** logic, as Google has tightened "Scoped Storage" rules recently.

**Does your note include images or just text?** If it's just text, Path A is remarkably efficient for a "Foundations" project.