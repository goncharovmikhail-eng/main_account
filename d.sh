#!/usr/bin/env bash

disposable=false
keep_running=false
container_name="box"
snapshot_image="goncharovmikhail/personal:sandbox"

while getopts ":dkn:" opt; do
  case $opt in
    d) disposable=true ;;
    k) keep_running=true ;;
    n) container_name="$OPTARG" ;;
    \?) echo "Неизвестная опция: -$OPTARG" >&2; exit 1 ;;
    :) echo "Опция -$OPTARG требует аргумент." >&2; exit 1 ;;
  esac
done

shift $((OPTIND - 1))
image="$1"

if [[ -z "$image" ]]; then
  echo "Usage: $0 [-d] [-k] [-n name] <image>"
  exit 1
fi

# Запуск контейнера
if docker ps -a --format '{{.Names}}' | grep -qw "$container_name"; then
  docker start "$container_name" > /dev/null
else
  docker run -dit --name "$container_name" "$image" bash
fi

docker exec -it "$container_name" bash

# Завершение
if $disposable; then
  docker rm -f "$container_name"
  docker images "$snapshot_image" --format '{{.Repository}}:{{.Tag}}' | grep -q "^$snapshot_image$" && docker rmi "$snapshot_image"
elif $keep_running; then
  docker commit "$container_name" "$snapshot_image"
else
  docker commit "$container_name" "$snapshot_image"
  docker stop "$container_name"
fi
