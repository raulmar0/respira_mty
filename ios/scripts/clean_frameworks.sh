#!/bin/sh
# Limpiar atributos extendidos y firmas de frameworks de Flutter
echo "Limpando frameworks embebidos..."

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
    echo "Limpiando $FRAMEWORK"
    xattr -cr "$FRAMEWORK"
    codesign --remove-signature "$FRAMEWORK"
done

echo "Limpieza completada."
