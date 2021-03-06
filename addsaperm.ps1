<# 
This script adds SA accounts for IIS 7
#>


$saccounts="IUSR","IIS_IUSRS"

$input=read-host "Enter base path"
foreach ($path in (Get-ChildItem $input))
    {
    Write-Host $path
    foreach ($account in $saccounts)
    {
    try
        {
            $colRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute, Synchronize" 

            $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit `
                    -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
            $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None 

            $objType =[System.Security.AccessControl.AccessControlType]::Allow 

            $objUser = New-Object System.Security.Principal.NTAccount($account) 

            $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 

            $objACL = Get-ACL $path.fullname
            $objACL.AddAccessRule($objACE) 

            Set-ACL $path.fullname $objACL
        if ($account -eq "IUSR")
            {
                #fix this D.R.Y.
                $colRights = [System.Security.AccessControl.FileSystemRights]"Write" 
                $objType =[System.Security.AccessControl.AccessControlType]::Deny

                $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
                    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 

                $objACL = Get-ACL $path.fullname
                $objACL.AddAccessRule($objACE) 

                Set-ACL $path.fullname$objACL
            }
        else
            {
                continue
            }

         }
    
        catch
        {
            continue
        }
    }
}