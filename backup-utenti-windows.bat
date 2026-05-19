@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  Backup dati utente + cartelle custom - radice C:\
::  Richiede: esecuzione come Amministratore
::  Destinazione: modificare DST secondo necessità
:: ============================================================

set SRC=C:\
set DST=D:\Backup\%COMPUTERNAME%
set LOG=%DST%\backup.log

:: Crea cartella di destinazione se non esiste
if not exist "%DST%" mkdir "%DST%"

echo. >> "%LOG%"
echo ============================================================ >> "%LOG%"
echo  Backup avviato: %DATE% %TIME% >> "%LOG%"
echo ============================================================ >> "%LOG%"


:: ── JOB 1: tutti i profili utente ────────────────────────────────────────
echo.
echo [1/3] Backup profili utente...

for /d %%U in (C:\Users\*) do (
    echo      - %%~nxU
    robocopy "%%U" "%DST%\Users\%%~nxU" ^
      /E /COPYALL /R:1 /W:2 /MT:8 ^
      /XD "AppData\Local\Temp" ^
          "AppData\Local\Packages" ^
          "AppData\Local\Microsoft\Windows\INetCache" ^
          "AppData\Local\Microsoft\Windows\WebCache" ^
          "AppData\Local\Microsoft\Windows\Caches" ^
          "AppData\Local\Microsoft\Windows\Explorer" ^
          "AppData\Local\Google\Chrome\User Data\Default\Cache" ^
          "AppData\Local\Microsoft\Edge\User Data\Default\Cache" ^
          "AppData\Local\pip\cache" ^
          "AppData\Local\npm-cache" ^
          "AppData\Local\Yarn" ^
          "node_modules" ".venv" "__pycache__" ^
      /XF *.tmp *.lock *.dmp ~$* Thumbs.db desktop.ini ^
          ntuser.dat.log* "NTUSER.DAT{*" "usrclass.dat{*" ^
      /XJ ^
      /LOG+:"%LOG%" /TEE /NP
)


:: ── JOB 2: cartelle custom in radice C:\ (non di sistema) ────────────────
echo.
echo [2/3] Backup cartelle custom in radice C:\...

robocopy "C:\" "%DST%\root" ^
  /E /COPYALL /R:1 /W:2 /MT:8 ^
  /XD "C:\Windows" ^
      "C:\Windows.old" ^
      "C:\Program Files" ^
      "C:\Program Files (x86)" ^
      "C:\ProgramData" ^
      "C:\Users" ^
      "C:\Recovery" ^
      "C:\PerfLogs" ^
      "C:\$Recycle.Bin" ^
      "C:\System Volume Information" ^
      "node_modules" ".venv" "__pycache__" ^
  /XF *.tmp *.lock *.dmp ~$* ^
  /XJ ^
  /LOG+:"%LOG%" /TEE /NP


:: ── JOB 3: file sciolti in radice C:\ (non cartelle) ─────────────────────
echo.
echo [3/3] Backup file in radice C:\...

robocopy "C:\" "%DST%\root" /LEV:1 ^
  /XD * ^
  /XF pagefile.sys hiberfil.sys swapfile.sys ^
      *.tmp *.log *.dmp ^
  /LOG+:"%LOG%" /TEE /NP


:: ── Fine ──────────────────────────────────────────────────────────────────
echo.
echo ============================================================ >> "%LOG%"
echo  Backup completato: %DATE% %TIME% >> "%LOG%"
echo ============================================================ >> "%LOG%"

echo.
echo Backup completato. Log: %LOG%
echo.
pause
