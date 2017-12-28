#
#   metric-windows-disk.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs all Disk/HDD Statistic in a Graphite acceptable format.
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
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-disk.ps1
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

$Category = 'PhysicalDisk'
$counters =  New-Object System.Collections.ArrayList
$instances =  @{}

[void]$counters.Add('Avg. Disk Bytes/Read')
[void]$counters.Add('Avg. Disk Bytes/Write')
[void]$counters.Add('Avg. Disk sec/Read')
[void]$counters.Add('Avg. Disk sec/Write')
[void]$counters.Add('Current Disk Queue Length')
[void]$counters.Add('Disk Transfers/sec')
[void]$counters.Add('Disk Reads/sec')
[void]$counters.Add('Disk Writes/sec')
[void]$counters.Add('Split IO/sec')

$perf_category = New-Object Diagnostics.PerformanceCounterCategory($Category)

foreach ($disk_instance in $perf_category.GetInstanceNames()) {

    if ($disk_instance.ToLower() -ne '_total') {

        $disk = $disk_instance
        $disk = $disk.Remove(0,1)
        $disk = $disk.Replace(":","")
        $disk = $disk.Trim()        
    }

    if ($disk_instance.ToLower() -ne '_total') {

        foreach ($counter in $counters) {

            $instance_counter = New-Object Diagnostics.PerformanceCounter
	        $instance_counter.CategoryName = $Category
            $instance_counter.InstanceName = $disk_instance
	        $instance_counter.CounterName = $counter

			if ($disk) { # Chek if DiskName is empty. Eg. StorageSpaces is used
                $diskname = $disk.ToString()
            }
            else {
                $diskname = $disk_instance.toString()
            }

            $Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

            $value = 1..10|%{$instance_counter.NextValue();sleep -m 100} | Measure-Object -Average |select -expand average

            if ($counter -eq 'Avg. Disk Bytes/Read') { Write-Host "$Path.disk.iostat.$diskname.read_bytes $value $Time" }
            if ($counter -eq 'Avg. Disk Bytes/Write') { Write-Host "$Path.disk.iostat.$diskname.write_bytes $value $Time" }
            if ($counter -eq 'Avg. Disk sec/Read') { Write-Host "$Path.disk.iostat.$diskname.read_await $value $Time" }
            if ($counter -eq 'Avg. Disk sec/Write') { Write-Host "$Path.disk.iostat.$diskname.write_await $value $Time" }
            if ($counter -eq 'Current Disk Queue Length') { Write-Host "$Path.disk.iostat.$diskname.queue_lenght $value $Time" }
			if ($counter -eq 'Avg. Disk Read Queue Length') { Write-Host "$Path.disk.iostat.$diskname.avg_read_queue_lenght $value $Time" }
            if ($counter -eq 'Avg. Disk Write Queue Length') { Write-Host "$Path.disk.iostat.$diskname.avg_read_queue_lenght $value $Time" }
            if ($counter -eq 'Disk Transfers/sec') { Write-Host "$Path.disk.iostat.$diskname.tranfers_sec $value $Time" }
            if ($counter -eq 'Disk Reads/sec') { Write-Host "$Path.disk.iostat.$diskname.reads_sec $value $Time" }
            if ($counter -eq 'Disk Writes/sec') { Write-Host "$Path.disk.iostat.$diskname.writes_sec $value $Time" }
            if ($counter -eq 'Split IO/sec') { Write-Host "$Path.disk.iostat.$diskname.split_io_sec $value $Time" }

        }

    }

}