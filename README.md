# Ubuntu-18.04-Bash-Scripting
The project contains a list of bash scripts used to interact with .NET applications, movement of files and so on. Each script is used extensively as they interact with client and server side uses of other repositories.

### automate-workflow script
This script automates a lot of the workflow I have related to other projects. Some tasks include automating the process of creating subdomains for a site, such as create, removing, go live, modifying a subdomains name, creating logs for any checks should they be made. This script also automates the workflow of creating subdomains related to dotnet applications in the .NET Core framework. By working with Kestrel server, publishing the dotnet application pushing it's released version to the apache server as well as creating the reverse proxy relevant to the application being published. It also includes many other tasks related to other projects located in my repositories.

### bacup-site script
This script just backups a storage physical location using rsync that is linked to a PHP hosted site which is another project. Ensuring that the core stored data of the site structure isn't lost and is still maintained irregardless of what happens to the site. As the site operates independently.

### check_vpn_users script
This script is primarly used to check my private vpn server for users currently active and online

### run_vpn_script script
This script is placed on a remote server that is used to activate the check_vpn_uses script.
