#!/bin/bash
# =====================================================================
# ÜLESANNE 14: TARKVARA HALDUSMENÜÜ
# =====================================================================

# Kontrollime juurkasutaja (root/sudo) õigusi, kuna apt ja systemctl nõuavad seda
if [ "$EUID" -ne 0 ]; then
    echo "VIGA: Seda skripti peab käivitama sudo õigustes!"
    exit 1
fi

while true; do
    echo ""
    echo "=== TARKVARA HALDUSMENÜÜ ==="
    echo "1) Uuenda süsteemi tarkvara"
    echo "2) Paigalda ja käivita apache2"
    echo "3) Eemalda apache2 tarkvara"
    echo "4) Välju menüüst"
    echo "============================"
    read -p "Sisesta oma valik [1-4]: " valik
    echo ""

    case $valik in
        1)
            echo "[INFO] Uuendan paketihaldurit ja tarkvara..."
            # -y tagab vaikimisi 'yes' vastuse kõigile küsimustele
            if apt-get update && apt-get upgrade -y; then
                echo "[OK] Süsteem on edukalt uuendatud!"
            else
                echo "[VIGA] Süsteemi uuendamine ebaõnnestus."
            fi
            ;;
        2)
            echo "[INFO] Kontrollin apache2 olemasolu..."
            # Kontrollime dpkg abil, kas apache2 on paigaldatud (ii staatusega)
            if dpkg -l | grep -q "^ii  apache2 "; then
                echo "[INFO] apache2 on juba paigaldatud!"
            else
                echo "[INFO] Paigaldan apache2..."
                if apt-get install apache2 -y; then
                    echo "[OK] apache2 paigaldamine õnnestus!"
                    # Käivitame teenuse ja lubame automaatkäivituse
                    systemctl start apache2 && systemctl enable apache2
                    echo "[OK] apache2 teenus töötab."
                else
                    echo "[VIGA] apache2 paigaldamine ebaõnnestus."
                fi
            fi
            ;;
        3)
            echo "[INFO] Kontrollin apache2 olemasolu eemaldamiseks..."
            if dpkg -l | grep -q "^ii  apache2 "; then
                echo "[INFO] Peatan apache2 teenuse..."
                systemctl stop apache2 2>/dev/null
                systemctl disable apache2 2>/dev/null
                
                echo "[INFO] Eemaldan apache2 ja puhastan seotud paketid..."
                # purge eemaldab konfiguratsiooni, autoremove kustutab mittevajalikud sõltuvused
                if apt-get purge apache2 -y && apt-get autoremove -y; then
                    echo "[OK] apache2 tarkvara on edukalt süsteemist eemaldatud!"
                else
                    echo "[VIGA] Eemaldamisel tekkis tõrge."
                fi
            else
                echo "[HOIATUS] apache2 tarkvara ei leitud, midagi pole eemaldada."
            fi
            ;;
        4)
            echo "Väljun menüüst. Ilusat päeva!"
            break
            ;;
        *)
            echo "[HOIATUS] Valikut '$valik' pole olemas! Vali number 1-4."
            ;;
    esac
done
