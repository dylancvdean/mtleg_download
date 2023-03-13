$hearing = Read-Host "Enter hearing video link"
Invoke-WebRequest -UserAgent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:118.0) Gecko/20100101 Firefox/118.0" -Uri $hearing -OutFile html
Select-String "m3u8" html | Select-Object Line | Out-File html2

$url = (Select-String -Path html -Pattern 'https?://.*\.m3u8').Matches.Value | select-object -First 1

Set-Content -Path url -Value $url
$url = $url -replace '/playlist.m3u8$',''

$i = 1
echo $url
while ($true) {
    $file_url = "$url/media_$i.ts"
    echo $file_url
    $response = Invoke-WebRequest -Uri $file_url -Method Head -UseBasicParsing -ErrorAction SilentlyContinue

    if ($response.StatusCode -ne 200) {
        break
    }

    Invoke-WebRequest -Uri $file_url -OutFile "$i.ts"

    $i++
}

& ffmpeg.exe -i "concat:$(Join-Path $PWD '*.ts')" -c copy output.mp4

Remove-Item -Path *.ts
