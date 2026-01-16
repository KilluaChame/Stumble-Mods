# Copilot instructions — Stumble Mods (AutoIt)

This project is a collection of AutoIt scripts and compiled EXEs that work together to provide a launcher, an overlay, and several game automation tools for "Stumble Guys". The guidance below highlights the core architecture, integration points, developer workflows, and project-specific patterns an AI coding agent should know to be productive quickly.

1. Big picture

- **Components**: Launcher (Launcher_GUI_1.1.au3), Overlay (Overlay.au3 / Overlay.exe), Aimbot (Aimbot/...), Plataforma timer (Plataforma/PlataformaTimer.au3) and AFK farm (AFK_FARM/...). The launcher launches the other components as separate processes.
- **IPC**: `status.ini` (in repository root / script dir) is the simple IPC mechanism. Launcher writes AIM/PLATAFORMA/AFK and CONFIG/Alpha keys; Overlay reads them and updates visuals.
- **Why split**: Each feature runs as its own AutoIt process/EXE for isolation and to allow independent toggling; the launcher is a lightweight process manager and UI.

2. Key integration points (search these files when making changes)

- [Launcher_GUI_1.1.au3](Launcher_GUI_1.1.au3): central process starter. Edit Global Const paths at top to point to compiled EXEs. Uses IniWrite/IniRead to flip statuses and `Run()` / `ProcessClose()` to control processes.
- [Overlay.au3](Overlay.au3): reads `status.ini` (sections: AIM, PLATAFORMA, AFK, CONFIG Alpha) and updates overlay GUI. Controls transparency with WinSetTrans and positions overlay based on game window position.
- `status.ini`: authoritative small-state file. Example contents: `[AIM] on=0` and `[CONFIG] Alpha=210`.

3. Hotkeys and lifecycle

- Common hotkeys: F7 toggles Aim (Launcher & scripts), F8 toggles Plataforma, F10 toggles AFK, F11 in launcher closes all, F12 terminates Overlay. Many scripts also use F1 for calibration.
- Scripts use `#RequireAdmin`. Run or test them with elevated permissions (use the AutoIt interpreter or compiled EXE run-as-admin).

4. Platform and resolution assumptions

- Many detection routines are pixel-based (PixelGetColor / IsHexColorInRange). Default base resolution is 1920x1080; transform helpers exist (see AFK scripts: `TransformCoordinates`, `GetClientSize`). When editing detection logic, prefer to keep scaling logic intact.

5. Patterns & conventions

- GUI-heavy AutoIt style: GUICtrlCreate\*, GUICtrlSetBkColor, WinMove for overlays.
- Global variables widely used across scripts (e.g., `$PID_Aimbot`, `$TempoPlataforma`). Avoid converting globals to locals without checking all callers.
- IPC via INI file (single-source-of-truth). Do not introduce additional IPC without reason — prefer extending `status.ini` sections.

6. Build / run / debug tips (practical examples)

- Run a script interactively: open the .au3 in SciTE or run with AutoIt v3 interpreter.
- Compile to EXE (so Launcher can run them): use AutoIt Aut2Exe (GUI or CLI). Example CLI pattern:

  "C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe.exe" /in "Aimbot_Teclado1.1_F7Close.au3" /out "Aimbot_Teclado1.1_F7Close.exe"

- To test the overlay/launcher workflow locally: 1) compile Overlay.au3 to Overlay.exe, 2) ensure `Launcher_GUI_1.1.au3` paths point to compiled EXEs (or run the .au3 scripts directly), 3) run the launcher as admin.
- Debugging tips: use `ToolTip()`, `MsgBox()`, or temporary `FileWrite()` logs. For pixel-detection issues, log the Pixel() results and confirm the game's window title matches `Stumble Guys` (WinWait uses this exact title).

7. Safe edits and common pitfalls

- Always preserve `#RequireAdmin` if a script expects elevated privileges.
- When changing hotkeys, update both Launcher and Overlay and any dependent scripts to keep UX consistent.
- Pixel coord changes must account for `TransformCoordinates` scaling. Do not hardcode new coordinates without verifying multi-resolution behavior.

8. Where to look for examples

- Launcher startup, status writes: [Launcher_GUI_1.1.au3](Launcher_GUI_1.1.au3) (IniWrite/Run/ProcessClose usage).
- Overlay read/update loop: [Overlay.au3](Overlay.au3) (IniRead/WinSetTrans/GUI updates).
- Resolution-aware detection and transforms: AFK_FARM/\*.au3 (TransformCoordinates, GetClientSize).

If anything important is missing from this summary (missing scripts, different game window title, custom compile flags, or CI hooks), tell me what to include and I will update this file.
