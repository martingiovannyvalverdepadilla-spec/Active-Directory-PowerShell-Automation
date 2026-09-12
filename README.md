# Automated Bulk User Provisioning in Active Directory

## Overview
Manually provisioning user accounts in Active Directory is error-prone, time-consuming, and inconsistent across enterprise environments. This project automates bulk user onboarding using **PowerShell** and a standardized CSV dataset in **Windows Server 2022 Active Directory Domain Services (AD DS)**.

The script ensures idempotent execution, dynamic organizational unit (OU) placement based on department data, strict parameter handling via splatting, and structured error handling (`try/catch`).
---

## Lab Environment
* **Operating System:** Windows Server 2022 Datacenter
* **Domain Name:** `lab.local`
* **Root OU:** `OU=COMPANY,DC=lab,DC=local`
* **Target Sub-OUs:**
  * `OU=IT,OU=COMPANY,DC=lab,DC=local`
  * `OU=Sales,OU=COMPANY,DC=lab,DC=local`
  * `OU=General,OU=COMPANY,DC=lab,DC=local`
  ## Key Features & Architecture

* **CSV Data Ingestion:** Uses `Import-Csv` to parse external user lists dynamically, separating infrastructure logic from dataset inputs for maintainable bulk operations.
* **Idempotency & Duplicate Prevention:** Queries Active Directory via `Get-ADUser -Filter` before execution. Existing accounts trigger `Write-Warning` and a `continue` statement, safely skipping duplicate records without terminating script flow.
* **Dynamic OU Routing:** Inspects the `Department` attribute through conditional logic (`if / elseif / else`) to route each user object to its designated Organizational Unit (`$TargetOU`).
* **PowerShell Splatting:** Employs a structured hash table (`@Params`) passed directly to `New-ADUser`, reducing line length and improving code readability and maintenance.
* **Fault Tolerance & Exception Handling:** Enforces `-ErrorAction Stop` inside a `try / catch` block to convert non-terminating errors into terminating exceptions, surfacing detailed Active Directory policy violations (e.g., password complexity failures) via `$($_.Exception.Message)`.

## Usage & Execution

1. Prepare the input dataset in `C:\NewUsers.csv` following this schema:
   ```csv
   GivenName,Surname,Department
   Martin,Valverde,IT
   Jesus,Luis,Sales
