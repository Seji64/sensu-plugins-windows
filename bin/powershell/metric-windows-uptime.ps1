#
#   metric-windows-uptime.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs the Uptime in seconds in a Graphite acceptable format.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Windows
#
# DEPENDENCIES:
#   Powershell
#
# USAGE:
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-uptime.ps1
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 sensu-plugins
#   Released under the same terms as Sensu (the MIT license); see LICENSE for details.
#

param(
    [switch]$UseFullyQualifiedHostname
    )

$ThisProcess = Get-Process -Id $pid
$ThisProcess.PriorityClass = "BelowNormal"

. (Join-Path $PSScriptRoot perfhelper.ps1)

if ($UseFullyQualifiedHostname -eq $false) {
    $Path = ($env:computername).ToLower()
}else{
    $Path = [System.Net.Dns]::GetHostEntry([string]"localhost").HostName.toLower()
}


$Category = 'System'
$instance_counter = New-Object Diagnostics.PerformanceCounter
$instance_counter.CategoryName = $Category
$instance_counter.CounterName = 'System Up Time'

$instance_counter.NextValue()
$value = $instance_counter.NextValue()
$value = [System.Math]::Truncate($value)

$Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

Write-Host "$Path.system.uptime $Value $Time"
