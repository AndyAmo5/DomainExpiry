Clear-Host
function IsNullOrEmpty($str) {if ($str) {"notempty"} else {"empty"}}

# This function just gets $true or $false
function Test-RegistryValue($path, $name)
{
    $key = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
    $key -and $null -ne $key.GetValue($name, $null)
}

# This function just gets $true or $false
function Test-RegistryValue($path, $name)
{
    $key = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
    $key -and $null -ne $key.GetValue($name, $null)
}

#Lookup Exchange version in registry 
[string]$vExch2010 = Test-RegistryValue HKLM:\SOFTWARE\Wow6432Node\Microsoft\ExchangeServer\v14\MailboxRole ConfiguredVersion #Exchange 2010
[string]$vExch2007 = Test-RegistryValue HKLM:\SOFTWARE\Wow6432Node\Microsoft\Exchange\v8.0\MailboxRole ConfiguredVersion #Exchange 2007
[string]$vExch2003 = Test-RegistryValue HKLM:\SOFTWARE\Microsoft\Exchange\Setup NewestBuild #Exchange 2003

#Check Exchange version
if ($vExch2010 -eq 'True') {"Exchange2010"
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
	}
elseif ($vExch2007 -eq 'True') {"Exchange2007"
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
	}
elseif ($vExchVer -eq 'True') {"Exchange 2003 currently unsupported"| Out-File "c:\NETESP\User.txt" -Append
	exit
	}
else {"Unsupported Exchange version"| Out-File "c:\NETESP\User.txt" -Append
exit
}
#Parse domain list
get-accepteddomain|ft domainname|out-file c:\windows\LTSVC\scripts\Domain\Domain.txt -Encoding ASCII

$f = ${c:\windows\LTSVC\scripts\Domain\Domain.txt}
$f[0]=$null
$f[1]=$null
$f[2]=$null

${c:\windows\LTSVC\scripts\Domain\Domain.txt} = $f

$content = Get-Content c:\windows\LTSVC\scripts\Domain\Domain.txt
$content | Foreach {$_.TrimEnd()} | Set-Content c:\windows\LTSVC\scripts\Domain\Domain.txt

#Read Domain output to array
$a=Get-Content c:\windows\LTSVC\scripts\Domain\Domain.txt
#$a.count
$SearchArray = @("Expiry Date:", "Expires")
foreach ($line in $a)
{
    $vNullValue = isnullorempty $line
	if ($vNullValue -ne 'empty') {
	c:\windows\LTSVC\scripts\domain\whoiscl.exe $line | out-file c:\windows\LTSVC\scripts\Domain\$line.txt
	[string]$Search=Select-String -Path c:\windows\LTSVC\scripts\Domain\$line.txt -pattern $SearchArray
	$Search = $Search.ToLower()
	$Search = $Search.substring($Search.length - 12, 12)
	[string]$output = $line + ',' + $Search + ','
	$output | out-File c:\windows\LTSVC\scripts\Domain\DomainExpiry.txt -append
	Remove-Item c:\windows\LTSVC\scripts\Domain\$line.txt -ErrorAction SilentlyContinue 
	}
}
