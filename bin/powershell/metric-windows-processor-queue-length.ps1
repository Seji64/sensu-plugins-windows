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
$ThisProcess = Get-Process -Id $pid
$ThisProcess.PriorityClass = "BelowNormal"

. (Join-Path $PSScriptRoot perfhelper.ps1)

# Select here whether the hostname is to be printed with or without domain
# Default: Without Domain
# With Domain:
# $Path = [System.Net.Dns]::GetHostEntry([string]"localhost").HostName.toLower()

$Path = ($env:computername).ToLower() 

$Value = (Get-WmiObject Win32_PerfFormattedData_PerfOS_System).ProcessorQueueLength
$Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

Write-Host "$Path.cpu.queue_length $Value $Time"
