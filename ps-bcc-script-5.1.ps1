Write-Output "#######################################################"
Write-Output "PowerShell script to backup browsing history and delete cache & cookies in Firefox, Chrome & IE/Edge browsers"
Write-Output "#######################################################"

# Customizable paths
$csv = "C:\Support\BCC\bcc-users.csv"
$backupDir = "C:\Support\BCC\BrowserHistoryBackup"
$logFile = "C:\Support\BCC\BrowserCleanupLog.txt"

# Start Logging
Start-Transcript -Path $logFile -Append

Write-Output "SECTION 1: Getting the list of users"
Write-Output "Exporting the list of users to $csv"
# List the users in c:\users and export to the local profile for calling later
Get-ChildItem "C:\Users" | Select-Object Name | Export-Csv -Path $csv -NoTypeInformation
$list = Test-Path $csv

if (!$list) {
    Write-Output "Failed to generate the user list. Script aborted."
    Stop-Transcript
    Exit
}

Write-Output "SECTION 2: Beginning Script..."

# Ensure backup directory exists
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Output "Created backup directory at $backupDir"
}

# Function to perform backups
function Backup-BrowserHistory {
    param (
        [string]$historyPath,
        [string]$userBackupDir,
        [string]$browserName,
        [string]$userName
    )
     # Append the current date to the user backup directory
     $currentDate = Get-Date -Format "yyyy-MM-dd"
     $userBackupDir = "$userBackupDir-$currentDate"
 
    if (!(Test-Path $userBackupDir)) {
        New-Item -ItemType Directory -Path $userBackupDir | Out-Null
    }
    try {
        if (Test-Path $historyPath) {
            Copy-Item -Path $historyPath -Destination $userBackupDir -Force
            Write-Output "$browserName history backed up for user $userName"
        } else {
            Write-Output "No $browserName history found for user $userName"
        }
    } catch {
        Write-Output "Error backing up $browserName history for user $userName : $_"
    }
}

Write-Output "SECTION 3: Backing Up Browsing Histories"

Import-CSV -Path $csv -Header Name | ForEach-Object {
    # Mozilla Firefox Backup
    $ff_history = "C:\Users\$($_.Name)\AppData\Roaming\Mozilla\Firefox\Profiles\*.default\places.sqlite"
    $ff_backupDir = "$backupDir\$($_.Name)\Firefox"
    Backup-BrowserHistory -historyPath $ff_history -userBackupDir $ff_backupDir -browserName "Firefox" -userName $_.Name

    # Google Chrome Backup
    $ch_history = "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\History"
    $ch_backupDir = "$backupDir\$($_.Name)\Chrome"
    Backup-BrowserHistory -historyPath $ch_history -userBackupDir $ch_backupDir -browserName "Chrome" -userName $_.Name

    # Microsoft Edge Backup
    $edge_history = "C:\Users\$($_.Name)\AppData\Local\Microsoft\Edge\User Data\Default\History"
    $edge_backupDir = "$backupDir\$($_.Name)\Edge"
    Backup-BrowserHistory -historyPath $edge_history -userBackupDir $edge_backupDir -browserName "Edge" -userName $_.Name
}

Write-Output "All Browsing History Backed Up!"

# Function to clear caches
function Clear-Cache {
    param (
        [string[]]$paths,
        [string]$browserName,
        [string]$userName
    )
    foreach ($path in $paths) {
        if (Test-Path -Path $path) {
            try {
                Get-ChildItem -Path "$path" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
                }
                Write-Output "Cleared $browserName cache for user $userName at $path"
            } catch {
                Write-Output "Failed to clear $browserName cache for user $userName at $path : $_"
            }
        } else {
            Write-Output "Path not found: $path for $browserName cache of user $userName"
        }
    }
}

Write-Output "SECTION 4: Clearing Browser Caches"

Import-CSV -Path $csv -Header Name | ForEach-Object {
    # Mozilla Firefox Cache
    $ff_cachePaths = @(
        "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*",
        "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\",
        "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\*",
        "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite",
        "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite",
        "C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite"
    )
    Clear-Cache -paths $ff_cachePaths -browserName "Firefox" -userName $_.Name

    # Google Chrome Cache
    $ch_cachePaths = @(
        "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\cache\*",
        "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\cache2\entries\",
        "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies",
        "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Media Cache",
        "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal"
    )
    Clear-Cache -paths $ch_cachePaths -browserName "Chrome" -userName $_.Name

# Internet Explorer / Edge Cache
$ie_cachePaths = @(
    "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\Temporary Internet Files\*",
    "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\WER\*",
    "C:\Users\$($_.Name)\AppData\Local\Temp\*",
    "C:\Windows\Temp\*",
    "C:\`$Recycle.Bin\*"
)

    # Iterate through each path and handle clearing
    foreach ($path in $ie_cachePaths) {
        if (Test-Path -Path $path) {
            try {
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-Output "Cleared $path for Edge/IE cache"
            } catch {
                Write-Output "Failed to clear $path for Edge/IE cache: $_"
            }
        } else {
            Write-Output "Path not found: $path for Edge/IE cache"
        }
    }
}
Write-Output "All Cache and Cookies Cleared!"

# Stop Logging
Stop-Transcript
