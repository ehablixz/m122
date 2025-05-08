## Lernjournal Ajan Zuberi

Erster Tag
---

### Linux auf einer VM installiert.
Wir haben VMWare/Oracle VM installiert, und darauf dann ein System mit Ubuntu Server aufgestellt.  
Während sich Linux installiert hat haben wir einen Test gemacht, um zu schauen wie gut wir uns schon in Linux auskennen.  

Zweiter Tag
---

### Verzeichnisse und Partitionen angeschaut.
Wir haben verschiedene Filesysteme aufgezählt.  
Wir haben auch geschaut wie die bennenung der Partitionen funktioniert.

| | Disk Name | Partition 1 | Partition 2 |
|---|---|---|---|
| **Disk 1** | sda | sda1 | sda2 |
| **Disk 2** | sdb | sdb1 | sdb2 |
| **Disk 3** | sdc | sdc1 | sdc2 |

Dritter Tag
---

Bash-Skripte sind nützlich zur Automatisierung von Aufgaben. Ein typisches Skript beginnt mit dem **Shebang** (`#!/bin/bash`), der festlegt, dass das Skript mit Bash ausgeführt wird.

### Erstellen eines Skripts  
1. Leere Datei erstellen:  
   ```sh
   touch meinscript.sh
   ```

2. Datei mit `nano` bearbeiten:
    
    ```sh
    nano meinscript.sh
    ```
    
3. Skript ausführen:
    
    ```sh
    chmod +x meinscript.sh
    ./meinscript.sh
    ```
    

## Variablen in Bash

- **Zuweisung:** `varname=wert` (kein Leerzeichen um `=`)
- **Ausgabe:** `echo $varname`
- **Arithmetik:**
    
    ```sh
    a=10
    b=5
    sum=$((a + b))  # Addition
    ```
    
- **Besondere Variablen:**
    
    |Variable|Bedeutung|
    |---|---|
    |`$0`|Skriptname|
    |`$1 - $9`|Parameter beim Skriptaufruf|
    |`$#`|Anzahl der Parameter|
    |`$$`|Prozess-ID des Skripts|
    |`$?`|Letzter Exit-Status|
    

## Kontrollstrukturen

### **If-Abfragen**

```sh
if [ $var -gt 10 ]; then
    echo "Größer als 10"
elif [ $var -eq 10 ]; then
    echo "Genau 10"
else
    echo "Kleiner als 10"
fi
```

### **Schleifen**

#### **For-Schleife über Argumente**

```sh
for datei in "$@"; do
    [ -f $datei ] && echo "$datei ist eine Datei"
    [ -d $datei ] && echo "$datei ist ein Verzeichnis"
done
```

#### **For-Schleife mit Array**

```sh
array=(eins zwei drei)
for wert in "${array[@]}"; do
    echo $wert
done
```

#### **While-Schleife**

```sh
while [ $var -lt 10 ]; do
    echo "Var ist $var"
    var=$((var + 1))
done
```

## Ein-/Ausgabeumleitungen

|Umleitung|Bedeutung|
|---|---|
|`>`|Überschreibt eine Datei|
|`>>`|Hängt an eine Datei an|
|`2>`|Leitet Fehlerausgabe um|
|`2>&1`|Kombiniert Fehler- und Standardausgabe|
|`/dev/null`|Unterdrückt Ausgabe|

Beispiel:

```sh
ls > liste.txt        # Ausgabe in Datei
./script 2> fehler.txt # Fehlerausgabe umleiten
./script > ausgabe.txt 2>&1  # Beides in eine Datei
```

## Pipelines

Ketten Befehle, indem sie den Output eines Befehls als Input für den nächsten verwenden.

```sh
cat datei.txt | grep "hallo" | sort | uniq
```

## Skripte debuggen

- `bash -x script.sh` → Zeigt alle Befehle vor der Ausführung
- `set -e` → Stoppt Skript bei Fehlern

## Skripte extern bearbeiten und kopieren

1. Skript mit `scp` auf einen Server kopieren:
    
    ```sh
    scp script.sh user@server:/home/user/
    ```
    
2. Auf dem Server ausführen:
    
    ```sh
    ssh user@server
    chmod +x script.sh
    ./script.sh
    ```
