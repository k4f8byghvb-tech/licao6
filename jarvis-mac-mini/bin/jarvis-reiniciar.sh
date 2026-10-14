#!/bin/bash
# Reinicia o Jarvis (por exemplo depois de mudar o jarvis.conf).
# As habilidades NÃO precisam disto: são lidas de novo a cada ligação.
launchctl kickstart -k "gui/$(id -u)/pt.centralia.jarvis" && echo "Jarvis reiniciado."
