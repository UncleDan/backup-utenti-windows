@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  Backup dati utente + cartelle custom - archivio 7z
::  Richiede: esecuzione come Amministratore
::            7-Zip installato (percorso in SZ sotto)
::  Destinazione: modificare DST secondo necessità
:: ============================================================

set SZ="C:\Program Files\7-Zip\7z.exe"
set DST=D:\Backup\%COMPUTERNAME%
set LOG=%DST%\backup.log

:: Data nel formato YYYYMMDD per il nome archivio
for /f "tokens=1-3 delims=/" %%a in ("%DATE%") do (
    set GG=%%a
    set MM=%%b
    set AAAA=%%c
)
:: Gestione formato data italiano (GG/MM/AAAA) e internazionale (AAAA-MM-GG)
:: 7z accetta qualsiasi suffisso, usiamo la variabile DATE risanata
set DATESTAMP=%DATE:/=-%
set DATESTAMP=%DATESTAMP: =_%

set ARCHIVE_USERS=%DST%\users_%DATESTAMP%.7z
set ARCHIVE_ROOT=%DST%\root_%DATESTAMP%.7z

:: Crea cartella di destinazione se non esiste
if not exist "%DST%" mkdir "%DST%"

echo. >> "%LOG%"
echo ============================================================ >> "%LOG%"
echo  Backup avviato: %DATE% %TIME% >> "%LOG%"
echo ============================================================ >> "%LOG%"


:: ── JOB 1: tutti i profili utente ────────────────────────────────────────
echo.
echo [1/2] Backup profili utente in archivio 7z...
echo       Archivio: %ARCHIVE_USERS%

%SZ% a -t7z "%ARCHIVE_USERS%" "C:\Users\*" ^
  -r ^
  -mx=5 ^
  -mmt=on ^
  -xr!"AppData\Local\Temp" ^
  -xr!"AppData\Local\Packages" ^
  -xr!"AppData\Local\Microsoft\Windows\INetCache" ^
  -xr!"AppData\Local\Microsoft\Windows\WebCache" ^
  -xr!"AppData\Local\Microsoft\Windows\Caches" ^
  -xr!"AppData\Local\Microsoft\Windows\Explorer" ^
  -xr!"AppData\Local\Google\Chrome\User Data\Default\Cache" ^
  -xr!"AppData\Local\Microsoft\Edge\User Data\Default\Cache" ^
  -xr!"AppData\Local\pip\cache" ^
  -xr!"AppData\Local\npm-cache" ^
  -xr!"AppData\Local\Yarn" ^
  -xr!"node_modules" ^
  -xr!".venv" ^
  -xr!"__pycache__" ^
  -xr!"*.tmp" ^
  -xr!"*.lock" ^
  -xr!"*.dmp" ^
  -xr!"~$*" ^
  -xr!"Thumbs.db" ^
  -xr!"desktop.ini" ^
  -xr!"ntuser.dat.log*" ^
  -xr!"NTUSER.DAT{*" ^
  -xr!"usrclass.dat{*" ^
  >> "%LOG%" 2>&1


:: ── JOB 2: cartelle custom in radice C:\ + file sciolti ─────────────────
echo.
echo [2/2] Backup cartelle custom radice C:\ in archivio 7z...
echo       Archivio: %ARCHIVE_ROOT%

%SZ% a -t7z "%ARCHIVE_ROOT%" "C:\*" ^
  -r ^
  -mx=5 ^
  -mmt=on ^
  -xr!"C:\Windows" ^
  -xr!"C:\Windows.old" ^
  -xr!"C:\Program Files" ^
  -xr!"C:\Program Files (x86)" ^
  -xr!"C:\ProgramData" ^
  -xr!"C:\Users" ^
  -xr!"C:\Recovery" ^
  -xr!"C:\PerfLogs" ^
  -xr!"C:\$Recycle.Bin" ^
  -xr!"C:\System Volume Information" ^
  -xr!"node_modules" ^
  -xr!".venv" ^
  -xr!"__pycache__" ^
  -x!"pagefile.sys" ^
  -x!"hiberfil.sys" ^
  -x!"swapfile.sys" ^
  -xr!"*.tmp" ^
  -xr!"*.lock" ^
  -xr!"*.dmp" ^
  -xr!"~$*" ^
  >> "%LOG%" 2>&1


:: ── Fine ──────────────────────────────────────────────────────────────────
echo.
echo ============================================================ >> "%LOG%"
echo  Backup completato: %DATE% %TIME% >> "%LOG%"
echo ============================================================ >> "%LOG%"

echo.
echo Backup completato.
echo   Utenti : %ARCHIVE_USERS%
echo   Root   : %ARCHIVE_ROOT%
echo   Log    : %LOG%
echo.
pause
