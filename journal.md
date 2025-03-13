- alles in Dieser file ist ab Tag 4, mit neuer Stuktur  
  
### MERKEN:
```
git pull
git add .
git commit -m "commit message"
git push
```  
  
# Bashscript Teil 3 (Tag 4)
Ich habe eine leichte Struktur in meine ordner gebracht.  
(ersichtlich mit `tree ~/m122`):  
```
m122
├── README.md
├── journal.md
├── medien
└── skripte
    ├── calc.sh
    ├── firstscript.sh
    └── scripthead.sh
```  
  
ich kann jetzt auch vom Terminal mein Git repository updaten.  
Vorlage für ein script erstellt ([scripthead.sh](skripte/scripthead.sh))  
Diese kann ich einfügen, indem ich in einem neuen script mit nano `ctrl+r` drücke, und dann den pfad für den `scripthead.sh` angebe.  
Neues script erstellt, das bc für Mathe benutzt ([calc.sh](skripte/calc.sh))  
Wichtige Funktionen im script:  
`read num1`  
speichert die eingabe des Benutzers in einer variable (in diesem Fall num1)  
```  
  
case $op in  #case leiten ein switch case statement ein, mit dem parameter $op (operator)
  +) result=$(echo "$num1 + $num2" | bc) ;;
  -) result=$(echo "$num1 - $num2" | bc) ;;
  \*) result=$(echo "$num1 * $num2" | bc) ;;  # * muss mit \ escaped werden
  /) result=$(echo "scale=2; $num1 / $num2" | bc) ;; # scale=2 für 2 Nachkommastellen
  *) echo "Invalid operator!" && exit 1 ;;  # * ist so wie der Default (in bash normalerweise "alles"). deswegen wurde er vorhin escaped (\*)
esac # case rückwarts geschrieben um den switch case zu beenden
```
