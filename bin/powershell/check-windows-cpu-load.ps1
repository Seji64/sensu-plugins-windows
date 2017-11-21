#
#   check-windows-cpu-load.ps1
#
# DESCRIPTION:
#   This plugin collects the CPU Usage and compares against the WARNING and CRITICAL thresholds.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Windows
#
# DEPENDENCIES:
#   Powershell 3.0 or above
#
# USAGE:
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\check-windows-cpu-load.ps1 90 95
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 sensu-plugins
#   Released under the same terms as Sensu (the MIT license); see LICENSE for details.
#

#Requires -Version 3.0

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [int]$WARNING,

   [Parameter(Mandatory=$True,Position=2)]
   [int]$CRITICAL
)

. (Join-Path $PSScriptRoot perfhelper.ps1)

$ThisProcess = Get-Process -Id $pid
$ThisProcess.PriorityClass = "BelowNormal"

$Category = 'Processor Information'

$instance_counter = New-Object Diagnostics.PerformanceCounter
$instance_counter.CategoryName = $Category
$instance_counter.InstanceName = '_total'
$instance_counter.CounterName = '% Processor Time'

$value = 1..5|%{$instance_counter.NextValue();sleep -m 100} | Measure-Object -Average |select -expand average
$value = [System.Math]::Round($value)

If ($value -gt $CRITICAL) {
  Write-Host CheckWindowsCpuLoad CRITICAL: CPU at $Value%.
  Exit 2 }

If ($value -gt $WARNING) {
  Write-Host CheckWindowsCpuLoad WARNING: CPU at $Value%.
  Exit 1
}

Else {
  Write-Host CheckWindowsCpuLoad OK: CPU at $Value%.
  Exit 0 
}
