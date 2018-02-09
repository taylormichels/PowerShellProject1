#
# Main.ps1
#
# requires Team Foundation Server Power Tools with PowerShell cmdlets installed (not default install)
. "C:\Users\tmichels\onedrive - gep\visual studio 2015\Projects\PowerShellProject1\PowerShellProject1\Utils.ps1"
. "C:\Users\tmichels\onedrive - gep\visual studio 2015\Projects\PowerShellProject1\PowerShellProject1\Format-Json.ps1"

$jsonPaths = "C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\assurant\p2p\inv\config.js", 
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\ascenaretail\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\atg\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\bhf\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\cbt\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\dtcc\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\marketingdemo\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\mylan\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\pumaenergy\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\riteaid\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\salesdemous\p2p\inv\config.js",
			"C:\SMART\MAIN\GEP PlatformServices\Storage\Blob\MtStorage\smartcontent\distribution\clientConfig_dist\clientConfig\clients\smart20\p2p\inv\config.js"

for($p = 0; $p -lt $jsonPaths.count; $p++) {
	$fields = 'InvoiceData.name',
				'InvoiceData.invoiceTotalAmount',
				'InvoiceData.PartnerInvoiceNumber',
				'InvoiceData.partnerInvoiceDate',
				'InvoiceData._NonePOInvoice',
				'InvoiceData.orderNumberObj',
				'InvoiceData.currency',
				'InvoiceData.orderingLocation',
				'InvoiceData.remittoLocation'

	Add-PSSnapin Microsoft.TeamFoundation.PowerShell
	Add-TfsPendingChange -Edit $jsonPaths[$p]

	$config = Get-Content $jsonPaths[$p] -raw | Remove-Var | ConvertFrom-Json 
	for($f = 0; $f -lt $fields.count; $f++) {
		for($i = 0; $i -lt $config.header.sections.count; $i++) {
			for($y = 0; $y -lt $config.header.sections[$i].rows.count; $y++) {
				for($z = 0; $z -lt $config.header.sections[$i].rows[$y].properties.count; $z++) {
					$tmpObj = $config.header.sections[$i].rows[$y].properties[$z] | where {$_.data -eq $fields[$f]}
					if ($tmpObj) {
						$isEditable = $tmpObj.attributes.isEditable
						if ($isEditable.Count -gt 0) {
							$isEditableModified = $isEditable | where { $_.StartsWith('0_1_')}
							$isEditableModified = $isEditableModified | ForEach-Object { 
								$_ -replace '0_1_', '1_1_'
								$_ }
							$isEditableModified += $isEditable
							$isEditableModified =  $isEditableModified | select -uniq | Sort-Object
							$tmpObj.attributes.isEditable = $isEditableModified
						}
					}
				}
			}
		}
	}
	$config | ConvertTo-Json -Depth 20 | Do-Unescape | Format-Json | Append-Var | set-content $jsonPaths[$p]
}

