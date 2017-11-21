#
#   metric-windows-system.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs some System Perfomance Counters in a Graphite acceptable format.
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
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-sytem.ps1
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

$Category = 'Processor Information'
$instance_counter = New-Object Diagnostics.PerformanceCounter
$instance_counter.CategoryName = $Category
$instance_counter.InstanceName = '_total'
$instance_counter.CounterName = 'Interrupts/sec'

$value_interrupt = 1..10|%{$instance_counter.NextValue();sleep -m 100} | Measure-Object -Average |select -expand average
$value_interrupt = [System.Math]::Round($value_interrupt)


$Category = 'System'
$instance_counter = New-Object Diagnostics.PerformanceCounter
$instance_counter.CategoryName = $Category
$instance_counter.CounterName = 'Context Switches/sec'

$value_context = 1..10|%{$instance_counter.NextValue();sleep -m 100} | Measure-Object -Average |select -expand average
$value_context = [System.Math]::Round($value_context)

$Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

Write-Host "$Path.system.irq_per_second $value_interrupt $Time"
Write-Host "$Path.system.context_switches_per_second $value_context $Time"