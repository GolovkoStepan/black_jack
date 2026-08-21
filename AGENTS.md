# BlackJack — Agent Guide

## Что это

Ruby-гем, реализующий игру «Блек Джек» (Blackjack) с компьютерным дилером. CLI-приложение на `tty-prompt`. Версия: 0.0.1.

## Сборка, тесты, линтинг

```shell
bundle install          # зависимости
rake spec               # или `bundle exec rspec` — 148 примеров
rubocop                 # линтинг (см. gotcha ниже)
rake build              # собрать .gem в pkg/
rake install            # установить гем локально
rake release            # тег + push на rubygems.org
```

CI: `.github/workflows/ci.yml` — rubocop + rspec, Ruby 3.0.2.

## Структура (неочевидное)

| Путь | Содержимое |
|---|---|
| `lib/black_jack.rb` | Точка входа; `require` всех классов; пустой модуль `BlackJack` |
| `lib/black_jack/common/player.rb` | Миксин `Common::Player` — переиспользуется в `User` и `Computer` |
| `lib/black_jack/interface.rb` | Модуль рендеринга CLI (`tty-prompt`). Включается в `Game` через `include Interface`. **Не использовать вне Game** |
| `exe/black_jack` | Бинарник; создаёт `BlackJack::Game.new` |
| `spec/lib/black_jack/` | Тесты по структуре lib. UI-тесты хрупкие (мокают ввод) |

## Конвенции

- **Язык комментариев и документации** — русский. README, PLAN.md, комментарии в коде, строки интерфейса — всё на русском.
- `# frozen_string_literal: true` в каждом файле.
- RSpec: формат `documentation`, `--color`, `spec_helper` автоматически.
- Rubocop: отключены `Style/Documentation`, все метрики (`ClassLength`, `MethodLength`, `BlockLength`, `AbcSize`, `Complexity`). Не включайте их обратно без обсуждения.

## Gotchas

1. **Rubocop не работает на Ruby 3.4** — зависимость `base64` удалена из default gems. CI использует Ruby 3.0.2.
2. `Game` нарушает SRP: ставки, раздача, определение победителя и UI в одном классе. Рефакторинг запланирован (см. PLAN.md).
3. Магическое число `BET_PER_STEP = 10` — вынести в константу/конфиг.
4. Тузы считаются как 1 или 11 неявно через `Card.cards_sum`. Метода `soft_hand?` нет (запланирован).
5. Колода генерируется заново при каждом раунде (`Card.generate_cards`). Нет перемешивания между раундами.
