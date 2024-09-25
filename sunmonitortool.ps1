param (
    [switch]$ResetDisplays  # Flag to reset displays to their original state
)

$virtualMonitorPath = "\\.\DISPLAY5"

Add-Type -AssemblyName System.Windows.Forms

# Function to setup resolution and FPS using qres
function Set-Resolution {
    # Get resolution of primary monitor via windows forms
    $primaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen

    $width = $primaryScreen.Bounds.Width
    $height = $primaryScreen.Bounds.Height

    # Using qres for this as get-ciminstance rounds down
    $qresRaw = qres /S
    $fps = ($qresRaw | Select-String -Pattern "\d+ Hz").Matches.Value.Replace(" Hz", "")

    $sunh = $Env:SUNSHINE_CLIENT_HEIGHT
    $sunw = $Env:SUNSHINE_CLIENT_WIDTH
    $sunfps = $Env:SUNSHINE_CLIENT_FPS

    # Save the resolution and FPS information to a file
    $output = "h: $height`nw: $width`nf: $fps`nsunshine_spec_dbg: $sunw x $sunh - $sunfps fps";
    $output | Out-File -FilePath "$env:APPDATA\sunshineres-resolution.txt";

    # Save debug info for the qres command
    echo "qres /x:$Env:SUNSHINE_CLIENT_WIDTH /y:$Env:SUNSHINE_CLIENT_HEIGHT /r:$Env:SUNSHINE_CLIENT_FPS" | Out-File -FilePath "$env:APPDATA\sunshineres-latest-dbg.txt";

    # Apply the resolution and refresh rate with qres
    qres.exe /X:$Env:SUNSHINE_CLIENT_WIDTH /Y:$Env:SUNSHINE_CLIENT_HEIGHT /R:$Env:SUNSHINE_CLIENT_FPS
}

function Reset-Resolution {
    $content = Get-Content -Path "$env:APPDATA\sunshineres-resolution.txt";

    $height = ($content | Select-String 'h:').ToString() -replace '\D+', '';
    $width = ($content | Select-String 'w:').ToString() -replace '\D+', '';
    $fps = ($content | Select-String 'f:').ToString() -replace '\D+', '';

    echo "qres /x:$width /y:$height /r:$fps" | Out-File -FilePath "$env:APPDATA\sunshineres-latest-rev-dbg.txt";

    qres /x:$width /y:$height /r:$fps
}

# Function to detect connected displays
function Get-ConnectedDisplays {
    $displayConfig = Get-WmiObject -Namespace root\wmi -Class WmiMonitorBasicDisplayParams
    return $displayConfig
}

# Function to check if the virtual display with instance id "MTT1337" is enabled
function Is-VirtualDisplayInstalled {
    $virtualDisplay = Get-PnpDevice | Where-Object { $_.InstanceId -like "*MTT1337*" -and $_.Status -eq "OK" }
    return $virtualDisplay -ne $null
}

# Enable the virtual display if not already enabled
function Enable-VirtualDisplay {
    if (Is-VirtualDisplayInstalled) {
        Write-Host "Virtual display installed. Enabling virtual display..."

         multimonitortool.exe /enable $virtualMonitorPath

        Start-Sleep -Seconds 3  # Wait a few seconds for the virtual display to become active
    } else {
        Write-Host "Virtual display is not installed."
    }
}
function Disable-VirtualDisplay {
    if (Is-VirtualDisplayInstalled) {
        Write-Host "Virtual display installed. Enabling virtual display..."

         multimonitortool.exe /display $virtualMonitorPath

        Start-Sleep -Seconds 3  # Wait a few seconds for the virtual display to become active
    } else {
        Write-Host "Virtual display is not installed."
    }
}


if ($ResetDisplays) {
    Write-Host "Resetting displays to original state..."
    Reset-Resolution
} else {
    # Check if any physical monitors are connected
    $connectedDisplays = Get-ConnectedDisplays

    if (($connectedDisplays.Count -lt 1) -and (Is-VirtualDisplayInstalled)) {
        Write-Host "No physical displays detected."
        
        # Enable virtual display if necessary
        Enable-VirtualDisplay

        # Call the resolution setup function for virtual display
        Set-Resolution
    } elseif ($connectedDisplays.Count -eq 0) {

    } else {
        Write-Host "Physical display detected. Proceeding with standard resolution setup..."

        # Call the resolution setup function for the physical display
        Set-Resolution
    }
}
