# SunMonitorTool

Allows Sunshine to manage display resolutions and virtual displays on Windows.

## Prerequisites

- [**Mike's VDD fork**](https://github.com/itsmikethetech/Virtual-Display-Driver): Creates a virtual display similar to a real one, so we don't have to use a dummy HDMI tool. Install instructions in the repo readme.
- [**qres**](https://sourceforge.net/projects/qres/): A command-line utility for setting the screen resolution. Make sure the executable is accessible in your system's PATH.
- [**MultiMonitorTool**](https://www.nirsoft.net/utils/multi_monitor_tool.html): A tool to manage multiple displays. Make sure the executable is accessible in your system's PATH.

## How to use
- Install the prerequisites
- Put the script somewhere (I put it in %appdata%/Roaming/SunMonitorTool)
- Change the virtual monitor path (open multimonitortool and look in the row for 'Virtual Display with HDR' and get the name)
  - Should look like `\\.\DISPLAY5`
- Change your "Command Preparations" in Sunshine > Config > General
  - config.do_cmd: `powershell.exe -executionpolicy bypass -windowstyle hidden -file "C:\path\to\sunmonitortool.ps1"`
  - config.undo_cmd: `powershell.exe -executionpolicy bypass -windowstyle hidden -file "C:\path\to\sunmonitortool.ps1" -ResetDisplays`
- The tool should autodetect the resolutions and switch to them with qres. On stream exit, it should reset **provided the primary monitor has not changed.**
