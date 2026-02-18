# 📸 Google Takeout Metadata Integrator (PowerShell + ExifTool)

Restore original metadata (EXIF/XMP + Windows file timestamps) to photos and videos exported from **Google Photos Takeout**, using their JSON sidecar files.

---

## 🚀 Overview

Google Takeout exports media like this:

```
photo.jpg
photo.jpg.supplemental-metadata.json
```

However:

- Windows shows incorrect **Created / Modified** dates  
- `DateTimeOriginal` is often missing  
- GPS metadata is not restored  
- Metadata is separated into JSON sidecar files  

This script:

- Reads Google JSON sidecar files  
- Writes proper EXIF + XMP metadata  
- Restores original photo taken date  
- Sets correct Windows file timestamps  
- Works with photos and videos  
- Optionally deletes JSON files after integration  

---

## 🧠 Metadata Mapping

| Google JSON Field | Written To |
|-------------------|------------|
| `photoTakenTime.timestamp` | `DateTimeOriginal`, `CreateDate` |
| `creationTime.timestamp` | `XMP:CreateDate` |
| `creationTime.timestamp` | Windows **Created** timestamp |
| `photoTakenTime.timestamp` | Windows **Modified** timestamp |
| `description` | `ImageDescription`, `XMP-dc:Description` |
| `title` | `XMP-dc:Title` |
| `url` | `XMP:Identifier`, `XMP:Source` |
| `geoData` | GPS metadata |
| `googlePhotosOrigin.mobileUpload.deviceType` | Stored in XMP |

---

## 📂 Supported File Types

- `.jpg`
- `.jpeg`
- `.png`
- `.heic`
- `.heif`
- `.tif`
- `.tiff`
- `.webp`
- `.mov`
- `.mp4`

---

## 🔧 Requirements

- Windows  
- PowerShell 5.1+  
- **ExifTool** installed and available in PATH  

Download ExifTool:

https://exiftool.org/

After downloading:

1. Rename `exiftool(-k).exe` → `exiftool.exe`
2. Add it to your system PATH  
   or  
3. Place it in the same folder as the script  

Verify installation:

```powershell
exiftool -ver
```

---

## ▶ How To Use

### 1️⃣ Save the Script

Save the script as:

```
integrate-google-takeout.ps1
```

---

### 2️⃣ Run the Script

Open PowerShell and run:

```powershell
.\integrate-google-takeout.ps1
```

If execution is blocked:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then run again.

---

### 3️⃣ Provide Folder Path

When prompted:

```
Enter full path to folder with media and JSON files:
```

Example:

```
C:\Users\YourName\Pictures\Takeout\Google Photos
```

---

### 4️⃣ Integration Process

The script will:

- Detect supported media files  
- Match JSON sidecars (including inconsistent names like `suppleme.json`)  
- Integrate metadata  
- Report how many files were processed  

---

### 5️⃣ Optional Cleanup

After processing, you will see:

```
Delete ALL .json files from this folder? (yes/no)
```

- `yes` → Only JSON files are deleted  
- `no` → Nothing is deleted  

Media files are **never deleted**.

---

## ⚡ Why This Is Useful

Google Takeout often results in:

- Incorrect Windows timestamps  
- Missing EXIF metadata  
- Separate JSON sidecars  

This script restores your media library to:

- Proper chronological order  
- Correct EXIF metadata  
- Full compatibility with Lightroom, DigiKam, Windows Explorer, etc.

---

## 🛡 Safety Notes

- Metadata is modified in-place (`-overwrite_original`)  
- Image pixels are not modified  
- Media files are never deleted  
- JSON deletion requires explicit confirmation  

---

## 📌 Before & After

### Before

- Windows Created = Takeout export date  
- No `DateTimeOriginal`  
- GPS missing  
- JSON sidecar present  

### After

- Windows Created = Google `creationTime`  
- Windows Modified = `photoTakenTime`  
- EXIF restored  
- GPS restored  
- JSON optionally removed  

---
