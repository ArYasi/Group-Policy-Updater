#export current local group policy security settings
secedit /export /cfg C:\secpol.cfg

#Replaced policy values are held in this array
$policiesToReplace = @{
    "MinimumPasswordAge ="="1"
    "PasswordHistorySize ="="24"
    "MaximumPasswordAge = "="60"
    "MinimumPasswordLength ="="14"
    "PasswordComplexity ="="1"
}

foreach ($policy in $policiesToReplace.Keys) {
    #Grabs policy string match from the array are replaces it with the correct policy value
    $initialFullPolicy = Get-Content C:\secpol.cfg -ReadCount 1000 | ForEach-Object { $_ -match $policy }
    $replacedPolicy = $initialFullPolicy -replace '(\d+)', $policiesToReplace[$policy]
    
    #edit file based of updated policies
    $null = (Get-Content C:\secpol.cfg).Replace($initialFullPolicy, $replacedPolicy) | Out-File C:\secpol.cfg

    Write-Host "+ $($policy) $($policiesToReplace[$policy])" -ForegroundColor Green
}

Write-Host "`nAll policies have been successfully updated." -ForegroundColor White -BackgroundColor Red

#Update local group policy
$null = secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
Remove-Item -force c:\secpol.cfg -confirm:$false