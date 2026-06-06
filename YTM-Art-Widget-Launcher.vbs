Set WshShell = CreateObject("WScript.Shell")
' Run the PowerShell script with WindowStyle 0 (Hidden)
' This ensures NO blue window or taskbar item ever appears for the terminal.
WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & "\YTM-Art-Widget.ps1""", 0, False
