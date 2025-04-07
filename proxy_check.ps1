$proxyList = Get-Content "proxies.txt"
$outputFile = "mxtoolbox_output.txt"
$customUserAgent = "YourCustomUserAgent/1.0"
$yourApiKey = "aaaaaaaaaaaaaaa"
$outputLines = @()

foreach ($proxy in $proxyList) {
    try {

       
        $curlCommand = "curl.exe --socks5 $proxy --max-time 10 -H 'User-Agent: $customUserAgent' 'https://api.ipify.org?format=json'" 
        $ipResponseJson = Invoke-Expression $curlCommand

         if ($ipResponseJson) {
            $ipResponse = $ipResponseJson | ConvertFrom-Json
            $realIP = $ipResponse.ip
            $outputLines += "$proxy -> IP:  $realIP"

         $headers = @{
    "Authorization" = $yourApiKey 
    "Accept"        = "application/json"
    "User-Agent" = $customUserAgent 
}
$mxtoolboxUri = "https://api.mxtoolbox.com/api/v1/Lookup/Blacklist/?argument=$realIP"
$mxtoolboxResult = Invoke-RestMethod -Uri $mxtoolboxUri -Headers $headers -Method Get

            $failedCount = $mxtoolboxResult.Failed.Count
            $warningCount = $mxtoolboxResult.Warnings.Count
            $outputLines += "  Failed: $failedCount, Warning: $warningCount"
}
        else {
            $outputLines += "$proxy - ipify Error"
        }
    }
    catch {
        $outputLines += "$proxy - unknown Error"
    }
}


$outputLines | Out-File -Encoding UTF8 $outputFile

Write-Output "Writed: $outputFile"