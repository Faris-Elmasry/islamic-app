# 🎨 Font Customization - Quick Start Guide

## How to Use the New Font Features

### Step 1: Open Font Settings

```
📱 App Home
  ↓
⚙️ Settings (الإعدادات)
  ↓
🔤 تخصيص الخط (Font Customization)
  ↓
✏️ تخصيص خط الأذكار
```

### Step 2: Choose Your Font

Tap any of the 6 available fonts:

- **تجول (Tajawal)** - Clear and easy to read ✅ _Ready to use_
- **أميري (Amiri)** - Traditional elegant font
- **القاهرة (Cairo)** - Modern distinctive font
- **شهرزاد (Scheherazade)** - Traditional Naskh script
- **لطيف (Lateef)** - Simple Naskh script
- **ريم كوفي (Reem Kufi)** - Modern Kufi font

_Note: Only Tajawal is currently available. See installation guide below._

### Step 3: Adjust Font Size

- **Slider**: Drag to any size between 12-40
- **+ Button**: Increase size by 2
- **- Button**: Decrease size by 2
- **Live Preview**: See changes instantly

### Step 4: View Your Azkar

- Open any azkar category
- Text now displays in your chosen font and size!

### Step 5: Reset if Needed

- Tap the **🔄 refresh icon** (top-right)
- Returns to defaults: Tajawal, size 18

---

## 📥 Installing Additional Fonts

Currently only **Tajawal** font is installed. To get the other 5 fonts:

### Quick Steps:

1. Visit [Google Fonts](https://fonts.google.com/)
2. Search for each font name
3. Click "Download family"
4. Extract the ZIP file
5. Copy `.ttf` files to: `asstes/fonts/`

### Required Files:

```
asstes/fonts/
├── Tajawal-*.ttf (✅ already installed)
├── Amiri-Regular.ttf
├── Amiri-Bold.ttf
├── Cairo-Regular.ttf
├── Cairo-Bold.ttf
├── ScheherazadeNew-Regular.ttf
├── ScheherazadeNew-Bold.ttf
├── Lateef-Regular.ttf
├── Lateef-Bold.ttf
├── ReemKufi-Regular.ttf
└── ReemKufi-Bold.ttf
```

### Direct Download Links:

1. **Amiri**: https://fonts.google.com/specimen/Amiri
2. **Cairo**: https://fonts.google.com/specimen/Cairo
3. **Scheherazade New**: https://fonts.google.com/specimen/Scheherazade+New
4. **Lateef**: https://fonts.google.com/specimen/Lateef
5. **Reem Kufi**: https://fonts.google.com/specimen/Reem+Kufi

### After Installing:

```bash
flutter pub get
flutter run
```

📖 **Detailed guide**: See `asstes/fonts/README.md`

---

## 💡 Tips & Tricks

### Best Font Sizes:

- **Small phones**: 14-18
- **Medium phones**: 18-22
- **Large phones/tablets**: 22-28
- **Vision assistance**: 28-40

### Font Recommendations:

- **Easy reading**: Tajawal, Cairo
- **Traditional look**: Amiri, Scheherazade
- **Clean modern**: Lateef, Cairo
- **Decorative**: Reem Kufi

### Power User Features:

- ⚡ **Long press** on azkar cards to reset count
- 🔄 **Swipe** to navigate between azkar pages
- 💾 **Auto-save**: All changes save immediately
- 🎨 **Global**: Changes apply to all azkar categories

---

## ❓ Troubleshooting

### Font not showing?

1. Check file is in `asstes/fonts/` folder
2. Verify exact file name (case-sensitive)
3. Run `flutter clean && flutter pub get`
4. Restart app

### Text looks weird?

- Try different font
- Adjust size up or down
- Reset to defaults

### Settings not saving?

- Check storage permissions
- Restart app
- Check Hive initialization

---

## 🌟 What's New

### Features:

✅ 6 beautiful Arabic fonts  
✅ Font size control (12-40)  
✅ Live preview  
✅ Instant apply  
✅ Auto-save settings  
✅ Reset to defaults  
✅ Responsive descriptions  
✅ Consistent across all pages

### Benefits:

🎯 **Personalized**: Your style, your way  
👁️ **Accessible**: Adjust for comfort  
📱 **Seamless**: Works across all azkar  
💾 **Persistent**: Remembers your choices  
🚀 **Fast**: Instant updates

---

**Enjoy your customized azkar reading experience!** 🌙
