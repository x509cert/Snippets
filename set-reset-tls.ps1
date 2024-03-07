Set-StrictMode -Version Latest

# Set to $true to enable TLS 1.0, 1.1 and 1.2
$enableOldProtocols = $true

$base = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\'
$tlsVersions = @('TLS 1.0', 'TLS 1.1')

$enabledValue = if ($enableOldProtocols) { 1 } else { 0 }
$disabledByDefaultValue = if ($enableOldProtocols) { 0 } else { 1 }

foreach ($version in $tlsVersions) {
    $path = $base + $version + '\Server'
    New-Item $path -Force | Out-Null

    # Create or set the 'Enabled' property
    New-ItemProperty -Path $path `
                     -Name 'Enabled' `
                     -Value $enabledValue `
                     -PropertyType 'DWord' `
                     -Force | Out-Null
                     
    if ($enableOldProtocols) {
        Write-Host "$version is Enabled."
    } else {
        Write-Host "$version is Disabled."
    }
}

