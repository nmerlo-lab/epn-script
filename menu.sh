#!/bin/bash

# Script de menú para procesar archivos de notas.:D  
# LA variable FILENAME debe estar definida: export FILENAME=notas

mostrar_menu() {
    echo ""
    echo "========== MENÚ PRINCIPAL =========="
    echo "1) Crear entorno"
    echo "2) Correr proceso (background)"
    echo "3) Mostrar alumnos ordenados por padrón"
    echo "4) Mostrar las 10 notas más altas"
    echo "5) Buscar alumno por padrón"
    echo "6) Salir"
    echo "===================================="
    echo -n "Seleccione una opción: "
}

# Opción 1: Este crea directorios
crear_entorno() {
    echo "Creando entorno..."
    
    if [ -d "$HOME/EPNro1" ]; then
        echo "El directorio EPNro1 ya existe."
    else
        mkdir -p "$HOME/EPNro1"
        echo "Directorio $HOME/EPNro1 creado."
    fi
    
    mkdir -p "$HOME/EPNro1/entrada"
    mkdir -p "$HOME/EPNro1/salida"
    mkdir -p "$HOME/EPNro1/procesado"
    
    echo "Carpetas creadas: entrada, salida, procesado"
}

# Opción 2: Correr proceso en background
correr_proceso() {
    echo "Iniciando proceso en background..."
    
    if [ ! -f "$HOME/EPNro1/consolidar.sh" ]; then
        echo "ERROR: No existe consolidar.sh en $HOME/EPNro1"
        return 1
    fi
    
    if [ -z "$FILENAME" ]; then
        echo "ERROR: Variable FILENAME no definida"
        echo "Ejecute: export FILENAME=nombre_archivo"
        return 1
    fi
    
    "$HOME/EPNro1/consolidar.sh" &
    echo $! > "$HOME/EPNro1/proceso.pid"
    echo "Proceso iniciado con PID: $!"
}

# Opción 3: Mostrar alumnos ordenados por padrón (primera columna)
mostrar_alumnos_ordenados() {
    ARCHIVO="$HOME/EPNro1/salida/${FILENAME}.txt"
    
    if [ ! -f "$ARCHIVO" ]; then
        echo "ERROR: No existe el archivo $ARCHIVO"
        return 1
    fi
    
    echo "Alumnos ordenados por número de padrón:"
    echo "======================================="
    sort -n -k1 "$ARCHIVO"
}

# Opción 4: Mostrar las 10 notas más altas (ordenar por ÚLTIMA columna)
mostrar_top10_notas() {
    ARCHIVO="$HOME/EPNro1/salida/${FILENAME}.txt"
    
    if [ ! -f "$ARCHIVO" ]; then
        echo "ERROR: No existe el archivo $ARCHIVO"
        return 1
    fi
    
    echo "Las 10 notas más altas:"
    echo "======================="
    # Usar awk para imprimir la nota (último campo) y toda la línea
    # Luego ordenar por nota y mostrar solo las primeras 10 notas. :V
    awk '{print $NF, $0}' "$ARCHIVO" | sort -rn -k1 | head -10 | awk '{$1=""; print substr($0,2)}'
}

# Opción 5: Buscar alumno por padrón
buscar_alumno() {
    ARCHIVO="$HOME/EPNro1/salida/${FILENAME}.txt"
    
    if [ ! -f "$ARCHIVO" ]; then
        echo "ERROR: No existe el archivo $ARCHIVO"
        return 1
    fi
    
    echo -n "Ingrese el número de padrón: "
    read padron
    
    resultado=$(grep "^$padron " "$ARCHIVO")
    
    if [ -z "$resultado" ]; then
        echo "No se encontró alumno con padrón: $padron"
    else
        echo "Datos del alumno:"
        echo "================="
        echo "$resultado"
    fi
}

# Limpiar entorno (para -d)
limpiar_entorno() {
    echo "Limpiando entorno..."
    
    if [ -f "$HOME/EPNro1/proceso.pid" ]; then
        pid=$(cat "$HOME/EPNro1/proceso.pid")
        if kill -0 $pid 2>/dev/null; then
            echo "Matando proceso PID: $pid"
            kill $pid
        fi
        rm "$HOME/EPNro1/proceso.pid"
    fi
    
    if [ -d "$HOME/EPNro1" ]; then
        rm -rf "$HOME/EPNro1"
        echo "Directorio EPNro1 eliminado"
    else
        echo "El directorio EPNro1 no existe"
    fi
}

# ========== PROGRAMA PRINCIPAL ==========

# Verificar parámetro -d
if [ "$1" = "-d" ]; then
    limpiar_entorno
    exit 0
fi

# Verificar variable FILENAME
if [ -z "$FILENAME" ]; then
    echo "ADVERTENCIA: FILENAME no está definida"
    echo "Definir con: export FILENAME=nombre"
fi

# Bucle principal
opcion=0
while [ "$opcion" != "6" ]; do
    mostrar_menu
    read opcion
    
    case $opcion in
        1) crear_entorno ;;
        2) correr_proceso ;;
        3) mostrar_alumnos_ordenados ;;
        4) mostrar_top10_notas ;;
        5) buscar_alumno ;;
        6) echo "Saliendo..." ;;
        *) echo "Opción inválida (1-6)" ;;
    esac
done

exit 0
