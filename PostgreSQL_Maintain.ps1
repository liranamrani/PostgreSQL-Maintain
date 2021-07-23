

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
    Write-Host "Q: Press 'Q' to quit."
}
do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {

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

    } Until ($selection -le $versions.Count)
    
   
    $fileName = (".\postgreSQL-" + $versions[$selection-1][0] + ".zip")
    Write-host "----Download PostgreSQL Version----"
    Invoke-WebRequest -Uri $versions[$selection-1][1] -OutFile $fileName

    
    } '2' {

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

    #Get Valid Input from user
    DO
    {

     $selection = Read-Host "Please make a selection"

    } Until ($selection -le $versionsAvailable.Count)
    # choose File to Unzip
    $path = $versionsAvailable.FullName[$selection-1]

    Write-host "----Unzip PostgreSQL Version----"
    # C:\temp folder just as example..
    Expand-Archive -LiteralPath $path -DestinationPath "\\$serverName\c$\temp\" -Force
    Write-host "----Install PostgreSQL Version----"
    cd $PSScriptRoot
    #Invoke-Command  -ComputerName $serverName -ScriptBlock {"c:\temp\pgsql\bin\initdb.exe -D c:\temp\pgsql\data –username=aidocapp --pwfile=<(echo aidcopass)  –auth=trust"}

    $secureString = 'PlainTextp@ssw0rd' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object pscredential('USERNAME', $secureString)
    if ($serverName -ne "localhost")
    {
    Invoke-Command  -ComputerName $serverName -Authentication NegotiateWithImplicitCredential  -FilePath ".\installPostgreSQL.ps1" 
    }
    else
    {
    powershell ".\installPostgreSQL.ps1"
    }



    } '3' {
      $url = 'https://www.postgresql.org/support/versioning/'
      $r = Invoke-WebRequest $url
      cd $PSScriptRoot
      Get-WebRequestTable.ps1 $r -TableNumber 0 | Format-Table -Auto

    }
    '4' {
      $url = 'https://www.postgresql.org/ftp/source/'
      $r = Invoke-WebRequest $url
      cd $PSScriptRoot
      Get-WebRequestTable.ps1 $r -TableNumber 0 | Format-Table -Auto

    }
    }
    pause
 }
 until ($selection -eq 'q')