<#

.SYNOPSIS

Powershell script to remotely collect data from target windows machines

.PARAMETER Remote
[OPTIONAL] List of IP or hostnames to run on separate machines

.PARAMETER Email
[OPTIONAL] If used, will prompt for email (only gmail works)

.PARAMETER Target
[OPTIONAL] If you have email, this is who to send it to

#>

# Parameters
Param([string]$Remote = "null",[switch]$Email=$false, [string]$Target=$false)

if ($Email) {
    $Creds = (Get-Credential -Message "Gmail credentials please!")
}

function collect() {

    $files = @()

    function prettyPrint($section, $obj) {
        Write-Host "####################"
        write-host ""$section
        write-host "####################"

        Write-host (($obj) | fl | out-string)
        $obj | Export-CSV ('./' + $section + '.csv')
        $files += ($section + '.csv')
    }



    ########################################
    # Time Information                     #
    ########################################

    $timeObject = New-Object PSObject

    $timeObject | Add-Member Date $(Get-Date)
    $timeObject | Add-Member Time-Zone $(Get-TimeZone)
    $timeObject | Add-Member Uptime $((get-date)-(gcim Win32_operatingsystem).LastBootUpTime)

    prettyPrint -section "Time Information" -obj $timeObject

    ########################################
    # OS Information                       #
    ########################################

    $osObj = New-Object PSObject

    $version = [System.Environment]::OSVersion.Version

    $osObj | Add-Member Typical-Name $(gwmi win32_operatingsystem | % caption)
    $osObj | Add-Member Version $version

    prettyPrint -section "OS Information" -obj $osObj

    ########################################
    # Hardware Information                 #
    ########################################

    $hardwareObj = New-Object PSObject

    $hardwareObj | Add-Member CPU $(gwmi win32_processor | % name)
    $hardwareObj | Add-member RAM $(gwmi win32_physicalmemoryarray | % maxcapacity)
    $hardwareObj | Add-member HDD $(gwmi win32_diskdrive | % size)
    $hardwareObj | add-member Drives $(gdr -PSProvider FileSystem | % Name)
    $hardwareObj | add-member Mounts $(gwmi win32_logicalDisk | % VolumeName)

    prettyPrint -section "Hardware Information" -obj $hardwareObj

    ########################################
    # Domain Controller Information        #
    ########################################

    $dcObj = New-Object psobject

    $domain = (Get-CimINSTANCE -ClassName wIN32_COMPUTERSystem).Partofdomain
    if($domain -eq $true){ 
        $dcObj | Add-Member Domain-Controller $(Get-ADDomainController)
    }
    else{
        $dcObj | Add-Member Domain-Controller "No Active Directory on this PC!"
    }
    prettyPrint -section "Domain Controller Information" -obj $dcObj

    ########################################
    # Hostname and Domain Information      #
    ########################################

    $hostnamedomainObj = new-object psobject

    $hostnamedomainObj | Add-Member "Host and Domain Info" ($((gwmi win32_computersystem | ft Name,Domain) | out-string))

    prettyPrint -section "Hostname and Domain Information" -obj $hostnamedomainObj

    ########################################
    # User Information                     #
    ########################################

    $userObj = new-object psobject

    $userObj | Add-Member "Users" ($(gwmi win32_useraccount | ft Name, SID | out-string))

    prettyPrint -section "User Information" -obj $userObj

    ########################################
    # Boot Information                     #
    ########################################

    $bootObj = New-Object psobject

    $bootObj | Add-Member "Services" ($(get-service | where {$_.StartType -eq 'Automatic'} | ft Name, DisplayName | out-string))
    $bootObj | Add-Member "Programs" ($(Get-CimInstance win32_startupcommand | ft Name,Command,User,Location | out-string))

    prettyPrint -section "Boot Information" -obj $bootObj

    ########################################
    # Schdeuled Tasks                      #
    ########################################

    $taskObj = new-object psobject

    $taskObj | Add-Member "Tasks:" ($(Get-Scheduledtask | where {$_.State -eq 'Ready'} | ft TaskName) | fl | out-string)

    prettyPrint -section "Scheduled Tasks" -obj $taskObj

    ########################################
    # Network Information                  #
    ########################################

    $netObj = New-Object psobject

    $netObj | Add-Member "Arp Table:" $(arp -a)

    $netObj | Add-Member "Mac Addresses:" ($(getmac) | fl | Out-String)

    $netObj | Add-Member "Routing Table:" ($(get-netroute) | fl | out-string)

    $netObj | Add-Member "IP Addr:" ($(get-netipaddress | ft IPAddress, InterfaceAlias) | fl | out-string)

    $netObj | Add-Member "DHCP:" ($(Get-WmiObject WIN32_NETWORKADAPTERCONFIGURATION | ? {$_.DHCPEnabled -eq $true -and $_.DHCPServer -ne $null} | select DHCPServer) | fl | out-string)

    $netObj | Add-Member "DNS:" ($(get-dnsclientserveraddress | select-object -expandproperty Serveraddresses) | fl | out-string)

    $netObj | Add-Member "IPv4 Gateway:" ($(get-netipconfiguration | % ipv4defaultgateway | fl nexthop) | fl | out-string)

    $netObj | Add-Member "IPV6 Gateway:" ($(get-netipconfiguration | % ipv6defaultgateway | fl nexthop) | fl | out-string)

    $netObj | Add-Member "Listening Services:" ($(get-nettcpconnection -state Listen | ft State, localport, ElementName, LocalAddress, RemoteAddress) | fl | out-string)

    $netObj | Add-Member "Established Connections:" ($(get-nettcpconnection | where {$_.State -ne "Listen"} | ft creationtime, LocalPort, LocalAddress, remoteaddress,owningprocess,state) | fl | out-string)

    $netObj | Add-Member "DNS Server:" ($(get-dnsclientcache | ft) | fl | out-string)

    $netObj | Add-Member "Network Shares:" ($(get-smbshare) | fl | out-string)

    $netObj | Add-Member "Printers:" ($(get-printer) | fl | out-string)

    $netObj | Add-Member "Wifi Access Profile:" ($(netsh.exe wlan show profiles) | fl | out-string)

    prettyPrint -section "Network Information" -obj $netObj

    ########################################
    # Installed Software                   #
    ########################################

    $softObj = New-Object psobject

    $softObj | Add-Member "Installed Software:" ($(gwmi win32_product | ft) | fl | out-string)

    prettyPrint -section "Installed Software" -obj $softObj

    ########################################
    # Processes Information                #
    ########################################

    $procObj = new-object psobject

    $procObj | Add-Member "Process Information" ($(Get-CimInstance -ClassName Win32_Process | Select-Object Name,ProcessID,ParentProcessID,Path,@{l='User';e={(Invoke-CimMethod -InputObject $_ -MethodName GetOwner).User}}) | fl | out-string)

    prettyPrint -section "Process Information" -obj $procObj

    ########################################
    # Driver List                          #
    ########################################

    $drivObj = new-object psobject

    $drivObj | Add-Member "Driver List" ($(Get-WindowsDriver -All -Online | Select-Object Name,BootCritical,Path,Version,Date,ProviderName) | fl | out-string)

    prettyPrint -section "Driver List" -obj $drivObj

    ########################################
    # Files in Documents and Downloads     #
    ########################################

	    $locals = Get-ChildItem -Path "C:\Users" | Select Name
	    $files = @()
	    foreach ($user in $locals){
		    try {
			    $path = ("C:\Users\" + $user.Name)
			    $downloads = Get-ChildItem -Path ($path + "\Downloads") | Select Name
			    $documents = Get-ChildItem -Path ($path + "\Documents") | Select Name
			    #make a few pretty objects to display
			    foreach ($download in $downloads) {
				    $file = New-Object PSObject
				    $file | Add-Member FileName $download.Name
				    $file | Add-Member Owner $user.Name
				    $file | Add-Member Folder ($path + "\Downloads")
				    $files += $file
			    }
			    foreach ($document in $documents) {
				    $file = New-Object PSObject
				    $file | Add-Member FileName $document.Name
				    $file | Add-Member Owner $user.Name
				    $file | Add-Member Folder ($path + "\Documents")
				    $files += $file
			    }
		    } catch {
			    Write-Host ("permission denied to " + $user)
		    }
	    }
	    prettyPrint -section "Files" -obj $files

    ########################################
    # Other Things                         #
    ########################################

    $otherObj = new-object psobject

    # Check for smb v1
    $otherObj | Add-Member SMB ($(get-smbserverconfiguration | Select-Object enablesmb1protocol | ft -AutoSize | out-string))
    $otherObj | Add-Member "Firewall Rules" ($(netsh advfirewall show allprofiles | out-string))
    $otherObj | Add-Member "USBs" ($(gwmi Win32_USBControllerDevice |%{[wmi]($_.Dependent)} | Sort Manufacturer,Description,DeviceID | Ft -GroupBy Manufacturer Description,Service,DeviceID | out-string))


    prettyPrint -section "Other Things" -obj $otherObj

    if ($Email -ne $false) {
		Write-Host "Attempting to send email ..."
		$files = $files | ? { $_ } | sort -uniq 
		Add-Type -Assembly System.IO.Compression.FileSystem
		$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
		[System.IO.Compression.ZipFile]::CreateFromDirectory($PSScriptRoot, "dfir.zip", $compressionLevel, $false)
		Send-MailMessage -Credential $Creds -From (($Creds.UserName) + '@gmail.com') -To $Target -Subject "DFIR CSV Output" -Attachments 'dfir.zip' -SmtpServer "smtp.gmail.com" -Port 587 -UseSsl $true
	}

}

collect
<#
if ($Remote -ne "null") {
    foreach ($remotes in $Remote -split ",") {
        $creds = Get-CRedential -Message $Remotes
        $session = New-PSSession -ComputerName $Remotes -Credential $Creds
        Invoke-Command -Session $session -SCriptblock ${function:collect}
        Remove-PSSession
    }

}
else {
    collect
}
#>