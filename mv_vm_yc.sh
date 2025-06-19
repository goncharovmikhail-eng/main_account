#!/bin/bash

echo "Для переноса требуется минимальная роль: compute.editor в обоих каталогах."

read -p "Импортируем снимок (1),образ (2) или vm(3)? " choice
read -p "Имя каталога, где находится цель: " folder_name

if [[ "$choice" == "1" ]]; then
    # Выводим список доступных снимков
    yc compute snapshot list --folder-name "$folder_name"

    # Ввод данных
    #заменить все на ID
    read -p "Введите имя снимка: " snapshot_name
    read -p "Введите имя образа: " image_name
    read -p "Введите описание образа: " description
    read -p "Документация: https://yandex.cloud/ru/docs/compute/concepts/image#images-optimized-for-deployment
Сделать образ оптимизированным? (y/n) " polled

    # Создание образа
    if [[ "$polled" == "n" ]]; then
        yc compute image create --folder-name "$folder_name" \
            --name "$image_name"  \
            --source-snapshot-name "$snapshot_name" \
            --description "$description"
    elif [[ "$polled" == "y" ]]; then
        yc compute image create --folder-name "$folder_name" \
            --name "$image_name"  \
            --source-snapshot-name "$snapshot_name" \
            --description "$description" \
            --pooled
    else
        echo "Ошибка: Введите только 'y' или 'n'"
        exit 1
    fi

    echo "Скопируйте ID образа. "
    yc compute image list --folder-name "$folder_name"
    read -p "Введите ID образа: " image_id
    yc compute image create --source-image-id=$image_id --name $image_name
    echo "Проверка: "
    yc compute image list

elif [[ "$choice" == "2" ]]; then

    read -p "Имя нового образа в каталоге доставки: : " image_name
    echo "Скоппируйте ID образа."
    yc compute image list --folder-name "$folder_name"
    read -p "Введите ID образа: " image_id
    yc compute image create --source-image-id=$image_id --name $image_name
    echo "Проверка: "
    yc compute image list
    echo "Done"
elif [[ "$choice" == "3" ]]; then
    echo "Для переноса VM требуется минимальная роль: compute.editor, vpc.viever"
    echo "Выберите папку, где находится целевая VM:"
    yc resource-manager folder list
    read -p "Введите имя каталога, где находится VM: " folded_name
    yc compute instance list --folder-name "$folded_name"
    read -p "Введите ID VM: " VM_ID
    read -p "Введите ID каталога назначения: " destination_folder_id
    yc compute instance move \
        --folder-name "$folded_name" \
        --id "$VM_ID" \
        --destination-folder-id "$destination_folder_id"
    echo "Done."
else
    echo "Ошибка: Введите только '1', '2' или '3'"
    exit 1
fi
