#
#   metric-windows-network.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs all Network Adapater Statistic in a Graphite acceptable format.
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
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-network.ps1
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 sensu-plugins
#   Released under the same terms as Sensu (the MIT license); see LICENSE for details.
#

param(
    [string[]]$Interfaces,
    [switch]$UseFullyQualifiedHostname
    )

$ThisProcess = Get-Process -Id $pid
$ThisProcess.PriorityClass = "BelowNormal"

. (Join-Path $PSScriptRoot perfhelper.ps1)

if ($UseFullyQualifiedHostname -eq $false) {
    $Hostname = ($env:computername).ToLower()
}else{
    $Hostname = [System.Net.Dns]::GetHostEntry([string]"localhost").HostName.toLower()
}

for($i = 0; $i -lt $Interfaces.Count; $i+=1) {
    $tmp = $Interfaces[$i]
    $Interfaces[$i] = $tmp.Replace("_"," ")
}

$Category = 'Network Interface'
$perf_category = New-Object Diagnostics.PerformanceCounterCategory($Category)

foreach ($interface_instance in $perf_category.GetInstanceNames()) {

    if ($Interfaces.Contains($interface_instance)) {

       foreach($counter in $perf_category.GetCounters($interface_instance)) {
            
            $countername =  $counter.CounterName -replace "\\","." -replace " ","_" -replace "[(]","." -replace "[)]","" -replace "[\{\}]","" -replace "[\[\]]","" -replace "/sec","per_second" -replace ":",""
            $instancename = $counter.InstanceName -replace "\\","." -replace " ","_" -replace "[(]","." -replace "[)]","" -replace "[\{\}]","" -replace "[\[\]]","" -replace ":",""

            $Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

            $value = 1..10|%{$counter.NextValue();sleep -m 100} | Measure-Object -Average |select -expand average
            $value = [System.Math]::Round($value)

            $Path = $Hostname+'.interface.'+$instancename+'.'+$countername
            $Path = $Path.ToLower()

            Write-Host "$Path $Value $Time"

       }

    }

}