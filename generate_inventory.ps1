param ([switch]$help, $user, $ifile, $ofile)

$currentDirectory = (Get-Location).Path
Import-Module $currentDirectory\Get-VMHostWSManInstance.psm1
Import-Module VMware.VimAutomation.Core

#HELP FUNCTION
function Help_fn(){ 

	write-host ""
	write-host "----------------------------HELP------------------------------------"
	write-host ""
	write-host "-user		[Mention the user]"
	write-host ""
	write-host "-ifile		[Mention the file path of IP addresses file]"
	write-host "		[For Example: C:\path\to\file.txt]"
	write-host ""
	write-host "-ofile		[Mention the CSV output file]"
	write-host "		[For Example: C:\path\to\file.csv]"
	write-host ""
	write-host "-help		[For Help]"
	write-host ""
	write-host ""
	write-host "***"
	write-host "Example Commands"
	write-host "PowerCLI C:\Users\user\Desktop> .\generate_inventory.ps1 -help"
	write-host "PowerCLI C:\Users\user\Desktop> .\generate_inventory.ps1 -user username -ifile C:\path\to\file.txt -ofile C:\path\to\file.csv"
	write-host "***"
	write-host ""
	write-host ""
	write-host "<!> WARNING <!>"
	write-host "<!> Please ensure to specify the correct password, if the password is not correct then"
	write-host "<!> after running this script continously with incorrect password may cause locking of your"
	write-host "<!> account on hypervisor"
	write-host ""
	write-host ""
}

#CREATE OUTPUT FILE
function Create_file($outputfile){

    #SETTING THE HEADER FIELDS OF THE OUTPUT FILE
	$ADDLINE = "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}" -f "Zone Type", "Hostname", "Server Model", "Serial #", "Category", "Version", "vCPUs", "Processor", "Memory (GB)", "DISK (GB)", "Storage Path", "ILOM IP", "IP Address"
	$ADDLINE | add-content -path $outputfile

}

function ServerInfo($inputfile, $outputfile, $credential){

    

	foreach($serverIPAddress in [System.IO.File]::ReadLines($inputfile))
	{
		#CONNECT TO SERVER ESXI HYPERVISOR {ALSO CHECK THE CONNECTIVITY}
        if (Connect-VIServer $serverIPAddress -cred $credential)
        {
            #GETTING THE SERVER AND ILOM INFORMATION
            $serverInfo = Get-VMHost $serverIPAddress
		    $serverHostname = $serverInfo.NetworkInfo.HostName
		    $model = $serverInfo.Model
		    #$serialTag = (Get-VMHost $serverIPAddress | Get-View).Summary.Hardware.OtherIdentifyingInfo[1].IdentifierValue
            #$serialTag = ((($serverInfo | Get-View).Summary.Hardware.OtherIdentifyingInfo | select IdentifierValue).IdentifierValue -join "") -replace "To Be Filled By O.E.M.", ""
            $serialTag = ""
            #WE HAVE THE LIST IN WHICH TAGS REPEAT OR ON THE LAST OR OTHER RAW INFORMATION. SO WE HAVE TO PARSE IT 
            $stringTags = ((($serverInfo | Get-View).Summary.Hardware.OtherIdentifyingInfo | select IdentifierValue).IdentifierValue -join ";")
            $stringTags.Split(";") | ForEach {
            
            	$temp_tag = $_
            	
            	if($temp_tag -match '^[0-9A-Z]+$'){ # REGEX TO GET THE VALID TAG 
            		$serialTag = $temp_tag
                    #break
            	}
            }

            if([string]::IsNullOrEmpty($serialTag)){$serialTag="Tag Not Found"} #CHECK IF THE TAG FOUND OR NOT

		    $version = $serverInfo.Version
		    $vCPUs = $serverInfo.NumCpu
		    $processorType = $serverInfo.ProcessorType
		    $memoryInfo = $serverInfo.MemoryTotalGB
		    $storagePath = (get-datastore | select-object -property Name).Name -join " | "
		    $storageCapacity = (get-datastore | select-object -property CapacityGB).CapacityGB -join " | "
            
            #CALLING THE ABOVE IMPORT MODULE FOR GETTING THE ILOM IP ADDRESS
            try {

                $info = Get-VMHostWSManInstance -VMHost (Get-VMHost $serverIPAddress) -ignoreCertFailures -class OMC_IPMIIPProtocolEndpoint
                $ilomIPAddress = $info.IPv4Address
            
            }
            catch
            {
                Write-Output $serverIPAddress
                Write-Warning -Message "Get-VMHostWSManInstance : Current license or ESXi version prohibits execution of the requested operation. {ILOM IP NOT FOUND}" 
                $info = ""
                $ilomIPAddress = ""
            }
		    
            if([string]::IsNullOrEmpty($ilomIPAddress)){$ilomIPAddress="IP Not Found"}
		    
		    #ADDING SERVER AND ILOM INFORMATION IN FILE
		    $ADDLINE = "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}" -f "Global", $serverHostname, $model, $serialTag, "Server", $version, $vCPUs, $processorType, $memoryInfo, $storageCapacity, $storagePath, $ilomIPAddress, $serverIPAddress
		    $ADDLINE | add-content -path $outputfile

		    
            try {
                #GET THE LIST OF RUNNING VM'S ON HYPERVISOR IN STRING
                #$listOfRunVMs = ((Get-VMGuest *).where{$_.State -eq 'Running'} | Select-Object -Property HostName).HostName -join ";"
                #VM'S HOSTNAME COULD NOT BE DIRECT USED WITH CMDLETS TO FIND THE STATUS, IT SHOULD BE
                #THE VM'S NAME THAT CAN GIVE THE STATUS OF THE MACHINES {OMIT THE ABOVE CMDLET}
                $runningVMs = (Get-VMGuest *).where{$_.State -eq 'Running'} 
                $listOfRunVMs = $runningVMs.VM -join ";"
                #SPLITTING AND ITERATING THE INDIVIDUAL VMS ALSO WITH DUMPING INFORMATION IN .CSV FILE
		        
		        $listOfRunVMs.Split(";") | ForEach {
		        
                    #try { #TO GET THE EXCEPTION WHILE FETCHING INFORMATION
                    
                     #write-output $_
		             $vmName = $_
		             #$vmIPAddress = (Get-VM -Name $vmName | Select @{N='IP';E={$_.Guest.IPAddress}}).IP
		             $vminfo = Get-VMGuest $vmName

		             $vmConnectionInfo = $vminfo.IPAddress -join " | " #TO COMBINE FOR MULTIPLE IP'S
                        $vmGetIPAddress = $vmConnectionInfo -replace '[a-z]+[0-9]*:*[0-9a-z]*:*[0-9a-z]*:*[0-9a-z]*:*[0-9a-z]*' -replace " "
                        $vmIPAddress = $vmGetIPAddress -replace "[\|]+"," | "

		             $vmSysInfo = Get-VM $vmName
		             #DUMPING FETECHED INFORMATION
		             $corePerSocket = $vmSysInfo.CoresPerSocket
		             $ADDLINE = "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}" -f "VM", $vminfo.HostName, "NA", "NA", "NA", $vminfo.OSFullName, $vmSysInfo.NumCpu, $corePerSocket, $vmSysInfo.MemoryGB, $vmSysInfo.ProvisionedSpaceGB, "NA", "NA", $vmIPAddress
		             $ADDLINE | add-content -path $outputfile

                    #}catch {
                    #    Write-Warning $Error[0]
                    #}

                }
		    }catch{
                Write-Warning $Error[0] 
            }

		    #DISCONNECTING THE SERVER ESXI HYPERVISOR
            #DON'T ALLOW THE PROMPT MESSAGE FOR YES OPTION
		    Disconnect-VIServer -Server $serverIPAddress -Force –Confirm:$false 
        
        }else{ 
            Write-Output "Info: PoweCLI does not connect to ESXI - " $serverIPAddress
      }
			
	}

}

#MAIN FUNCTION 

if ($help) {

	Help_fn
	
}elseif(![string]::IsNullOrEmpty($ifile) -and ![string]::IsNullOrEmpty($ofile) -and ![string]::IsNullOrEmpty($user)){

    $cred = Get-Credential $user 
	Create_file $ofile
	ServerInfo $ifile $ofile $cred

}else{
	write-host "Please pass the correct arguments"
}

write-host "----------------- THE END --------------------"