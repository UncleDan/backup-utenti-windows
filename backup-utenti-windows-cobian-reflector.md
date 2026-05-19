# Configurazione Cobian Reflector — Backup dati utente Windows

Il pacchetto include il file `backup-utenti-windows-cobian-reflector.lst`
che può essere aperto direttamente da Cobian Reflector tramite il menu
**File → Open list**, oppure copiato come `Main.lst` nella cartella
dei dati utente del programma (vedi sezione "Main.lst" in fondo).

Questa guida descrive la configurazione dei due task e come personalizzarla.

---

## Prerequisiti

- Cobian Reflector installato (versione 2.7.x)
- Esecuzione come Amministratore o installato come servizio con account privilegiato
- **Abilitare Volume Shadow Copy** in ogni task (vedi sotto) per gestire i file
  locked come NTUSER.DAT e OST di Outlook

---

## Task 1 — Profili utente (C:\Users)

### General
| Campo | Valore |
|---|---|
| Task name | `Backup Utenti` |
| Backup type | `Full` (oppure `Differential` per backup successivi) |
| Include subdirectories | ✔ |
| Create new separated backups | ✔ (crea una cartella per ogni esecuzione) |

### Files — Source
Aggiungere come directory sorgente:
```
C:\Users
```

### Files — Destination
Aggiungere la cartella di destinazione desiderata, es.:
```
D:\Backup\NomeMacchina\Users
```

### Filters — Exclude files (mask, separati da virgola)
Cobian Reflector accetta sia **maschere semplici** (`*.tmp`) sia
**espressioni regolari** per i path complessi. Inserire nel campo
**"Exclude these files"**:

```
*.tmp, *.lock, *.dmp, ~$*, Thumbs.db, desktop.ini, ntuser.dat.log*, NTUSER.DAT{*, usrclass.dat{*
```

### Filters — Exclude directories
Aggiungere come **directory escluse** (pulsante "Add directory" oppure
usando la regex nel campo mask con `FOFilterKind=4`):

Per escludere le cartelle di cache indipendentemente dal nome utente,
usare le seguenti **espressioni regolari** nel campo "Exclude these files":

```
.*\\AppData\\Local\\Temp\\.*
.*\\AppData\\Local\\Packages\\.*
.*\\AppData\\Local\\Microsoft\\Windows\\INetCache\\.*
.*\\AppData\\Local\\Microsoft\\Windows\\WebCache\\.*
.*\\AppData\\Local\\Microsoft\\Windows\\Caches\\.*
.*\\AppData\\Local\\Microsoft\\Windows\\Explorer\\.*
.*\\AppData\\Local\\Google\\Chrome\\User Data\\Default\\Cache\\.*
.*\\AppData\\Local\\Microsoft\\Edge\\User Data\\Default\\Cache\\.*
.*\\AppData\\Local\\pip\\cache\\.*
.*\\AppData\\Local\\npm-cache\\.*
.*\\AppData\\Local\\Yarn\\.*
.*\\node_modules\\.*
.*\\\.venv\\.*
.*\\__pycache__\\.*
```

> **Nota:** In Cobian Reflector i filtri regex vanno inseriti uno per riga
> nel campo "Exclude these files" — il programma li riconosce come regex
> quando contengono `.*`. Verificare il funzionamento con un backup di test.

### Advanced
| Campo | Valore |
|---|---|
| Use Volume Shadow Copy | ✔ (fondamentale per file locked) |
| Ignore empty directories | ✔ (opzionale, riduce il rumore nel log) |

---

## Task 2 — Cartelle custom in radice C:\

### General
| Campo | Valore |
|---|---|
| Task name | `Backup Root Custom` |
| Backup type | `Full` (oppure `Differential`) |
| Include subdirectories | ✔ |
| Create new separated backups | ✔ |

### Files — Source
Aggiungere come directory sorgente:
```
C:\
```

### Files — Destination
```
D:\Backup\NomeMacchina\root
```

### Filters — Exclude directories
Aggiungere le seguenti **directory come esclusioni esplicite** tramite
il pulsante "Add directory" nella sezione Filters:

```
C:\Windows
C:\Windows.old
C:\Program Files
C:\Program Files (x86)
C:\ProgramData
C:\Users
C:\Recovery
C:\PerfLogs
C:\$Recycle.Bin
C:\System Volume Information
```

Aggiungere poi le seguenti **espressioni regolari** per le cartelle dev:

```
.*\\node_modules\\.*
.*\\\.venv\\.*
.*\\__pycache__\\.*
```

### Filters — Exclude files (mask)
```
*.tmp, *.lock, *.dmp, ~$*, pagefile.sys, hiberfil.sys, swapfile.sys
```

### Advanced
| Campo | Valore |
|---|---|
| Use Volume Shadow Copy | ✔ |

---

## Pianificazione

Nella scheda **Schedule** di ogni task impostare la frequenza desiderata.
Configurazione consigliata:

| Campo | Valore suggerito |
|---|---|
| Schedule type | `Daily` |
| Time | `02:00` (notte, macchina accesa) |
| Full copies to keep | `7` (una settimana di storico) |

---

## Note operative

**Volume Shadow Copy** — è la funzione più importante da abilitare:
permette di copiare file aperti e locked (NTUSER.DAT, OST di Outlook, ecc.)
senza errori. Richiede che il servizio VSS di Windows sia attivo.

**Utenti di sistema** — con sorgente `C:\Users` vengono inclusi anche
`Default`, `Public` e `All Users`, coerentemente con gli altri script
del pacchetto.

**Cartelle di sistema escluse dal Task 2** — vengono escluse tramite
path assoluti, quindi una eventuale cartella `C:\miei-dati\Recovery\`
non viene esclusa per errore.

**Gestionali con dati in ProgramData** — se si usa software (es.
TeamSystem, Zucchetti) che salva dati in `C:\ProgramData\`, creare un
terzo task dedicato con quella cartella come sorgente specifica.

**Main.lst** — il file di configurazione generato da Cobian Reflector
si trova tipicamente in:
```
C:\Users\<utente>\AppData\Local\CobianSoft\Cobian Reflector\
```
Può essere copiato su un'altra macchina per replicare la configurazione,
ma i path assoluti vanno verificati e adattati manualmente.
