<#
#>
param(
    [Parameter(Mandatory = $false)]
    [string]$db_instance,
	
	[Parameter(Mandatory = $false)]
    [string]$db_username,
	
	[Parameter(Mandatory = $false)]
    [string]$db_password
)

Write-Verbose "SSRS Config"

function Get-ConfigSet() {
    return Get-WmiObject -namespace "root\Microsoft\SqlServer\ReportServer\RS_SSRS\v14\Admin" -class MSReportServer_ConfigurationSetting -ComputerName localhost
}

# Allow importing of sqlps module
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Retrieve the current configuration
$configset = Get-ConfigSet

$configset

If (! $configset.IsInitialized) {
    # Get the ReportServer and ReportServerTempDB creation script
    [string]$dbscript = $configset.GenerateDatabaseCreationScript("ReportServer", 1033, $false).Script

    # Import the SQL Server PowerShell module
	Import-Module SqlServer
	
    #  
    # Loads the SQL Server Management Objects (SMO)  
    #  
    $assemblylist =   
      "Microsoft.SqlServer.Management.Common",  
      "Microsoft.SqlServer.Smo",  
      "Microsoft.SqlServer.Dmf ",  
      "Microsoft.SqlServer.Instapi ",  
      "Microsoft.SqlServer.SqlWmiManagement ",  
      "Microsoft.SqlServer.ConnectionInfo ",  
      "Microsoft.SqlServer.SmoExtended ",  
      "Microsoft.SqlServer.SqlTDiagM ",  
      "Microsoft.SqlServer.SString ",  
      "Microsoft.SqlServer.Management.RegisteredServers ",  
      "Microsoft.SqlServer.Management.Sdk.Sfc ",  
      "Microsoft.SqlServer.SqlEnum ",  
      "Microsoft.SqlServer.RegSvrEnum ",  
      "Microsoft.SqlServer.WmiEnum ",  
      "Microsoft.SqlServer.ServiceBrokerEnum ",  
      "Microsoft.SqlServer.ConnectionInfoExtended ",  
      "Microsoft.SqlServer.Management.Collector ",  
      "Microsoft.SqlServer.Management.CollectorEnum",  
      "Microsoft.SqlServer.Management.Dac",  
      "Microsoft.SqlServer.Management.DacEnum",  
      "Microsoft.SqlServer.Management.Utility",
      "Microsoft.SqlServer.Management.Smo"
    foreach ($asm in $assemblylist)  
    {  
      $asm = [Reflection.Assembly]::LoadWithPartialName($asm)  
    }

    # Establish a connection to the database server (remote host)
    $conn = New-Object Microsoft.SqlServer.Management.Common.ServerConnection -ArgumentList $env:ComputerName
    $conn.ApplicationName = "SCOB Script"
    $conn.StatementTimeout = 0
    $conn.ConnectTimeout = 30
    $conn.LoginSecure = $FALSE
    $conn.Login = $db_username
    $conn.Password = $db_password
    $conn.ServerInstance = $db_instance
    $conn.Connect()
    $smo = New-Object Microsoft.SqlServer.Management.Smo.Server($conn)

    # Select SSRS SQL database
    $db = $smo.Databases["master"]

    # Set "NT AUTHORITY\NetworkService" user role in database
    $ssrs_svc_acct_role_script = [IO.File]::ReadAllText(".\ssrs_svc_account_setup.sql")
    $db.ExecuteNonQuery($ssrs_svc_acct_role_script)

    # Create the ReportServer and ReportServerTempDB databases
    $db.ExecuteNonQuery($dbscript)
    
    # Set "NT AUTHORITY\NetworkService" RSExc role in SSRS database
    $ssrs_svc_acct_role_script = [IO.File]::ReadAllText(".\ssrs_svc_rsexec_role.sql")
    $db.ExecuteNonQuery($ssrs_svc_acct_role_script)

    # Set permissions for the databases
    # Reference: https://docs.microsoft.com/en-us/sql/reporting-services/wmi-provider-library-reference/configurationsetting-method-generatedatabaserightsscript?view=sql-server-2017
    #
    # UserName - The user name or Windows security identifier (SID) of the user to which the script will grant rights.
    #    
    #            (S-1-5-18)                  :  Local System        <Domain>\<ComputerName>$
    #            .\LocalSystem               :  Local System        <Domain>\<ComputerName>$
    #            ComputerName\LocalSystem    :  Local System        <Domain>\<ComputerName>$
    #            LocalSystem                 :  Local System        <Domain>\<ComputerName>$
    #            (S-1-5-20)	                 :  Network Service     <Domain>\<ComputerName>$
    #            NT AUTHORITY\NetworkService :  Network Service     <Domain>\<ComputerName>$
    #            (S-1-5-19)	Local Service    :  Error - see below.
    #            NT AUTHORITY\LocalService   :  Local Service       Error - see below.	
    #
    # DatabaseName - The database name to which the script will grant access to the user.
    #
    # IsRmote - A Boolean value to indicating whether the database is remote from the report server.
    #
    # IsWindowUser - A Boolean value indicating whether the specified user name is a Windows user or a SQL Server user.
    #
    #$dbscript = $configset.GenerateDatabaseRightsScript($configset.WindowsServiceIdentityConfigured, "ReportServer", $false, $true).Script
    $dbscript = $configset.GenerateDatabaseRightsScript("NT AUTHORITY\NetworkService", "ReportServer", $true, $true).Script
    $db.ExecuteNonQuery($dbscript)

    # Set the database connection info
    # Reference: https://docs.microsoft.com/en-us/sql/reporting-services/wmi-provider-library-reference/configurationsetting-method-setdatabaseconnection?view=sql-server-2017
    # The type of credentials to use for the connection. Values can be:
    # 0 - Windows
    # 1 - SQL Server
    # 2 - Windows Service
    $credentials_type = 1
    #$configset.SetDatabaseConnection("(local)", "ReportServer", 2, "", "")
    $configset.SetDatabaseConnection($db_instance, "ReportServer", $credentials_type, $db_username, $db_password)

    $configset.SetVirtualDirectory("ReportServerWebService", "ReportServer", 1033)
    $configset.ReserveURL("ReportServerWebService", "http://+:80", 1033)

    # Did the name change?
    $configset.SetVirtualDirectory("ReportServerWebApp", "Reports", 1033)
    $configset.ReserveURL("ReportServerWebApp", "http://+:80", 1033)

    $configset.InitializeReportServer($configset.InstallationID)

    # Re-start services?
    $configset.SetServiceState($false, $false, $false)
    Restart-Service $configset.ServiceName
    $configset.SetServiceState($true, $true, $true)

    # Update the current configuration
    $configset = Get-ConfigSet

    $configset.IsReportManagerEnabled
    $configset.IsInitialized
    $configset.IsWebServiceEnabled
    $configset.IsWindowsServiceEnabled
    $configset.ListReportServersInDatabase()
    $configset.ListReservedUrls();

    $inst = Get-WmiObject -namespace "root\Microsoft\SqlServer\ReportServer\RS_SSRS\v14" -class MSReportServer_Instance -ComputerName localhost

    $inst.GetReportServerUrls()
}