$path = "$HOME\Certificates"
if (!(Test-Path $path -PathType Container)) {
  New-Item -ItemType Directory -Force -Path $path
}

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "                                                          DIRECTIONS"
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "In the following steps you will be prompted with a 'certificate name'. This is what your Self Signed Cert will be called."
Write-Host ""
Write-Host "Next you will be prompted with a 'Certificate password'. This is what your Self Signed Cert will be use for a private key password."
Write-Host ""
Write-Host "Lastly you will be given directions on where to place these certificates so that Windows will acknowledge them."
Write-Host ""
Write-Host "Your certificates will be in this directory when complete: $path"
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""
Write-Host ""
Write-Host ""

$certname= Read-Host -Prompt "Enter certificate name: "
$certpw= Read-Host -Prompt "Enter certificate password: "

$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256 -NotAfter (Get-Date).AddYears(10)
Export-Certificate -Cert $cert -FilePath "$path\$certname.cer"
$mypwd = ConvertTo-SecureString -String "$certpw" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "$path\$certname.pfx" -Password $mypwd


Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "                                                          FINAL STEPS"
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "Search for 'Manage computer certificates' option and open it. Follow these steps:"
Write-Host ""
Write-Host "In the left panel, navigate to Certificates - Local Computer → Personal → Certificates"
Write-Host "Locate the created certificate (in this example look under the Issued To column 'mysite.local', or under the Friendly Name column '$certname')"
Write-Host "In the left panel, open (but don't navigate to) Certificates - Local Computer → Trusted Root Certification Authorities → Certificates"
Write-Host "With the right mouse button, drag and drop the certificate to the location opened in the previous step"
Write-Host "Select 'Copy Here' in the popup menu"
Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "                                                             DONE!"