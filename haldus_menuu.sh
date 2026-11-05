#!/bin/bash

# Kontrollime, kas skripti käivitatakse sudo-õigustes. Kui ei, siis lõpetame töö.
if [ "$EUID" -ne 0 ]; then
    echo "VIGA: Seda skripti peab käivitama sudo õigustes! (sudo ./haldus_menuu.sh)"
    exit 1
fi

# Lõpmatu tsükkel menüü kuvamiseks, kuni kasutaja valib väljumise
while true; do
    echo ""
    echo "=========================================="
    echo "           TARKVARA HALDUSMENÜÜ           "
    echo "=========================================="
    echo "1) Uuenda süsteemi tarkvara (apt update & upgrade)"
    echo "2) Paigalda ja käivita apache2"
    echo "3) Eemalda apache2 ja seotud paketid"
    echo "4) Välju menüüst"
    echo "=========================================="
    read -p "Sisesta oma valik [1-4]: " valik
    echo ""

    case $valik in
        1)
            echo "[INFO] Uuendan paketihalduri andmeid ja tarkvara..."
            # Käivitatakse uuendused, -y vastab vaikimisi 'yes'
            if apt update && apt upgrade -y; then
                echo "[OK] Süsteemi tarkvara on edukalt uuendatud!"
            else
                echo "[VIGA] Süsteemi uuendamisel tekkis tõrge."
            fi
            ;;
        2)
            echo "[INFO] Kontrollin apache2 olemasolu..."
            # Kontrollitakse dpkg abil, kas apache2 on juba paigaldatud
            if dpkg -l | grep -q "^ii  apache2 "; then
                echo "[INFO] apache2 on juba süsteemi paigaldatud!"
            else
                echo "[INFO] apache2 pole paigaldatud. Alustan paigaldust..."
                # Paigaldatakse apache2 vaikimisi 'yes' kinnitusega
                if apt install apache2 -y; then
                    echo "[OK] apache2 paigaldamine õnnestus!"
                    # Käivitatakse ja lubatakse teenus automaatselt taaskäivitusel
                    systemctl start apache2 && systemctl enable apache2
                    echo "[OK] apache2 teenus on käivitatud."
                else
                    echo "[VIGA] apache2 paigaldamine ebaõnnestus."
                fi
            fi
            ;;
        3)
            echo "[INFO] Kontrollin, kas apache2 on olemas eemaldamiseks..."
            if dpkg -l | grep -q "^ii  apache2 "; then
                echo "[INFO] Lülitan apache2 teenuse välja..."
                # Peatatakse teenus ja võetakse automaatkäivitus maha
                systemctl stop apache2 2>/dev/null
                systemctl disable apache2 2>/dev/null
                
                echo "[INFO] Eemaldan apache2 ja sellega seotud paketid..."
                # purge eemaldab ka seaded ja autoremove puhastab sõltuvused (-y kinnitab vaikimisi)
                if apt purge apache2 -y && apt autoremove -y; then
                    echo "[OK] apache2 ja sellega seotud paketid on edukalt eemaldatud!"
                else
                    echo "[VIGA] apache2 eemaldamisel tekkis viga."
                fi
            else
                echo "[HOIATUS] apache2 tarkvara ei leitud süsteemist, midagi pole eemaldada."
            fi
            ;;
        4)
            echo "Ilusat päeva! Väljun menüüst."
            break # Murrab tsükli ja lõpetab skripti töö
            ;;
        *)
            # Käitub olukorras, kus kasutaja sisestab midagi muud peale 1-4
            echo "[HOIATUS] Valikut '$valik' pole olemas! Palun vali number vahemikus 1-4."
            ;;
    esac
done
