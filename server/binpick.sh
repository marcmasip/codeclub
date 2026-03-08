#!/bin/bash

# binpick.sh - Copia un binario y sus dependencias a un root destino
# Uso: binpick.sh <binario> <destino>

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar uso
usage() {
    echo "Uso: $0 <binario> <destino>"
    echo "  <binario>: Ruta al binario ejecutable"
    echo "  <destino>: Directorio root destino (se esperan subdirs como usr/lib, usr/bin, etc.)"
    exit 1
}

# Verificar argumentos
if [ $# -ne 2 ]; then
    usage
fi

BINARY="$1"
DEST_ROOT="$2"

# Verificar que el binario existe
if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: El binario '$BINARY' no existe${NC}"
    exit 1
fi

# Verificar que el binario es ejecutable o es un objeto compartido
if [ ! -x "$BINARY" ] && ! file "$BINARY" | grep -q "ELF"; then
    echo -e "${RED}Error: '$BINARY' no es un binario ejecutable o librería ELF${NC}"
    exit 1
fi

# Crear directorio destino si no existe
if [ ! -d "$DEST_ROOT" ]; then
    echo -e "${YELLOW}Creando directorio destino: $DEST_ROOT${NC}"
    mkdir -p "$DEST_ROOT"
fi

# Función para copiar archivo preservando enlaces
copy_with_links() {
    local src="$1"
    local dst_dir="$2"
    
    # Crear directorio destino si no existe
    mkdir -p "$dst_dir"
    
    local dst_file="$dst_dir/$(basename "$src")"
    
    # Verificar si ya existe
    if [ -e "$dst_file" ]; then
        echo -e "  ${YELLOW}⊘${NC} Ya existe: $(basename "$src")"
        return 0
    fi
    
    # Si es un enlace simbólico, copiarlo y seguir la cadena
    if [ -L "$src" ]; then
        local link_target=$(readlink "$src")
        local src_dir=$(dirname "$src")
        
        echo -e "  ${GREEN}→${NC} Enlace: $(basename "$src") -> $link_target"
        
        # Copiar el enlace simbólico
        cp -P "$src" "$dst_file" 2>/dev/null || true
        
        # Si el target es relativo, resolverlo
        if [[ "$link_target" != /* ]]; then
            link_target="$src_dir/$link_target"
        fi
        
        # Copiar recursivamente el target si existe
        if [ -e "$link_target" ]; then
            copy_with_links "$link_target" "$dst_dir"
        fi
    else
        # Es un archivo regular, copiarlo con cp -a
        cp -a "$src" "$dst_dir/"
        echo -e "  ${GREEN}✓${NC} Copiado: $(basename "$src")"
    fi
}

# Copiar el binario principal
echo -e "${YELLOW}Copiando binario principal...${NC}"
BINARY_REALPATH=$(realpath "$BINARY")
BINARY_DIR=$(dirname "$BINARY_REALPATH")

# Determinar dónde colocar el binario (bin o sbin)
if [[ "$BINARY_REALPATH" == */sbin/* ]]; then
    DEST_BIN_DIR="$DEST_ROOT/usr/sbin"
elif [[ "$BINARY_REALPATH" == */bin/* ]]; then
    DEST_BIN_DIR="$DEST_ROOT/usr/bin"
else
    DEST_BIN_DIR="$DEST_ROOT/usr/bin"
fi

mkdir -p "$DEST_BIN_DIR"
copy_with_links "$BINARY" "$DEST_BIN_DIR"

# Hacer strip del binario
DEST_BINARY="$DEST_BIN_DIR/$(basename "$BINARY")"
if [ -f "$DEST_BINARY" ] && [ ! -L "$DEST_BINARY" ]; then
    echo -e "${YELLOW}Aplicando strip a $(basename "$BINARY")...${NC}"
    strip "$DEST_BINARY" 2>/dev/null || echo -e "${YELLOW}  Advertencia: No se pudo hacer strip${NC}"
fi

# Obtener dependencias con ldd
echo -e "\n${YELLOW}Analizando dependencias...${NC}"
DEPS=$(ldd "$BINARY_REALPATH" 2>/dev/null | grep "=>" | awk '{print $3}' | grep -v "^$")

if [ -z "$DEPS" ]; then
    echo -e "${GREEN}No se encontraron dependencias dinámicas${NC}"
    exit 0
fi

# Procesar cada dependencia
echo -e "${YELLOW}Copiando dependencias...${NC}"
for lib in $DEPS; do
    if [ -f "$lib" ]; then
        # Determinar directorio destino basado en la ubicación original
        if [[ "$lib" == */lib64/* ]]; then
            DEST_LIB_DIR="$DEST_ROOT/usr/lib64"
        elif [[ "$lib" == */lib32/* ]]; then
            DEST_LIB_DIR="$DEST_ROOT/usr/lib32"
        elif [[ "$lib" == */libx32/* ]]; then
            DEST_LIB_DIR="$DEST_ROOT/usr/libx32"
        else
            DEST_LIB_DIR="$DEST_ROOT/usr/lib"
        fi
        
        echo "$(basename "$lib"):"
        copy_with_links "$lib" "$DEST_LIB_DIR"
        
        # Hacer strip de la librería
        LIB_DEST="$DEST_LIB_DIR/$(basename "$lib")"
        if [ -f "$LIB_DEST" ] && [ ! -L "$LIB_DEST" ]; then
            strip "$LIB_DEST" 2>/dev/null || true
        fi
    fi
done

# Buscar y copiar el loader dinámico si existe
echo -e "\n${YELLOW}Verificando loader dinámico...${NC}"
LOADER=$(ldd "$BINARY_REALPATH" 2>/dev/null | grep "ld-linux" | awk '{print $1}')
if [ -n "$LOADER" ] && [ -f "$LOADER" ]; then
    LOADER_DIR=$(dirname "$LOADER")
    DEST_LOADER_DIR="$DEST_ROOT$LOADER_DIR"
    echo "Loader: $(basename "$LOADER")"
    copy_with_links "$LOADER" "$DEST_LOADER_DIR"
    
    # Hacer strip del loader
    LOADER_DEST="$DEST_LOADER_DIR/$(basename "$LOADER")"
    if [ -f "$LOADER_DEST" ] && [ ! -L "$LOADER_DEST" ]; then
        strip "$LOADER_DEST" 2>/dev/null || true
    fi
fi

echo -e "\n${GREEN}✓ Proceso completado exitosamente${NC}"
echo -e "Binario y dependencias copiados a: $DEST_ROOT"
