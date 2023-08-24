@echo off

@REM Download miniconda3 win64 exe
echo Downloading Miniconda3-latest-Windows-x86_64.exe ...
powershell -Command ^
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
    (New-Object System.Net.WebClient).DownloadFile('https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe', ^
        (Join-Path -Path $PWD -ChildPath 'Miniconda3-latest-Windows-x86_64.exe'))
echo Miniconda3-latest-Windows-x86_64.exe Download!

@REM Calculate sha256 hash of miniconda3 file
for /f %%i in ('
    powershell -Command 
    "Get-fileHash (Join-Path -Path $PWD -ChildPath 'Miniconda3-latest-Windows-x86_64.exe') | Select-Object -ExpandProperty Hash"
') do set "calcHash=%%i"

@REM Parse conda website for win64 sha256 hash
for /f "delims=" %%i in ('
    powershell -Command 
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;"
    "$htmlContent = (Invoke-WebRequest -Uri 'https://docs.conda.io/en/latest/miniconda.html#installing').Content;"
    "([Regex]::Matches($htmlContent, '[a-f0-9]{64}').Value[0]);"
') do set "correctHash=%%i"

echo.
echo Correct sha256 hash value:    %correctHash%
echo Calculated sha256 hash value: %calcHash%

@REM Compare hashes and run installer if equal or remove download if bad file
if /i "%correctHash%" == "%calcHash%" ( 
    echo Hashes Matched!
    echo.
    echo Installing Miniconda3 ...
    start /wait "" Miniconda3-latest-Windows-x86_64.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%UserProfile%\Miniconda3
    echo Miniconda3 was successfully installed to %UserProfile%\Miniconda3!

    echo Removing Miniconda3-latest-Windows-x86_64.exe ...
    del %cd%\Miniconda3-latest-Windows-x86_64.exe
    echo Removed Miniconda3-latest-Windows-x86_64.exe successfully!

    echo.
    echo Now starting miniconda3 in the current terminal
    echo You can also hit the Win key and search for Anaconda-prompt^(miniconda3^) to launch miniconda3

    title Anaconda Prompt ^(miniconda3^)
    cmd /k C:\Users\Cody\miniconda3\condabin\activate.bat
    
 ) else ( 
    echo Hashes didnt match!

    echo Deleting Miniconda3-latest-Windows-x86_64.exe ...
    del %cd%\Miniconda3-latest-Windows-x86_64.exe
    echo Deleted Miniconda3-latest-Windows-x86_64.exe successfully!
)
