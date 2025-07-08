#!/bin/bash

# Проверка, установлен ли git
if ! command -v git &> /dev/null; then
  echo "Ошибка: git не установлен. Завершение работы."
  exit 1
fi

# Обновление репозиториев (fetch + pull)
gitupdate() {
  find . -type d -path "*/.git" | sed 's/\/.git$//' | while IFS= read -r dir; do
    echo "🔄 Проверяем $dir на обновления..."
    ( 
      cd "$dir" || { echo "❌ Не удалось перейти в $dir"; return; }
      if git fetch && git pull; then
        echo "✅ $dir успешно обновлён."
      else
        echo "⚠️ Ошибка при обновлении $dir."
      fi
    )
  done
}

# Проверка на незакоммиченные изменения и отправка в remote
gitcheck() {
  find . -type d -path "*/.git" | sed 's/\/.git$//' | while IFS= read -r dir; do
    echo "🔍 Проверяем $dir на изменения..."
    (
      cd "$dir" || { echo "❌ Не удалось перейти в $dir"; return; }
      if [[ -n $(git status --porcelain) ]]; then
        echo "📝 Найдены незакоммиченные изменения в $dir."
        git add . && git commit -m "full" && git push && \
        echo "✅ Изменения в $dir закоммичены и отправлены."
      else
        echo "✔️ Нет незакоммиченных изменений в $dir."
      fi
    )
  done
}

# Очистка локального хранилища Git
gittrach() {
  find . -type d -path "*/.git" | sed 's/\/.git$//' | while IFS= read -r dir; do
    echo "🧹 Очистка $dir..."
    (
      cd "$dir" || { echo "❌ Не удалось перейти в $dir"; return; }
      git prune && git gc && echo "✅ Очистка завершена в $dir."
    )
  done
}

# Запуск всех функций
gitupdate
gitcheck
gittrach

