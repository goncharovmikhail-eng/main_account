#!/bin/bash

set -e

# Настройки
VG_NAME="VG003"
LV_NAME="lv_root"
LV_PATH="/dev/${VG_NAME}/${LV_NAME}"

echo "📦 Расширение LVM-диска: ${LV_PATH}"

# 1. Проверка, что мы root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Этот скрипт нужно запускать от root"
    exit 1
fi

# 2. Найдём основной физический диск с LVM PV
PV_DEVICE=$(pvs --noheadings -o pv_name | head -n1 | awk '{$1=$1};1')
echo "🔍 Физическое устройство LVM: $PV_DEVICE"

# 3. Расширяем Physical Volume (если диск увеличен)
echo "📏 Расширяем PV: $PV_DEVICE"
pvresize "$PV_DEVICE"

# 4. Расширяем логический том на всё свободное место
echo "🔧 Расширяем LV на всё свободное пространство"
lvextend -l +100%FREE "$LV_PATH"

# 5. Расширяем файловую систему ext4
echo "🧰 Расширяем файловую систему ext4"
resize2fs "$LV_PATH"

echo "✅ Готово! Текущий статус:"
df -hT | grep "$LV_PATH"
