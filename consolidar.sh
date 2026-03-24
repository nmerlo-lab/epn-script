#!/bin/bash

# Script consolidar.sh
ENTRADA="$HOME/EPNro1/entrada"
SALIDA="$HOME/EPNro1/salida"
PROCESADO="$HOME/EPNro1/procesado"
ARCHIVO_SALIDA="$SALIDA/${FILENAME}.txt"

procesar_archivo() {
    archivo="$1"
    echo "Procesando: $archivo"
    cat "$archivo" >> "$ARCHIVO_SALIDA"
    mv "$archivo" "$PROCESADO/"
    echo "Archivo $archivo procesado"
}

if [ ! -d "$ENTRADA" ]; then
    echo "ERROR: No existe la carpeta $ENTRADA"
    exit 1
fi

if [ -z "$FILENAME" ]; then
    echo "ERROR: Variable FILENAME no definida"
    exit 1
fi

touch "$ARCHIVO_SALIDA"
echo "Script consolidar.sh iniciado. Monitoreando $ENTRADA"

while true; do
    for archivo in "$ENTRADA"/*.txt; do
        if [ -f "$archivo" ]; then
            procesar_archivo "$archivo"
        fi
    done
    sleep 2
done
