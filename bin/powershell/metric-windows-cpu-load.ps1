#
#   metric-windows-cpu-load.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs the CPU Usage in a Graphite acceptable format.
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
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-cpu-load.ps1
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
}else {
    $Path = [System.Net.Dns]::GetHostEntry([string]"localhost").HostName.toLower()
}

$Category = 'Processor Information'
$counters =  New-Object System.Collections.ArrayList

[void]$counters.Add('% Processor Time')
[void]$counters.Add('% Idle Time')
[void]$counters.Add('% User Time')
[void]$counters.Add('% Interrupt Time')

foreach ($counter in $counters) {

	$instance_counter=New-Object Diagnostics.PerformanceCounter
	$instance_counter.CategoryName = $Category
    $instance_counter.InstanceName = '_total'
	$instance_counter.CounterName = $counter

	$Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

	$value = 1..10|%{$instance_counter.NextValue();sleep -m 100} | Measure-Object -Average |select -expand average

	if ($counter -eq '% Processor Time') { Write-Host "$Path.cpu.percent.total $value $Time" }
	if ($counter -eq '% Idle Time') { Write-Host "$Path.cpu.percent.idle $value $Time" }
	if ($counter -eq '% User Time') { Write-Host "$Path.cpu.percent.user $value $Time" }
	if ($counter -eq '% Interrupt Time') { Write-Host "$Path.cpu.percent.user $value $Time" }


}