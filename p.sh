#!/usr/bin/env bash

disposable=false
keep_running=false
container_name="box"
snapshot_image="goncharovmikhail/personal:sandbox"
port_args=()
volume_args=()

while getopts ":dkn:p:v:" opt; do
  case $opt in
    d) disposable=true ;;
    k) keep_running=true ;;
    n) container_name="$OPTARG" ;;
    p) port_args+=("-p" "$OPTARG") ;;
    v) volume_args+=("-v" "$OPTARG") ;;
    \?) echo "Неизвестная опция: -$OPTARG" >&2; exit 1 ;;
    :) echo "Опция -$OPTARG требует аргумент." >&2; exit 1 ;;
  esac
done

shift $((OPTIND - 1))
image="$1"
shift

if [[ -z "$image" ]]; then
  echo "Usage: $0 [-d] [-k] [-n name] [-p host:container] [-v /host:/container] <image> [command...]"
  exit 1
fi

# Запуск контейнера
if podman ps -a --format '{{.Names}}' | grep -qw "$container_name"; then
  podman start "$container_name" > /dev/null
else
  podman run -dit --name "$container_name" \
    "${port_args[@]}" \
    "${volume_args[@]}" \
    "$image" "$@"
fi

# Проверка, что контейнер запущен
if ! podman ps --format '{{.Names}}' | grep -qw "$container_name"; then
  echo "Контейнер $container_name не запущен. Проверьте параметры запуска." >&2
  exit 1
fi

# Запуск bash/sh если это интерактивный образ
if [[ "$image" =~ (ubuntu|debian|centos|alpine|fedora) ]]; then
  podman exec -it "$container_name" bash || podman exec -it "$container_name" sh
fi

# Завершение
if $disposable; then
  podman rm -f "$container_name"
  podman images "$snapshot_image" --format '{{.Repository}}:{{.Tag}}' | grep -q "^$snapshot_image$" && podman rmi "$snapshot_image"
elif $keep_running; then
  podman commit "$container_name" "$snapshot_image"
else
  podman commit "$container_name" "$snapshot_image"
  podman stop "$container_name"
fi
