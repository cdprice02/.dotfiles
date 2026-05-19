if ($global:__PROFILE_LOADED) { return }; $global:__PROFILE_LOADED = $true

# setup user .config/ directory
$ConfigDir = Join-Path -Path $HOME -ChildPath ".config"
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir | Out-Null
}

# output encoding
$OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PYTHONIOENCODING = 'utf-8'

# install gitaliases
$GitaliasPath = Join-Path $ConfigDir 'gitalias.txt'
if (-not (Test-Path $GitaliasPath)) {
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt" -OutFile $GitaliasPath -ErrorAction Stop
    }
    catch {
        Write-Warning "Could not download gitalias.txt: $_"
    }
}

git config --global include.path $GitaliasPath

# install PSReadLine
$RequiredVersion = [Version]"2.1.0"
$module = Get-Module -ListAvailable -Name PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
if (-not $module -or $module.Version -lt $RequiredVersion) {
    try {
        # Install for the current user, skip prompting for trusted publisher
        Install-Module -Name PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser -MinimumVersion $RequiredVersion
        Import-Module PSReadLine -Force
    }
    catch {
        Write-Warning "Could not update or import PSReadLine module: $_"
    }
}

$module = Get-Module -ListAvailable -Name PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
if ($module -and $module.Version -ge $RequiredVersion) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
}
Set-PSReadLineOption -EditMode Windows

# setup starship
Invoke-Expression (&starship init powershell)

# aliases
Set-Alias ll 'Get-ChildItem'
Set-Alias la 'Get-ChildItem -Force'
Set-Alias edit 'notepad'

Clear-Host
