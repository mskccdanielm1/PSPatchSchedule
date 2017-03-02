function Get-PatchSchedule {


# Full item url https://one.mskcc.org/sites/pub/is/Pages/tr/Patching-Schedule.aspx

try {
Import-Module SharePointPnPPowerShell2013 -ErrorAction Stop | Out-Null
}
catch {
Write-Host "You must install the PnP PowerShell 2013 module" 
}

$creds = (Get-Credential)
Connect-PnPOnline -Url "https://one.mskcc.org/sites/pub/is/" -Credentials $creds
$list = Get-PnPList -Identity "6f1bac24-64ea-45e0-8bc0-392a8c1d2ca5"
$context = (get-PnPcontext)
$web = $context.web

#Get-PnPView -List "6f1bac24-64ea-45e0-8bc0-392a8c1d2ca5"

$query = New-Object Microsoft.SharePoint.Client.CamlQuery
$items = $list.GetItems($query)
$context.Load($items)
$context.ExecuteQuery()

$Results = @()

#$patchinfo = ($items) #| select titile,IP,Contact_x0020_Div,Contact_x0020_Dept_x002e_,Primary_x0020_Contact_x0020_Name

foreach ($item in $items) {

$item = ($item.fieldvalues)
#write-host $item.Title

$PatchSplat = @{ 
    Property=( 
        'Server', 
        'IP', 
        'Contact Div', 
        'Contact Dept', 
        'Support PDL', 
        'Patch Phase', 
        'Current Patch Slot', 
        'Custom Schedule Details' 
    )} 


$patchinfo = [pscustomobject][ordered]@{ 
    'Server'=$item.Title
    'IP'=$item.IP
    'Contact Div'=$item.Contact_x0020_Div
    'Contact Dept'=$item.Contact_x0020_Dept_x002e_
    'Support PDL'=$item.Primary_x0020_Contact_x0020_Name
    'Patch Phase'=($item).Patch_x0020_Phase1.LookupValue
    'Current Patch Slot'=($item).Current_x0020_Patch_x0020_Slot
    'Custom Schedule Details'=($item).Custom_x0020_Schedule_x0020_Deta
      } | Select-Object @SelectSplat 

$Results += $patchinfo

}

$Results | ConvertTo-Json
}
