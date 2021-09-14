# Disable inactive Active Directory user accounts

This is a very simple PowerShell script that takes all inactive Active Directory users that have not been logged on for X days, and disables them. The Search OU and max inactive days can be configured on the script. The script searches users separately in all Domain Controllers (because some users might only use one out of X domain controllers, so they are active, you might just not be aware of them, because you search the wrong DC).

This script is more of automation, rather than auditing, though it can be used for it. If you want a more GUI friendly tool, there are a lot of alternatives, for example [CJWDEV](http://www.cjwdev.com/)'s [AD Tidy](http://www.cjwdev.com/Software/ADTidy/Info.html) tool.

## Requirements
The script (PowerShell 5 was tested) needs to be ran on a domain joined Windows machine (Server or Desktop), because of the Active Directory integration. It also needs to have the Active Directory module installed (on non-server Windows versions, this is achieved by the Remove Server Administration Tools (RSAT)).

You also need to have the permission to read and disable accounts in Active Directory.

## Usage

Just run it as a normal PowerShell script :)
