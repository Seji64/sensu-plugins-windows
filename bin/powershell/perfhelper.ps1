#
#   perfhelper.ps1
#
# DESCRIPTION:
#   This is file provides useful functions for powershell based metric checks
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
#   To use these functions dot source this file. 
#	Example: . (Join-Path $PSScriptRoot perfhelper.ps1)
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 sensu-plugins
#   Released under the same terms as Sensu (the MIT license); see LICENSE for details.
#

Function DateTimeToUnixTimestamp([datetime]$DateTime)
{
    $utcDate = $DateTime.ToUniversalTime()
    # Convert to a Unix time without any rounding
    [uint64]$UnixTime = [double]::Parse((Get-Date -Date $utcDate -UFormat %s))
    return [uint64]$UnixTime
}