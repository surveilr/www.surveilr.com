# surveilrctl Windows Installation Script
# Usage: irm https://surveilr.com/install.ps1 | iex
# With host parameter: $env:SURVEILR_HOST="your-host-url"; irm https://surveilr.com/surveilrctl.ps1 | iex

[CmdletBinding()]
param (
    [string]$SurveilrHost = $env:SURVEILR_HOST
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter(Mandatory)]
        [string]$ForegroundColor
    )
    
    $previousColor = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    Write-Output $Message
    $host.UI.RawUI.ForegroundColor = $previousColor
}

Write-ColorOutput "╔════════════════════════════════════════════════════════════╗" "Blue"
Write-ColorOutput "║              surveilrctl Windows Installation               ║" "Blue"
Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" "Blue"

$GithubRepo = "surveilr/surveilrctl"
$LatestReleaseUrl = "https://api.github.com/repos/$GithubRepo/releases/latest"

# confirm admin privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-ColorOutput "Warning: This script is not running with administrator privileges." "Yellow"
    Write-ColorOutput "Some operations might fail. Consider re-running in an administrator PowerShell:" "Yellow"
    Write-ColorOutput '  Start-Process powershell -Verb RunAs -ArgumentList "-Command $env:SURVEILR_HOST=''your-host''; irm https://surveilr.com/surveilrctl.ps1 | iex"' "Yellow"
    Write-ColorOutput "" "White"
    
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-ColorOutput "Installation canceled." "Red"
        exit 1
    }
}

# temp dir
$tempDir = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
    Write-ColorOutput "Fetching latest release information..." "Blue"
    $releaseInfo = Invoke-RestMethod -Uri $LatestReleaseUrl -ErrorAction Stop
    $version = $releaseInfo.tag_name -replace "^v", ""
    
    Write-ColorOutput "Latest version: $version" "Green"
    
    $downloadUrl = "https://github.com/$GithubRepo/releases/download/v$version/surveilrctl_${version}_x86_64-pc-windows-msvc.zip"
    $archiveName = "surveilrctl_${version}_x86_64-pc-windows-msvc.zip"
    $outputArchive = Join-Path $tempDir $archiveName
    
    Write-ColorOutput "Downloading $archiveName..." "Blue"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputArchive -ErrorAction Stop
    
    Write-ColorOutput "Extracting archive..." "Blue"
    Expand-Archive -Path $outputArchive -DestinationPath $tempDir -Force
    
    $installDir = "C:\Program Files\surveilrctl"
    
    if (-not (Test-Path $installDir)) {
        Write-ColorOutput "Creating installation directory: $installDir" "Blue"
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }
    
    Write-ColorOutput "Installing surveilrctl to $installDir" "Blue"
    Copy-Item -Path (Join-Path $tempDir "surveilrctl.exe") -Destination $installDir -Force
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*$installDir*") {
        Write-ColorOutput "Adding installation directory to PATH" "Blue"
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$installDir", "Machine")
        $env:Path = $env:Path + ";$installDir"
    }
    
    Write-ColorOutput "✓ surveilrctl has been installed to $installDir\surveilrctl.exe" "Green"
    
    # setup if host is provided
    if ($SurveilrHost) {
        Write-ColorOutput "Running initial setup with host: $SurveilrHost" "Blue"
        
        try {
            & "$installDir\surveilrctl.exe" setup --uri $SurveilrHost
            Write-ColorOutput "✓ Setup completed successfully!" "Green"
        }
        catch {
            Write-ColorOutput "Setup failed. You may need to run it manually:" "Red"
            Write-ColorOutput "  surveilrctl setup --uri $SurveilrHost" "Yellow"
        }
    }
    else {
        Write-ColorOutput "To complete setup, run:" "Blue"
        Write-ColorOutput "  surveilrctl setup --uri https://your-surveilr-host" "Yellow"
    }
}
catch {
    Write-ColorOutput "Error: $_" "Red"
    exit 1
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
}

Write-ColorOutput "" "White"
Write-ColorOutput "Installation complete!" "Green"