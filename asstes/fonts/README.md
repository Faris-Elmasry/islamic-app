# Font Files Installation Guide

## Required Arabic Fonts

To use all the font customization features in the Azkar app, you need to download and install the following Arabic font files in the `asstes/fonts/` directory:

### 1. ✅ Tajawal (Already Installed)

- ✅ All Tajawal font files are already present

### 2. Amiri Font

**Download from:** [Google Fonts - Amiri](https://fonts.google.com/specimen/Amiri)

Required files:

- `Amiri-Regular.ttf`
- `Amiri-Bold.ttf`

### 3. Cairo Font

**Download from:** [Google Fonts - Cairo](https://fonts.google.com/specimen/Cairo)

Required files:

- `Cairo-Regular.ttf`
- `Cairo-Bold.ttf`

### 4. Scheherazade New Font

**Download from:** [Google Fonts - Scheherazade New](https://fonts.google.com/specimen/Scheherazade+New)

Required files:

- `ScheherazadeNew-Regular.ttf`
- `ScheherazadeNew-Bold.ttf`

### 5. Lateef Font

**Download from:** [Google Fonts - Lateef](https://fonts.google.com/specimen/Lateef)

Required files:

- `Lateef-Regular.ttf`
- `Lateef-Bold.ttf`

### 6. Reem Kufi Font

**Download from:** [Google Fonts - Reem Kufi](https://fonts.google.com/specimen/Reem+Kufi)

Required files:

- `ReemKufi-Regular.ttf`
- `ReemKufi-Bold.ttf`

## Installation Steps

1. **Download the fonts:**

   - Visit each Google Fonts link above
   - Click "Download family" button
   - Extract the ZIP file

2. **Copy font files:**

   - Navigate to `asstes/fonts/` folder in your project
   - Copy the required `.ttf` files listed above
   - Make sure the file names match exactly

3. **Verify installation:**

   - The folder should contain all Tajawal files (already present) plus the new fonts
   - Total: approximately 16-18 `.ttf` files

4. **Run the app:**
   ```bash
   flutter pub get
   flutter run
   ```

## Alternative: Quick Download

You can also download all fonts in one go:

1. Visit [Google Fonts](https://fonts.google.com/)
2. Search for each font: Amiri, Cairo, Scheherazade New, Lateef, Reem Kufi
3. Add to collection
4. Download all as ZIP
5. Extract and copy required files to `asstes/fonts/`

## Font Features in App

Once installed, users can:

- ✨ Choose from 6 different Arabic fonts
- 📏 Adjust font size from 12 to 40
- 👁️ Live preview before applying
- 💾 Settings saved automatically
- 🔄 Reset to defaults anytime

## Troubleshooting

**Font not showing in app?**

- Verify file names match exactly (case-sensitive)
- Run `flutter clean` then `flutter pub get`
- Restart the app

**Build errors?**

- Check `pubspec.yaml` fonts section
- Ensure all paths start with `asstes/fonts/`
- Verify no typos in file names

## Current Font Status

| Font             | Status       | Files Needed |
| ---------------- | ------------ | ------------ |
| Tajawal          | ✅ Installed | None         |
| Amiri            | ⏳ Pending   | 2 files      |
| Cairo            | ⏳ Pending   | 2 files      |
| Scheherazade New | ⏳ Pending   | 2 files      |
| Lateef           | ⏳ Pending   | 2 files      |
| Reem Kufi        | ⏳ Pending   | 2 files      |

**Total files needed:** 10 `.ttf` files

---

**Note:** The app will work with just Tajawal font (already installed), but other fonts won't be available for selection until you download and install them.
