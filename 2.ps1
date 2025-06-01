
$hostsPath = 'C:\Windows\System32\drivers\etc\hosts'
$hostsEntries = @'

127.0.0.1 ftpm.amd.com
127.0.0.1 tsci.intel.com
127.0.0.1 ekcert.intel.com
127.0.0.1 pki.intel.com
127.0.0.1 trustedservices.intel.com
'@
Add-Content -Path $hostsPath -Value $hostsEntries -Force
