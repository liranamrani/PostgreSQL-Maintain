function Download-PostgreSQL {
 #Add here new versions if needed.
   $versions = @(
        @("v13.3","https://get.enterprisedb.com/postgresql/postgresql-13.3-2-windows-x64-binaries.zip"),
        @("v12.7","https://get.enterprisedb.com/postgresql/postgresql-12.7-2-windows-x64-binaries.zip")
    )

    #Count for menu.
    $count = 1 
    foreach ($versionAvailable in $versions)
    {
    write-host $count ": Press '" $count "' for Download PostgresSQL Version - " $versions[$count-1][0]
    $count = $count+1
    }

    #Get Valid Input from user
    DO
    {

     $selection = Read-Host "Please make a selection"

    } Until ($selection -le $versions.Count -and $selection -gt 0)
    
   
    $fileName = (".\postgreSQL-" + $versions[$selection-1][0] + ".zip")
    Write-host "----Download PostgreSQL Version----"
    Invoke-WebRequest -Uri $versions[$selection-1][1] -OutFile $fileName

    
}

# take from https://feilerdev.wordpress.com/2017/12/05/installing-postgresql-on-windows-using-zip-archive-without-the-installer/
function Install-PostgreSQL {
$defaultValue = 'localhost'
    if (!($serverName = Read-Host "Please Enter ServerName(Or Ip Address) [Or Enter Nothing for $defaultValue]")) { $serverName = $defaultValue }
    #$serverName = Read-Host 'Please Enter ServerName(Or Ip Address)'    
    $versionsAvailable = Get-ChildItem -Path .\Post*.zip | select Name,FullName

        #Count for menu.
    $count = 1 
    foreach ($version in $versionsAvailable)
    {
    write-host $count ": Press '" $count "' for Extract and Install - " $version.Name
    $count = $count+1
    }

    #Special Section for the options that postgreSQL is already installed in remote machine.
    if (Test-Path "\\$serverName\C$\temp\pgsql\bin\psql.exe")
    {
    $installedVersion = .\checkPostgreSQLVersion.ps1
    write-host $count ": Press '" $count "' for Install Current Extracted Version [ $installedVersion ] without extracting new version" 
    }
    #Get Valid Input from user
    DO
    {

     $selection = Read-Host "Please make a selection"

    } Until ($selection -le $count)
    if ($selection -ne $count){
    # choose File to Unzip
    $path = $versionsAvailable.FullName[$selection-1]




    Write-host "----Unzip PostgreSQL Version----"
    # C:\temp folder just as example..
    Expand-Archive -LiteralPath $path -DestinationPath "\\$serverName\c$\temp\" -Force
    }

    #backup data folder if existed
    if (Test-Path "\\$serverName\C$\temp\pgsql\data\")
    {
    Write-host "----Backup PostgreSQL Data Folder----"
       if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -ScriptBlock {"c:\temp\pgsql\bin\pg_dumpall > backupFile "}
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -ScriptBlock {"Remove-Item -Path 'C:\temp\pgsql\data -Recurse'"}
    }
    else
    {
    c:\temp\pgsql\bin\pg_dumpall > backupFile.sql 
    }
    Write-Host "Backup completed."
   
       Remove-Item -Path "C:\temp\pgsql\data" -Recurse 
    }

    Write-host "----Install PostgreSQL Version----"
    cd $PSScriptRoot
    #Invoke-Command  -ComputerName $serverName -ScriptBlock {"c:\temp\pgsql\bin\initdb.exe -D c:\temp\pgsql\data –username=aidocapp --pwfile=<(echo aidcopass)  –auth=trust"}

    #$secureString = 'PlainTextp@ssw0rd' | ConvertTo-SecureString -AsPlainText -Force
    #$credential = New-Object pscredential('USERNAME', $secureString)
    if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -FilePath ".\installPostgreSQL.ps1" 
    Start-PostgreSQL

    }
    else
    {
    powershell ".\installPostgreSQL.ps1"
    Start-PostgreSQL
    }

}

function Get-Info-EOL{
      $url = 'https://www.postgresql.org/support/versioning/'
      $r = Invoke-WebRequest $url
      cd $PSScriptRoot
      Get-WebRequestTable.ps1 $r -TableNumber 0 | Format-Table -Auto 
}

function Get-Avilable-Versions {
$url = 'https://www.postgresql.org/ftp/source/'
      $r = Invoke-WebRequest $url
      cd $PSScriptRoot
      Get-WebRequestTable.ps1 $r -TableNumber 0 | Format-Table -Auto
      }

function Get-PostgreSQL-Version {
 $defaultValue = 'localhost'
    if (!($serverName = Read-Host "Please Enter ServerName(Or Ip Address) [Or Enter Nothing for $defaultValue]")) { $serverName = $defaultValue }
    #$serverName = Read-Host 'Please Enter ServerName(Or Ip Address)'    
    if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -FilePath ".\checkPostgreSQLVersion.ps1" 
    }
    else
    {
    powershell ".\checkPostgreSQLVersion.ps1"
    }
}

function Start-PostgreSQL {
 $defaultValue = 'localhost'
    if (!($serverName = Read-Host "Please Enter ServerName(Or Ip Address) [Or Enter Nothing for $defaultValue]")) { $serverName = $defaultValue }
    #$serverName = Read-Host 'Please Enter ServerName(Or Ip Address)'    
    if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -ScriptBlock {"C:\temp\pgsql\bin\pg_ctl.exe start -D C:\temp\pgsql/data"} 
    }
    else
    {
    C:\temp\pgsql\bin\pg_ctl.exe start -D C:\temp\pgsql/data
    }
}
function Stop-PostgreSQL {
 $defaultValue = 'localhost'
    if (!($serverName = Read-Host "Please Enter ServerName(Or Ip Address) [Or Enter Nothing for $defaultValue]")) { $serverName = $defaultValue }
    #$serverName = Read-Host 'Please Enter ServerName(Or Ip Address)'    
    if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -ScriptBlock {"C:\temp\pgsql\bin\pg_ctl.exe stop -D C:\temp\pgsql/data"} 
    }
    else
    {
    C:\temp\pgsql\bin\pg_ctl.exe stop -D C:\temp\pgsql/data
    }
}

function Create-AIdoc-user-and-db {
$defaultValue = 'localhost'
    if (!($serverName = Read-Host "Please Enter ServerName(Or Ip Address) [Or Enter Nothing for $defaultValue]")) { $serverName = $defaultValue }
    #$serverName = Read-Host 'Please Enter ServerName(Or Ip Address)'    
    if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -ScriptBlock {"C:\temp\pgsql\bin\createuser.exe -s aidocapp"}
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -ScriptBlock {"C:\temp\pgsql\bin\createdb.exe aidocapp"} 
    }
    else
    {
    C:\temp\pgsql\bin\createuser.exe -s aidocapp
    C:\temp\pgsql\bin\createdb.exe aidocapp

    }
}

function Connect-Aidoc-DB {

$defaultValue = 'localhost'
    if (!($serverName = Read-Host "Please Enter ServerName(Or Ip Address) [Or Enter Nothing for $defaultValue]")) { $serverName = $defaultValue }
    #$serverName = Read-Host 'Please Enter ServerName(Or Ip Address)'    
    if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -ScriptBlock {"C:\temp\pgsql\bin\psql.exe --username=aidocapp"}
    }
    else
    {
    C:\temp\pgsql\bin\psql.exe --username=aidocapp
    }

}

function Backup-DB{

$defaultValue = 'localhost'
    if (!($serverName = Read-Host "Please Enter ServerName(Or Ip Address) [Or Enter Nothing for $defaultValue]")) { $serverName = $defaultValue }
    #$serverName = Read-Host 'Please Enter ServerName(Or Ip Address)'    
    if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -ScriptBlock {"c:\temp\pgsql\bin\pg_dumpall > backupFile "}
    }
    else
    {
    c:\temp\pgsql\bin\pg_dumpall > backupFile.sql 
    }
    Write-Host "Backup completed."
   
}


function Show-Menu {
    param (
        [string]$Title = 'PostgreSQL Maintain'
    )
    Clear-Host
Write-Host "Created By Liran Amrani"
    Write-Host "================ $Title ================"
    Write-Host "1: Press '1' for Download PostgresSQL Version."
    Write-Host "2: Press '2' for Install PostgresSQL Version"
    Write-Host "3: Press '3' for Getting information about EOL"
    Write-Host "4: Press '4' for Getting list of Available Versions"
    Write-Host "5: Press '5' for Check installed Version Number"
    Write-Host "6: Press '6' for Start PostgreSQL"
    Write-Host "7: Press '7' for Stop PostgreSQL"
    Write-Host "8: Press '8' for Create AIdoc user and db"
    Write-Host "9: Press '9' for Connecting to AIdoc db"
    Write-Host "10: Press '10' for Backup"
    Write-Host "Q: Press 'Q' to quit."
    Write-Host "#PLEASE NOTICE - For Commands on remote machine - WinRM must be Available"
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
    Download-PostgreSQL
  
    } '2' {
    Install-PostgreSQL


    } '3' {
    Get-Info-EOL

    }
    '4' {
    Get-Avilable-Versions

    }
        '5' {
    Get-PostgreSQL-Version

    }
            '6' {
    Start-PostgreSQL

    }
            '7' {
    Stop-PostgreSQL

    }
            '8' {
    Create-AIdoc-user-and-db

    }
            '9' {
    Connect-Aidoc-DB

    }
                '10' {
    Backup-DB

    }

    }
    pause
 }
 until ($selection -eq 'q')







