param(
    [Parameter(Mandatory = $false)]
    [string]$db_instance,

    [Parameter(Mandatory = $false)]
    [string]$db_username,

    [Parameter(Mandatory = $false)]
    [string]$db_password,

    [Parameter(Mandatory = $true)]
    [string]$ssrs_user,

    [Parameter(Mandatory = $true)]
    [string]$ssrs_password
)

Write-Verbose "SSRS Config"
.\configureSSRS2017 -db_instance $db_instance -db_username $db_username -db_password $db_password -Verbose

Write-Verbose "Setup SSRS user"
.\newadmin -username $ssrs_user -password $ssrs_password -Verbose

$lastCheck = (Get-Date).AddSeconds(-2) 
while ($true) { 
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message	 

    $lastCheck = Get-Date
    Start-Sleep -Seconds 2 
}
