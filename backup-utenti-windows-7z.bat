@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  Backup dati utente + cartelle custom - archivio 7z
::  Richiede: esecuzione come Amministratore
::            7-Zip installato (percorso in SZ sotto)
::  La cartella di destinazione viene creata nella stessa
::  cartella dello script se DST non viene modificato
:: ============================================================

set SZ="C:\Program Files\7-Zip\7z.exe"

:: Destinazione backup — modificare se necessario
:: Default: sottocartella Backup\NomeMacchina nella cartella dello script
set DST=%~dp0Backup\%COMPUTERNAME%

:: Timestamp nel formato YYYY-MM-DD_HH-MM-SS
:: Parsing data (formato italiano GG/MM/AAAA)
for /f "tokens=1-3 delims=/" %%a in ("%DATE%") do (
    set DD=%%a
    set MM=%%b
    set YYYY=%%c
)
:: Parsing ora (HH:MM:SS,cc)
for /f "tokens=1-3 delims=:," %%a in ("%TIME: =0%") do (
    set HH=%%a
    set MN=%%b
    set SS=%%c
)
set TS=%YYYY%-%MM%-%DD%_%HH%-%MN%-%SS%

:: 5 lettere maiuscole casuali (A-Z) per evitare collisioni tra esecuzioni parallele
set CHARSET=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
set RND5=
for /l %%i in (1,1,5) do (
    set /a IDX=!RANDOM! %% 36
    for %%X in (!IDX!) do set RND5=!RND5!!CHARSET:~%%X,1!
)

set PREFIX=%TS%_%RND5%

set ARCHIVE_USERS=%DST%\%PREFIX% users.7z
set ARCHIVE_ROOT=%DST%\%PREFIX% root.7z
set LOG=%DST%\%PREFIX% backup.log

:: Crea cartella di destinazione se non esiste
if not exist "%DST%" mkdir "%DST%"

:: Crea file temporaneo con le esclusioni utenti
set EXCL_USERS=%TEMP%\7z_excl_users.txt
(
echo AppData\Local\Temp
echo AppData\Local\Packages
echo AppData\Local\Microsoft\Windows\INetCache
echo AppData\Local\Microsoft\Windows\WebCache
echo AppData\Local\Microsoft\Windows\Caches
echo AppData\Local\Microsoft\Windows\Explorer
echo AppData\Local\Google\Chrome\User Data\Default\Cache
echo AppData\Local\Microsoft\Edge\User Data\Default\Cache
echo AppData\Local\pip\cache
echo AppData\Local\npm-cache
echo AppData\Local\Yarn
echo node_modules
echo .venv
echo __pycache__
echo *.tmp
echo *.lock
echo *.dmp
echo ~$*
echo Thumbs.db
echo desktop.ini
echo ntuser.dat.log*
echo NTUSER.DAT{*
echo usrclass.dat{*
) > "%EXCL_USERS%"

:: Crea file temporaneo con le esclusioni root
set EXCL_ROOT=%TEMP%\7z_excl_root.txt
(
echo Windows
echo Windows.old
echo Program Files
echo Program Files ^(x86^)
echo ProgramData
echo Users
echo Recovery
echo PerfLogs
echo $Recycle.Bin
echo System Volume Information
echo node_modules
echo .venv
echo __pycache__
echo *.tmp
echo *.lock
echo *.dmp
echo ~$*
) > "%EXCL_ROOT%"

echo. >> "%LOG%"
echo ============================================================ >> "%LOG%"
echo  Backup avviato: %DATE% %TIME% >> "%LOG%"
echo ============================================================ >> "%LOG%"


:: ── JOB 1: tutti i profili utente ────────────────────────────────────────
echo.
echo [1/2] Backup profili utente in archivio 7z...
echo       Archivio: %ARCHIVE_USERS%

%SZ% a -t7z "%ARCHIVE_USERS%" "C:\Users\*" -r -mx=5 -mmt=on -xr@"%EXCL_USERS%" >> "%LOG%" 2>&1


:: ── JOB 2: cartelle custom in radice C:\ + file sciolti ──────────────────
echo.
echo [2/2] Backup cartelle custom radice C:\ in archivio 7z...
echo       Archivio: %ARCHIVE_ROOT%

%SZ% a -t7z "%ARCHIVE_ROOT%" "C:\*" -r -mx=5 -mmt=on -xr@"%EXCL_ROOT%" -x!"pagefile.sys" -x!"hiberfil.sys" -x!"swapfile.sys" >> "%LOG%" 2>&1


:: ── Pulizia file temporanei ───────────────────────────────────────────────
del "%EXCL_USERS%" "%EXCL_ROOT%"


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
