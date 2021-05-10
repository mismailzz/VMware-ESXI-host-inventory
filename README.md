# VMware-ESXI-host-inventory
The script is written in powershell


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
