# Cleanup Disabled Users from SharePoint for Keepit Zerto M365 Backup

This PowerShell script is designed for organizations using Keepit's Zerto M365 SaaS backup solution to manage SharePoint licenses more efficiently. It targets the removal of disabled users who continue to consume SharePoint licenses without having an active M365 license, thus optimizing license allocation.

## Features

- **Automated Detection and Removal**: Identifies and removes disabled users from SharePoint site collections and Microsoft 365 Unified Groups.
- **License Optimization**: Helps in reclaiming SharePoint licenses occupied by disabled users.
- **Detailed Logging**: Offers comprehensive logging for transparency and auditing purposes.

## Prerequisites

Before running this script, ensure the following prerequisites are met:

- **PowerShell 5.1 or higher**: Required for executing the script.
- **PnP PowerShell Module**: Needed for SharePoint operations.
- **Microsoft Graph PowerShell SDK**: Used for Microsoft 365 operations.
- **Certificate & Enterprise Application**: A certificate must be associated with an Enterprise Application in Azure AD. This application needs the following permissions to execute the required operations:
    - `User.ReadWrite.All`
    - `Group.ReadWrite.All`
    - `GroupMember.ReadWrite.All`
    - `Sites.FullControl.All`

These permissions allow the script to modify user and group memberships and manage site collections effectively.

### Installing Required PowerShell Modules

Install the necessary PowerShell modules by executing the following commands:

```powershell
Install-Module SharePointPnPPowerShellOnline -AllowClobber
Install-Module Microsoft.Graph -Scope CurrentUser
```

## Setup

1. **Configure Azure AD Application**: Create an Enterprise Application in Azure AD and bind a certificate to it. Assign the application the required Graph permissions as listed in the prerequisites.

2. **Clone the Repository**: Download the script files to your local environment.

    ```bash
    git clone https://github.com/yourrepository/KeepitCleanupScript.git
    ```

3. **Script Configuration**: Edit the script to include your specific M365 tenant details (`$TenantURL`, `$ClientID`, `$ThumbPrint`, `$Tenant`, `$TenantID`).

## Usage

Execute the script in a PowerShell session with administrative privileges. Navigate to the script's directory and run:

```powershell
.\CleanupDisabledUsers.ps1
```

The script performs the following actions:
- Connects to your M365 tenant using the provided credentials.
- Retrieves lists of site collections, disabled users, and Unified Groups.
- Removes the identified disabled users from the site collections and Unified Groups.
- Logs the details of the operations performed.

## Contribution

We welcome contributions to enhance the script's functionality. Feel free to submit issues or pull requests on GitHub.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Disclaimer

This script is provided "as is," without any warranty. Users should proceed with caution and test in a non-production environment before deploying. Ensure you have adequate backups before making changes to live environments.

