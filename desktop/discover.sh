#!/bin/bash

URL="$1"

DIR_URL="${URL%/*}/"     
FILENAME="${URL##*/}"      

PKG_NAME=$(echo "$FILENAME" | sed -E 's/-[0-9].*//')

EXT=$(echo "$FILENAME" | grep -oE '\.(tar\.[a-z0-9]+|tgz|tbz2)$')

echo "Buscando actualizaciones para: $PKG_NAME $EXT"
echo "Directorio base: $DIR_URL"

LATEST_FILE=$(curl -sL "$DIR_URL" | \
    grep -oEi 'href="[^"]+"' | \
    cut -d'"' -f2 | \
    grep -E "${PKG_NAME}-[0-9].*\\${EXT}$" | \
    sort -V | \
    tail -n 1)

if [ -z "$LATEST_FILE" ]; then
    echo "❌ No se encontraron versiones válidas en el directorio."
    exit 1
fi

echo "-----------------------------------"
echo "Versión actual de la URL: $FILENAME"
echo "Última versión en el dir: $LATEST_FILE"

if [ "$FILENAME" != "$LATEST_FILE" ]; then
    echo "✅ ¡Hay una nueva versión disponible! -> ${DIR_URL}${LATEST_FILE}"
else
    echo "👍 Ya tienes la última versión."
fi
