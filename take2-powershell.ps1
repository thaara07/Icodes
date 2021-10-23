function get-file
    {
        [cmdletbinding()]
        param(
                [parameter(Mandatory)]
                [system.IO.fileInfo] $file
              )

              return Import-csv $file
              
}


#Question 4,5,6
function get-sitemailboxes
    {
        [cmdletbinding()]
        param(
                [parameter(Mandatory,Position = 0)]
                [system.IO.fileInfo] $file,
                [parameter(Mandatory,Position = 1)]
                [AllowNull()]
                [AllowEmptyString()]
                [string] $site,
                [parameter(Position = 2)]
                [Validateset('Employee','Contractor','All')]
                [AllowNull()]
                [AllowEmptyString()]
                [string] $Accounttype
            )

            <#$file = "C:\Temp\users.csv"
            $site = "NYC"
            $Accounttype = "Employee"
            #>
                if(([string]::IsNullOrEmpty($Accounttype)) -and ([string]::IsNullOrEmpty($Site)))
                    {
                        return Import-csv $file
                    }
                elseif([string]::IsNullOrEmpty($Accounttype))
                    {
                        return Import-csv $file | ?{$_.site -eq $site}
                    }
                 elseif([string]::IsNullOrEmpty($Site))
                    {
                        return Import-csv $file | ?{$_.Accounttype -eq $Accounttype}
                    }
                else
                    {
                     return Import-csv $file | ?{($_.site -eq $site) -and ($_.Accounttype -eq $Accounttype)}   
                     }   

           
    }
$email = @()
$path = "C:\temp\Users.csv"
$sitesummary = @()
$inputfile = get-file $path

try
{
# Question1
$usercount = ($inputfile | select -unique Userprincipalname).count
Write-host "Total number of users : $($usercount)"
}
catch
{
"Usercount error (inputfile | select -unique Userprincipalname).count: $PSItem.ToString()" >> C:\Temp\errorlog.txt
}
try
{
#Question2
$totalmailboxsize = ($inputfile | Measure-Object -property Mailboxsizegb -Sum).sum
Write-host "Total mailboxsize for all users: $($totalmailboxsize)"
}
catch
{
"Totalmailboxsize error (inputfile | Measure-Object -property Mailboxsizegb -Sum).sum: $PSItem.ToString()" >> C:\Temp\errorlog.txt
}
try
{
#Question3
$nonidenticalusername = ($inputfile | ?{-not ($_.emailaddress -ceq $_.Userprincipalname)} | select emailaddress,userprincipalname).count
Write-host "Total non identical users : $($nonidenticalusername)"
}
catch
{
"nonidenticalusername = ($inputfile | ?{-not ($_.emailaddress -ceq $_.Userprincipalname)} | select emailaddress,userprincipalname).count
: $PSItem.ToString()" >> C:\Temp\errorlog.txt
}
try
{
#Question7
$mailboxpersite = get-sitemailboxes $path "NYC" | ?{$_.emailaddress -like "*@domain2.com"} | sort-object MailboxSizeGB -Descending | select -First 10
Write-host "Total mailbox per site with domain2.com :" 
$mailboxpersite
}
catch
{
'mailboxpersite = get-sitemailboxes $path "NYC" | ?{$_.emailaddress -like "*@domain2.com"} | sort-object MailboxSizeGB -Descending | select -First 10
: $PSItem.ToString()' >> C:\Temp\errorlog.txt
}
try
{
#Question8
$suspicioususername = ($inputfile | ?{$_.emailaddress -like "*@domain2.com"} | select emailaddress | % {($_.emailaddress -split "@")[0] }) -join " "
Write-host "Suspicious user names in domain2.com : $($suspicioususername)"
}
catch
{
'suspicioususername = ($inputfile | ?{$_.emailaddress -like "*@domain2.com"} | select emailaddress | % {($_.emailaddress -split "@")[0] }) -join " "
: $PSItem.ToString()' >> C:\Temp\errorlog.txt
}

#Question 9,10
get-sitemailboxes $path "" | Group-Object Site | %{
$sitesummary += New-Object psobject -Property @{
Site = $_.Name;
TotalUsercount = $_.Count;
Employeecount = ($_.group | ?{$_.accounttype -like "*Employee*"}).count;
Contractorcount = ($_.group | ?{$_.accounttype -like "*Contractor*"}).count;
TotalMailboxSizeGB = ($_.group | Measure-Object -Sum Mailboxsizegb).sum;
AverageMailboxsizeGB= ([Math]::Round(($_.group | Measure-Object -Average Mailboxsizegb).Average,1)) 
}
} 

$sitesummary | Export-Csv C:\temp\sitesummary2.csv




