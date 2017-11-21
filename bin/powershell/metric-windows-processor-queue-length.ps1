#
#   metric-windows-processor-queue-length.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs the Processor Queue Length in a Graphite acceptable format.
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
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-processor-queue-length.ps1
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
$instance_counter.CounterName = 'Processor Queue Length'

$Value = 1..10|%{$instance_counter.NextValue();sleep -m 100} | Measure-Object -Average |select -expand average
$value = [System.Math]::Round($value)

$Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

Write-Host "$Path.cpu.queue_length $Value $Time"
