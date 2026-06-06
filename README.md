# YTM Art Mode Widget

Pure album art, zero UI. A completely borderless, resizable companion widget for YouTube Music Desktop with a modern Lofi aesthetic.

---

## 📸 Screenshots

*(User: Insert your "Hero Shot" here)*
![Art Mode Preview](https://via.placeholder.com/400?text=Hero+Shot+Placeholder)

*(User: Insert your "Hover State" shot here)*
![Hover Preview](https://via.placeholder.com/400?text=Hover+State+Placeholder)

---

## ✨ Features

- **Pure Immersive Look:** Displays only the high-res album art with zero window clutter or title bars.
- **Lofi Aesthetic:** Retro monospace typography, all-lowercase text, and soft rounded corners.
- **Smart Resizing:** Drag any corner to resize; the window automatically stays a perfect square to keep the art crisp.
- **Invisible Execution:** Includes a silent launcher so the PowerShell terminal never distracts you or shows in your taskbar.
- **Auto-Hide UI:** The Close (X) button and resize grip are invisible until you hover your mouse over them.
- **Live Progress:** A paper-thin minimalist bar at the bottom tracks your song's duration.
- **High Performance:** Lightweight WPF/PowerShell architecture with smart API polling to avoid rate limits.

---

## 🛠️ Requirements

- **OS:** Windows 10 or Windows 11.
- **App:** [YouTube Music Desktop App (NovusTheory/ytmdesktop)](https://ytmdesktop.app/) v2.0 or higher.
- **Integration:** You must enable the **Companion Server** in your app settings (see below).

---

## 🚀 Setup Instructions

1. **Enable the API:**
   - Open YouTube Music Desktop.
   - Go to **Settings** -> **Integrations**.
   - Toggle **Companion Server** to **ON**.
   - Toggle **Enable Companion Authorization** to **ON**.

2. **Launch the Widget:**
   - Download this repository folder.
   - Double-click **`YTM-Art-Widget-Launcher.vbs`**.
   - A terminal may blink for a split second, then vanish.
   - **Check your YouTube Music App:** A popup will appear asking to authorize "ArtWidget." Click **Approve**.

3. **Enjoy!**
   - The art will appear within a few seconds. 
   - Drag to move, drag corners to resize.
   - **Hover** over the window to see the Close (X) button.

---

## 📜 License

This project is licensed under the [MIT License](LICENSE). 
Created by James Bratton.
