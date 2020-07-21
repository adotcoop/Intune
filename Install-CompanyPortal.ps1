<#
    .SYNOPSIS
        Automatically installs the Company Portal app

        Most of this code is is by Oliver Kieselbach from his excellent blog post

        https://oliverkieselbach.com/2020/04/22/how-to-completely-change-windows-10-language-with-intune/
    
     .NOTES
        Author: Andrew Cooper
        Twitter: @adotcoop
        
    .LINK
        https://github.com/adotcoop/Intune

    .DESCRIPTION
        This script provides a way to automatically install the Company Portal app.

        The inspiration for this script came after watching the Greg Shields' Pluralsight course on Intune where
        it appears that the only current mechanism to autodeploy the Company Portal is through Microsoft Store for 
        Business. MSfB appears to have been deprecated (https://twitter.com/concentratdgreg/status/1246133337200062464). 

        Oliver Kieselbach details how to use the MDM Bridge WMI Provider to force a store app install in his blog post 

        https://oliverkieselbach.com/2020/04/22/how-to-completely-change-windows-10-language-with-intune/

        The MDM Bridge provider appears to allow any store app to be installed automatically provided you know the 
        applicationID. The applicationID can be found at the end of the store URL. For example, here is the Company 
        Portal URL

        https://www.microsoft.com/en-gb/p/company-portal/9wzdncrfj3pz

        I can't improve on Oliver's code, so the credit for this method of store app deployment should go to him.

#>

$applicationId = "9wzdncrfj3pz"
$skuId = 0016

$webpage = Invoke-WebRequest -UseBasicParsing -Uri "https://bspmts.mp.microsoft.com/v1/public/catalog/Retail/Products/$applicationId/applockerdata"
$packageFamilyName = ($webpage | ConvertFrom-JSON).packageFamilyName

# you can specify the packageFamilyName if already known
#$packageFamilyName = 'Microsoft.CompanyPortal_8wekyb3d8bbwe' 


#   All of the below code is by Oliver Kieselbach

$namespaceName = "root\cimv2\mdm\dmmap"
$session = New-CimSession
$omaUri = "./Vendor/MSFT/EnterpriseModernAppManagement/AppInstallation"
$newInstance = New-Object Microsoft.Management.Infrastructure.CimInstance "MDM_EnterpriseModernAppManagement_AppInstallation01_01", $namespaceName
$property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ParentID", $omaUri, "string", "Key")
$newInstance.CimInstanceProperties.Add($property)
$property = [Microsoft.Management.Infrastructure.CimProperty]::Create("InstanceID", $packageFamilyName, "String", "Key")
$newInstance.CimInstanceProperties.Add($property)

$flags = 0
$paramValue = [Security.SecurityElement]::Escape($('<Application id="{0}" flags="{1}" skuid="{2}"/>' -f $applicationId, $flags, $skuId))
$params = New-Object Microsoft.Management.Infrastructure.CimMethodParametersCollection
$param = [Microsoft.Management.Infrastructure.CimMethodParameter]::Create("param", $paramValue, "String", "In")
$params.Add($param)

try {
    # we create the MDM instance and trigger the StoreInstallMethod
    $instance = $session.CreateInstance($namespaceName, $newInstance)
    $result = $session.InvokeMethod($namespaceName, $instance, "StoreInstallMethod", $params)
}
catch [Exception] {
    write-host $_ | out-string
}

Remove-CimSession -CimSession $session

