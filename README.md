# Backup dati utente Windows — Pacchetto script

Questo pacchetto contiene tre versioni dello stesso schema di backup per sistemi Windows 10 e Windows 11.

L'obiettivo è copiare **tutti i dati utente e le cartelle custom** presenti sul disco `C:\`, escludendo il sistema operativo, i programmi installati, i file di paging e ibernazione, le cache e le cartelle ricostruibili.

---

## File inclusi

| File | Strumento | Modalità |
|---|---|---|
| `backup_utenti_windows.bat` | Robocopy (built-in Windows) | Copia file-level, mirror incrementale |
| `backup_utenti_windows.ffs_batch` | FreeFileSync | Sincronizzazione con interfaccia grafica |
| `backup_utenti_windows_7z.bat` | 7-Zip | Archivi compressi datati |

---

## Cosa viene copiato

- `C:\Users\*` — tutti i profili utente, inclusi `Default`, `Public` e profili di sistema
- Qualsiasi cartella non di sistema presente in radice `C:\` (es. `C:\dati\`, `C:\winPenPack\`, stack di sviluppo locali, ecc.)
- File sciolti in radice `C:\` (esclusi quelli di sistema)

## Cosa viene escluso

**Cartelle di sistema:**
`Windows`, `Windows.old`, `Program Files`, `Program Files (x86)`, `ProgramData`, `Recovery`, `PerfLogs`, `$Recycle.Bin`, `System Volume Information`

**File di sistema:**
`pagefile.sys`, `hiberfil.sys`, `swapfile.sys`

**Cache e temporanei (ovunque nell'albero):**
`AppData\Local\Temp`, `AppData\Local\Packages`, cache di Internet Explorer/Edge/Chrome/Firefox, cache pip/npm/Yarn

**Cartelle di sviluppo ricostruibili:**
`node_modules`, `.venv`, `__pycache__`

**File temporanei e lock:**
`*.tmp`, `*.lock`, `*.dmp`, `~$*`, `Thumbs.db`, `desktop.ini`, lock file del registro di Windows (`ntuser.dat.log*`, `NTUSER.DAT{*`, `usrclass.dat{*`)

---

## Prerequisiti

- Esecuzione come **Amministratore** (tutti e tre gli script)
- **FreeFileSync** installato per il file `.ffs_batch`
- **7-Zip** installato in `C:\Program Files\7-Zip\` per lo script `_7z.bat` (il percorso è modificabile nella variabile `SZ` in cima al file)

---

## Configurazione prima dell'uso

### backup_utenti_windows.bat e backup_utenti_windows_7z.bat

Modificare la variabile `DST` in cima al file con il percorso di destinazione reale:

```batch
set DST=D:\Backup\%COMPUTERNAME%
```

`%COMPUTERNAME%` viene espanso automaticamente con il nome della macchina.

### backup_utenti_windows.ffs_batch

FreeFileSync non espande variabili d'ambiente nei path. Sostituire `NomeMacchina` nei due tag `<Right>` con il nome reale del PC o con il percorso di destinazione desiderato:

```xml
<Right>D:\Backup\NomeMacchina\Users</Right>
<Right>D:\Backup\NomeMacchina\root</Right>
```

---

## Note operative

**File locked** — NTUSER.DAT e i file OST di Outlook aperti da un utente loggato non possono essere copiati a caldo. Robocopy e 7-Zip li salteranno con un warning nel log senza interrompere il backup. Per catturarli occorre un VSS snapshot pre-backup oppure eseguire il backup a utente disconnesso.

**OneDrive** — se i profili utente hanno OneDrive attivo in modalità "file a richiesta", i file non scaricati localmente risulteranno stub e non verranno copiati. Se si vuole escludere del tutto la cartella OneDrive (già presente nel cloud), aggiungere alle esclusioni `OneDrive` e `OneDrive - NomeSocieta`.

**Gestionale con dati in ProgramData** — software come TeamSystem, Zucchetti o simili a volte scrivono dati utente in `C:\ProgramData\`. Quella cartella è esclusa dal backup perché contiene principalmente file di programma. Se necessario, aggiungere un job/pair dedicato con il path specifico del gestionale.

**Versione 7z — archivi datati** — lo script `_7z.bat` produce un nuovo archivio ad ogni esecuzione con la data nel nome (`users_GG-MM-AAAA.7z`). Per non accumulare archivi storici, aggiungere una pulizia automatica o pianificare la rotazione manualmente.

**Pianificazione** — tutti e tre gli script possono essere pianificati tramite **Utilità di pianificazione di Windows** (Task Scheduler) con account SYSTEM e trigger notturno. Per FreeFileSync è disponibile anche **RealTimeSync** per backup in tempo reale al variare dei file.
