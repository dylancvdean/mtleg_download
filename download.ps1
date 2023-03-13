@echo off

set /p hearing="Enter hearing video link: "

powershell -Command "Invoke-WebRequest -UserAgent 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:118.0) Gecko/20100101 Firefox/118.0' -Uri '%hearing%' -OutFile html"

findstr "m3u8" html > html2

for /f "tokens=2 delims=:, " %%a in ('findstr /i /c:"url" html2') do set url=%%~a

echo %url% > url

set /a i=1

:loop
set file_url=%url%/media_%i%.ts
powershell -Command "Invoke-WebRequest -Uri '%file_url%' -Method Head" >nul 2>&1

if %errorlevel% neq 0 goto done

powershell -Command "Invoke-WebRequest -Uri '%file_url%' -OutFile %i%.ts"
set /a i+=1
goto loop

:done
copy /b *.ts output.mp4
del *.ts
