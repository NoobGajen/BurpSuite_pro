#requires -Version 5.1
[CmdletBinding()]
param(
    [Alias('v')][ValidatePattern('^\d{4}\.\d+(\.\d+)*$')][string]$Version,
    [Alias('l')][switch]$ListVersions,
    [Alias('n')][ValidatePattern('\A[0-9]+\z')][ValidateRange(1, 1000)][string]$Limit = '10',
    [Alias('y')][switch]$Defaults,
    [Alias('d')][string]$InstallDir,
    [Alias('j')][string]$JavaPath,
    [Alias('s')][switch]$DesktopShortcut,
    [Alias('i')][switch]$InstallJava,
    [Alias('h')][switch]$Help
)
$ReleasesUrl = 'https://portswigger.net/burp/releases'
$DefaultVersion = '2026.10.1'

function Show-Usage {
    @'
Usage: .\install.ps1 [OPTIONS]
  -v, -Version VERSION       Install exactly this version
  -l, -ListVersions          List desktop versions with channels and exit
  -n, -Limit COUNT           Number of versions to list (default: 10; max: 1000)
  -y, -Defaults              No prompts; newest valid local JAR or pinned default
  -d, -InstallDir DIR        Default: %LOCALAPPDATA%\BurpSuite-Pro
  -j, -JavaPath FILE         Full path to Java 21 or newer
  -s, -DesktopShortcut       Also create a Desktop shortcut
  -i, -InstallJava           Compatibility flag; missing Java installs automatically
  -h, -Help                  Show this help
PowerShell uses a single dash for long parameter names too.
'@
}
function New-Release([string]$ReleaseVersion, [string]$Channel) {
    [pscustomobject]@{ Version = $ReleaseVersion; Channel = $Channel }
}
function ConvertFrom-ReleaseData([string]$Json, [int]$Count = 10) {
    $data = $Json | ConvertFrom-Json -ErrorAction Stop
    if ($null -eq $data.ResultSet.Results) { throw 'Invalid release metadata.' }
    $seen = @{}
    foreach ($row in $data.ResultSet.Results) {
        if ($row.buildCategory -notin @('desktop', 'pro', 'professional') -and
            'Desktop' -notin $row.categories -and 'Professional' -notin $row.categories) { continue }
        if ($row.version -isnot [string] -or $row.version -notmatch '^\d{4}\.\d+(\.\d+)*$' -or $seen.ContainsKey($row.version)) { continue }
        if ($null -ne $row.releaseChannels -and $row.releaseChannels -isnot [array]) {
            throw 'Invalid release channels: expected an array of strings.'
        }
        $channels = @(foreach ($item in $row.releaseChannels) {
            if ($item -isnot [string]) { throw 'Invalid release channel: expected a string.' }
            $label = ($item -replace '\s+', ' ').Trim()
            if ($label) { $label }
        })
        $channel = if ($channels.Count) { $channels -join ', ' } else { 'Not specified' }
        New-Release $row.version $channel
        $seen[$row.version] = $true
        if ($seen.Count -ge $Count) { break }
    }
}
function ConvertFrom-ArchiveYears([string]$Html) {
    $decoded = [Net.WebUtility]::HtmlDecode($Html)
    $years = @([regex]::Matches($decoded, '/burp/releases/archive\?y=(\d{4})') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique -Descending)
    if (-not $years.Count) { throw 'Cannot read release archive years.' }
    $years
}
function ConvertFrom-ArchiveLinks([string]$Html) {
    $links = [regex]::Matches($Html, '(?is)<a\b[^>]*\bhref\s*=\s*["''](?<href>[^"'']+)["'']')
    foreach ($link in $links) {
        $href = [Net.WebUtility]::HtmlDecode($link.Groups['href'].Value)
        try { $uri = [uri]::new([uri]'https://portswigger.net', $href) } catch { continue }
        if ($uri.Host -ne 'portswigger.net' -or $uri.Scheme -ne 'https') { continue }
        if ($uri.AbsolutePath -match '^/burp/releases/professional-community(?:-edition)?-(\d{4}(?:-\d+)+)$') {
            [pscustomobject]@{ Version = $Matches[1].Replace('-', '.'); Path = $uri.AbsolutePath }
        }
    }
}
function ConvertFrom-ReleaseChannel([string]$Html) {
    $labels = [regex]::Matches($Html, '(?is)<label\b[^>]*\bclass\s*=\s*["''](?<classes>[^"'']*)["''][^>]*>(?<text>.*?)</label>')
    $channels = @($labels | Where-Object { ($_.Groups['classes'].Value -split '\s+') -contains 'label' } | ForEach-Object {
        $plain = $_.Groups['text'].Value -replace '<[^>]+>', ''
        ([Net.WebUtility]::HtmlDecode($plain) -replace '\s+', ' ').Trim()
    } | Where-Object { $_ } | Select-Object -Unique)
    if (-not $channels.Count) { throw 'Cannot read the release channel.' }
    $channels -join ', '
}
function Get-ReleasePage([string]$Uri) {
    (Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 45 -ErrorAction Stop).Content
}
function Get-BurpVersions([ValidatePattern('\A[0-9]+\z')][ValidateRange(1, 1000)][string]$Count = '10') {
    $knownChannels = @{}
    try {
        $rows = @(ConvertFrom-ReleaseData (Get-ReleasePage "$ReleasesUrl/data?pageSize=100") $Count)
        if ($rows.Count -ge $Count) { return $rows }
        foreach ($row in $rows) { $knownChannels[$row.Version] = $row.Channel }
    } catch { Write-Verbose 'Release feed unavailable; trying the official archive.' }
    # The server may cap the feed at ten mixed-edition rows, leaving only four
    # desktop releases. Walk archive years until enough desktop versions exist.
    $years = @(ConvertFrom-ArchiveYears (Get-ReleasePage "$ReleasesUrl/archive"))
    $seen = @{}
    $releases = New-Object 'System.Collections.Generic.List[object]'
    foreach ($year in $years) {
        $links = @(ConvertFrom-ArchiveLinks (Get-ReleasePage "$ReleasesUrl/archive?y=$year"))
        foreach ($link in $links) {
            if ($seen.ContainsKey($link.Version)) { continue }
            $seen[$link.Version] = $true
            $channel = $knownChannels[$link.Version]
            if (-not $channel -or $channel -eq 'Not specified') {
                $channel = ConvertFrom-ReleaseChannel (Get-ReleasePage "https://portswigger.net$($link.Path)")
            }
            $releases.Add((New-Release $link.Version $channel))
            if ($releases.Count -ge $Count) { return $releases.ToArray() }
        }
    }
    if ($releases.Count -eq 0) { throw 'No desktop releases found in the archive.' }
    Write-Warning "Only $($releases.Count) desktop releases exist in the archive (requested $Count)."
    return $releases.ToArray()
}
function Format-ReleaseRow($Release, [string]$Prefix = '') {
    $channel = $Release.Channel
    if (-not [Console]::IsOutputRedirected -and $Host.UI.SupportsVirtualTerminal -and
        -not $env:NO_COLOR -and $env:TERM -ne 'dumb' -and $channel -like '*Early Adopter*') {
        $channel = "$([char]27)[38;5;250m$channel$([char]27)[0m"
    }
    '{0}{1,-16} {2}' -f $Prefix, $Release.Version, $channel
}
function Test-Jar([string]$Path) {
    $archive = $null
    try {
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive = [IO.Compression.ZipFile]::OpenRead($Path)
        $entry = $archive.GetEntry('META-INF/MANIFEST.MF')
        if ($null -eq $entry) { return $false }
        $reader = New-Object IO.StreamReader($entry.Open())
        try { $manifest = $reader.ReadToEnd() } finally { $reader.Dispose() }
        if ($manifest -notmatch '(?m)^Main-Class:[ \t]+\S+') { return $false }
        # Read every entry to catch malformed or truncated compressed data.
        $buffer = New-Object byte[] 65536
        foreach ($entry in $archive.Entries) {
            $stream = $entry.Open()
            try {
                [long]$length = 0
                while (($count = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) { $length += $count }
                if ($length -ne $entry.Length) { return $false }
            } finally { $stream.Dispose() }
        }
        return $true
    } catch { return $false } finally { if ($null -ne $archive) { $archive.Dispose() } }
}
function Save-BurpJar([string]$Destination, [string]$BurpVersion) {
    $temporary = "$Destination.part.$([guid]::NewGuid().ToString('N'))"
    Write-Host "Downloading Burp Suite $BurpVersion (JAR)..."
    try {
        Invoke-WebRequest -UseBasicParsing -TimeoutSec 1800 -Uri "https://portswigger.net/burp/releases/download?product=desktop&version=$BurpVersion&type=Jar" -OutFile $temporary -ErrorAction Stop
        if (-not (Test-Jar $temporary)) {
            throw 'Response is not a valid executable JAR (possibly an HTML error page, empty, or corrupt).'
        }
        # Replace only after validation; a failed download preserves the old file.
        if (Test-Path -LiteralPath $Destination) {
            [IO.File]::Replace($temporary, $Destination, [System.Management.Automation.Language.NullString]::Value)
        } else { [IO.File]::Move($temporary, $Destination) }
    } catch {
        throw "Failed to download Burp Suite ${BurpVersion}: $($_.Exception.Message) Download the JAR manually from $ReleasesUrl, save it as $Destination, then rerun with -v $BurpVersion and the same -d directory."
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
    }
}
function Find-Java([string]$ExplicitPath) {
    $candidates = @()
    if ($ExplicitPath) {
        $candidates = @($ExplicitPath)
    } else {
        if ($env:JAVA_HOME) { $candidates += Join-Path $env:JAVA_HOME 'bin\java.exe' }
        $candidates += @(Get-Command java.exe -All -ErrorAction SilentlyContinue | ForEach-Object { $_.Source })
        foreach ($root in @("$env:ProgramFiles\Eclipse Adoptium", "$env:ProgramFiles\Microsoft", "$env:ProgramFiles\Java")) {
            if (Test-Path -LiteralPath $root) {
                $candidates += @(Get-ChildItem -LiteralPath $root -Directory | ForEach-Object { Join-Path $_.FullName 'bin\java.exe' })
            }
        }
    }
    foreach ($candidate in $candidates) {
        if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { continue }
        $previousPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $output = (& $candidate -version 2>&1 | Out-String)
            $success = $LASTEXITCODE -eq 0
        } catch { continue } finally { $ErrorActionPreference = $previousPreference }
        if ($success -and $output -match '(?:version\s+["'']?|openjdk\s+)(\d+)' -and [int]$Matches[1] -ge 21) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    return $null
}
function Get-RequiredJava([string]$ExplicitPath) {
    $java = Find-Java $ExplicitPath
    if ($java) { return $java }
    if ($ExplicitPath) { throw 'The supplied -j path is not a working Java 21+ executable. Check the path and rerun.' }
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw 'winget is unavailable. Install Java 21 manually and use -j C:\path\to\java.exe.'
    }
    Write-Host 'Java 21 or newer not found. Downloading and installing Microsoft OpenJDK 21...'
    Write-Host 'Please wait; approve the Windows administrator prompt if one appears.'
    $logDirectory = Join-Path ([IO.Path]::GetTempPath()) ('BurpSuite-Pro-OpenJDK-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $logDirectory | Out-Null
    $arguments = @('install', '--id', 'Microsoft.OpenJDK.21', '--exact', '--source', 'winget',
        '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity')
    try {
        # Redirect at the process boundary: PowerShell must not decode/reprint
        # winget's animated UTF-8 output. Keep both streams for troubleshooting.
        $process = Start-Process -FilePath 'winget.exe' -ArgumentList $arguments -NoNewWindow -Wait -PassThru `
            -RedirectStandardOutput (Join-Path $logDirectory 'stdout.log') `
            -RedirectStandardError (Join-Path $logDirectory 'stderr.log') -ErrorAction Stop
        if ($process.ExitCode -ne 0) { throw "winget exit code $($process.ExitCode)" }
    } catch {
        throw "Java dependency installation failed: $($_.Exception.Message). Logs: $logDirectory"
    }
    Remove-Item -LiteralPath $logDirectory -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host 'Microsoft OpenJDK installation completed. Checking Java...'
    # Search installation directories again: this process may still have the old PATH.
    $java = Find-Java ''
    if (-not $java) { throw 'OpenJDK installation completed, but Java 21+ was not found. Rerun with -j C:\path\to\java.exe.' }
    return $java
}
function Select-BurpVersion([string]$Requested, [string]$Directory, [bool]$NonInteractive) {
    if ($Requested) { return $Requested }
    if ($NonInteractive) {
        $localVersions = @(Get-ChildItem -LiteralPath $Directory -File | Where-Object {
            $_.Name -match '^burpsuite_(?:pro|desktop)_v\d{4}\.\d+(?:\.\d+)*\.jar$' -and (Test-Jar $_.FullName)
        } | ForEach-Object { $_.BaseName -replace '^burpsuite_(?:pro|desktop)_v', '' })
        if ($localVersions.Count) {
            return ($localVersions | Sort-Object { [version]($_ + $(if (($_ -split '\.').Count -eq 2) { '.0' })) } -Descending | Select-Object -First 1)
        }
        return $DefaultVersion
    }
    Write-Host 'Fetching available Burp Suite versions...'
    try { $versions = @(Get-BurpVersions -Count $Limit) } catch {
        Write-Warning "Could not fetch releases. See $ReleasesUrl or enter a version manually."
        $choice = Read-Host "Burp Suite version [$DefaultVersion]"
        if (-not $choice) { return $DefaultVersion }
        if ($choice -notmatch '^\d{4}\.\d+(\.\d+)*$') { throw 'Invalid version.' }
        return $choice
    }
    Write-Host 'Available Burp Suite versions (release channel):'
    Write-Host ('{0,-5} {1,-16} {2}' -f '', 'BURP VERSION', 'CHANNEL')
    for ($index = 0; $index -lt $versions.Count; $index++) { Write-Host (Format-ReleaseRow $versions[$index] "  $($index + 1)) ") }
    $choice = Read-Host 'Select a Burp Suite number, enter a version, or press Enter for the newest listed'
    if (-not $choice) { return $versions[0].Version }
    [int]$number = 0
    if ([int]::TryParse($choice, [ref]$number) -and $number -ge 1 -and $number -le $versions.Count) { return $versions[$number - 1].Version }
    if ($choice -notmatch '^\d{4}\.\d+(\.\d+)*$') { throw 'Invalid version.' }
    return $choice
}
function Get-BundledLoaders([string]$Directory = $PSScriptRoot) {
    $loaders = @(Get-ChildItem -LiteralPath $Directory -File | Where-Object { $_.Name -like '*loader*.jar' } | Sort-Object Name)
    if ($loaders.Count -eq 0) { throw 'Bundled loader missing. Restore it from the repository before installing.' }
    $loaders
}
function Select-Loader([string]$Directory, [bool]$NonInteractive) {
    $loaders = @(Get-BundledLoaders)
    $selected = $loaders | Where-Object Name -eq 'h3110w0r1d-y_loader.jar' | Select-Object -First 1
    if (-not $selected) { $selected = $loaders[0] }
    if (-not $NonInteractive -and $loaders.Count -gt 1) {
        for ($index = 0; $index -lt $loaders.Count; $index++) { Write-Host "  $($index + 1)) $($loaders[$index].Name)" }
        $choice = Read-Host "Select loader (Enter for $($selected.Name))"
        if ($choice) {
            [int]$number = 0
            if (-not [int]::TryParse($choice, [ref]$number) -or $number -lt 1 -or $number -gt $loaders.Count) { throw 'Invalid loader selection.' }
            $selected = $loaders[$number - 1]
        }
    }
    $target = Join-Path $Directory $selected.Name
    if ($selected.FullName -ne $target) { Copy-Item -LiteralPath $selected.FullName -Destination $target -Force }
    return $target
}
function Write-WindowsIcon([string]$Directory) {
    # Windows supports PNG image data inside an ICO container. Package the
    # existing icon using .NET only; no extra asset or image library is needed.
    $png = [IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'burpsuite-pro-icon.png'))
    if ($png.Length -lt 24 -or [BitConverter]::ToString($png, 0, 8) -ne '89-50-4E-47-0D-0A-1A-0A') {
        throw 'The bundled Burp icon is not a PNG image.'
    }
    $width = ($png[16] -shl 24) -bor ($png[17] -shl 16) -bor ($png[18] -shl 8) -bor $png[19]
    $height = ($png[20] -shl 24) -bor ($png[21] -shl 16) -bor ($png[22] -shl 8) -bor $png[23]
    if ($width -lt 1 -or $width -gt 256 -or $height -lt 1 -or $height -gt 256) {
        throw 'The bundled Burp icon must be between 1 and 256 pixels in each dimension.'
    }
    $stream = [IO.File]::Create((Join-Path $Directory 'burpsuite-pro-icon.ico'))
    $writer = New-Object IO.BinaryWriter($stream)
    try {
        $writer.Write([uint16]0) # Reserved
        $writer.Write([uint16]1) # Icon
        $writer.Write([uint16]1) # One image
        $writer.Write([byte]($width % 256)) # Zero represents 256 pixels
        $writer.Write([byte]($height % 256))
        $writer.Write([byte]0) # No palette
        $writer.Write([byte]0) # Reserved
        $writer.Write([uint16]1) # Color planes
        $writer.Write([uint16]32) # Bits per pixel
        $writer.Write([uint32]$png.Length)
        $writer.Write([uint32]22) # Image offset after header and directory entry
        $writer.Write([byte[]]$png)
    } finally { $writer.Dispose() }
}
function Write-Launcher([string]$Directory, [string]$Java, [string]$Jar, [string]$Loader) {
    $javaw = Join-Path (Split-Path $Java -Parent) 'javaw.exe'
    if (-not (Test-Path -LiteralPath $javaw -PathType Leaf)) {
        throw "Windowless Java executable missing: $javaw. Install a complete Java 21+ runtime."
    }
    Write-WindowsIcon $Directory
    $configuration = @{ Java = $Java; Javaw = $javaw; Jar = $Jar; Loader = $Loader }
    $configuration | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $Directory 'launcher.json') -Encoding UTF8
    $launcher = Join-Path $Directory 'burpsuite_pro_launcher.ps1'
    @'
$ErrorActionPreference = 'Stop'
$log = Join-Path $PSScriptRoot 'launcher.log'
try {
    $config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'launcher.json') -Raw | ConvertFrom-Json
    foreach ($path in @($config.Javaw, $config.Jar, $config.Loader)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required file missing: $path. Rerun the installer." }
    }
    $javaArguments = @('-noverify', '--add-opens=java.desktop/javax.swing=ALL-UNNAMED', '--add-opens=java.base/java.lang=ALL-UNNAMED', '--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED', '--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED', '--add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED', "-javaagent:$($config.Loader)", '-jar', $config.Jar) + $args
    # Start-Process joins arguments into one Windows command line. Escape quotes
    # and trailing backslashes so forwarded arguments and spaced paths survive.
    $commandLine = ($javaArguments | ForEach-Object {
        '"' + (($_ -replace '(\\*)"', '$1$1\"') -replace '(\\+)$', '$1$1') + '"'
    }) -join ' '
    Start-Process -FilePath $config.Javaw -ArgumentList $commandLine -WorkingDirectory $PSScriptRoot `
        -RedirectStandardOutput $log -RedirectStandardError (Join-Path $PSScriptRoot 'launcher-error.log') -ErrorAction Stop
} catch {
    $_ | Out-String | Add-Content -LiteralPath $log
    Write-Host "Burp failed to start: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
'@ | Set-Content -LiteralPath $launcher -Encoding UTF8
    return $launcher
}
function Write-Shortcut([string]$ShortcutPath, [string]$Launcher, [string]$Directory) {
    $parent = Split-Path -Path $ShortcutPath -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($ShortcutPath)
    $config = Get-Content -LiteralPath (Join-Path $Directory 'launcher.json') -Raw | ConvertFrom-Json
    $shortcut.TargetPath = $config.Javaw
    $shortcut.Arguments = '-noverify --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED "-javaagent:' + $config.Loader + '" -jar "' + $config.Jar + '"'
    $shortcut.WorkingDirectory = $Directory
    $shortcut.IconLocation = (Join-Path $Directory 'burpsuite-pro-icon.ico') + ',0'
    $shortcut.Description = 'Launch Burp Suite Professional'
    $shortcut.Save()
    if (-not (Test-Path -LiteralPath $ShortcutPath -PathType Leaf)) { throw "Could not create shortcut: $ShortcutPath" }
}
function Invoke-Installer {
    $ErrorActionPreference = 'Stop'
    if ($Help) { Show-Usage; return }
    # No package installation or directory changes for read-only listing.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    if ($ListVersions) {
        try {
            $releases = @(Get-BurpVersions -Count $Limit)
            '{0,-16} {1}' -f 'VERSION', 'CHANNEL'
            foreach ($release in $releases) { Format-ReleaseRow $release }
        } catch { throw "Could not list releases. Visit $ReleasesUrl or use -v VERSION. $($_.Exception.Message)" }
        return
    }
    if ($env:OS -ne 'Windows_NT') { throw 'This installer requires Windows. Use python3 install.py on Linux.' }
    $null = Get-BundledLoaders
    if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA 'BurpSuite-Pro' }
    $directory = [IO.Path]::GetFullPath($InstallDir)
    $java = Get-RequiredJava $JavaPath
    Write-Host "Using Java: $java"
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $selectedVersion = Select-BurpVersion $Version $directory ([bool]$Defaults)
    Write-Host "Installing Burp Suite $selectedVersion..."
    $jar = Join-Path $directory "burpsuite_pro_v$selectedVersion.jar"
    $alternative = Join-Path $directory "burpsuite_desktop_v$selectedVersion.jar"
    if (Test-Jar $jar) { Write-Host "Reusing $jar" }
    elseif (Test-Jar $alternative) { $jar = $alternative; Write-Host "Reusing $jar" }
    else { Save-BurpJar $jar $selectedVersion }
    $loader = Select-Loader $directory ([bool]$Defaults)
    $launcher = Write-Launcher $directory $java $jar $loader
    $programs = [Environment]::GetFolderPath('Programs')
    if (-not $programs) { throw 'Windows Start Menu Programs directory could not be found.' }
    $startMenuShortcut = Join-Path $programs 'BurpSuite Professional.lnk'
    Write-Shortcut $startMenuShortcut $launcher $directory
    if ($DesktopShortcut) { Write-Shortcut (Join-Path ([Environment]::GetFolderPath('Desktop')) 'BurpSuite Professional.lnk') $launcher $directory }
    Write-Host "Installation complete: Burp Suite $selectedVersion"
    Write-Host "Java: $java"
    Write-Host "Launcher: $launcher"
    Write-Host "Start Menu shortcut: $startMenuShortcut"
    Write-Host 'To launch: press the Windows key, type "BurpSuite Professional", and press Enter.'
    Write-Host 'You can also right-click the Start Menu result to pin it to Start or the taskbar.'
    Write-Host 'Activation: run these commands in PowerShell to open the selected loader:'
    Write-Host ("Set-Location -LiteralPath '" + $directory.Replace("'", "''") + "'")
    Write-Host ("& '" + $java.Replace("'", "''") + "' -jar '.\" + ([IO.Path]::GetFileName($loader)).Replace("'", "''") + "'")
    Write-Host 'Then follow the Activation guide in README.md.'
}
if ($MyInvocation.InvocationName -ne '.') {
    try { Invoke-Installer } catch { Write-Error "Installation failed: $($_.Exception.Message)"; exit 1 }
}
