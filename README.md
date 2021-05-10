# VMware-ESXI-host-inventory
This Generate Inventory build script is written in Powershell with the support of its PowerCLI module for VMware ESXi hosts. It will generate the inventory of the resources allocation on multiple ESXi hosts with running Virtual Machines. It will take the list of IP addresses of the ESXi hypervisors and fetch all required information such as:

1. Zone Name
2. Server / VM Hostname
3. Server Model
4. Serial Tag
5. vCPUs
6. Processor Type / Cores Per Socket
7. Memory
8. Disk
9. Storage Path
10. ILOM / IDRAC IP Addresses
11. Server / Running VM IP Addresses

This script can be modified for various requirements. For successful execution, the VMware Tool should be installed for the Virtual Machines which you can verify from the GUI of the VMware ESXi hypervisors. The VM may be running but it failed to fetch the information just because of the unavailability of the VMware Tools. Furthermore, there is also a possibility that some cmdlets are not supported by the older version of ESXi or the assigned license.
![](https://github.com/mismailzz/VMware-ESXI-host-inventory/blob/main/Error-Info.PNG)

```
Powershell Version      
-------      
5.1.19041.906

PS C:\Users\mismailzz\Documents\Projects\HypervisorInventory> .\generate_inventory.ps1 -help

----------------------------HELP------------------------------------

-user		[Mention the user]

-ifile		[Mention the file path of IP addresses file]
		[For Example: C:\path\to\file.txt]

-ofile		[Mention the CSV output file]
		[For Example: C:\path\to\file.csv]

-help		[For Help]


***
Example Commands
PowerCLI C:\Users\user\Desktop> .\generate_inventory.ps1 -help
PowerCLI C:\Users\user\Desktop> .\generate_inventory.ps1 -user username -ifile C:\path\to\file.txt -ofile C:\path\to\file.csv
***


<!> WARNING <!>
<!> Please ensure to specify the correct password, if the password is not correct then
<!> after running this script continously with incorrect password may cause locking of your
<!> account on hypervisor


----------------- THE END --------------------
```

Just after the execution of the script, we have the Login portal

![](https://github.com/mismailzz/VMware-ESXI-host-inventory/blob/main/ESXI-login.PNG)

We can open the .csv file in the Excel format and modify it

![](https://github.com/mismailzz/VMware-ESXI-host-inventory/blob/main/ESXI-Inventory.PNG)

