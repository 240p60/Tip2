# Задание 1. REST API

## 1. Теоретическая часть (краткая выжимка)

### Методы REST API

REST использует методы HTTP по их семантическому назначению:

| Метод | Назначение | Идемпотентен? | Безопасен? | Типовые статусы |
|-------|-----------|:-------------:|:----------:|-----------------|
| **GET** | Получение данных без побочных эффектов | ✓ | ✓ | 200, 304, 404 |
| **POST** | Создание ресурса / отправка данных | ✗ | ✗ | 201, 200, 400, 409, 422 |
| **PUT** | Полная замена ресурса по известному URI | ✓ | ✗ | 200, 201, 204 |
| **PATCH** | Частичное обновление ресурса | ⚠ (зависит) | ✗ | 200, 204 |
| **DELETE** | Удаление ресурса | ✓ | ✗ | 200, 202, 204, 404 |
| **HEAD** | То же, что GET, но без тела | ✓ | ✓ | 200, 404 |
| **OPTIONS** | Получение списка поддерживаемых методов | ✓ | ✓ | 200, 204 |

- **Идемпотентность** — повторный вызов даёт тот же результат (важно для надёжных ретраев).
- **Безопасность** — не модифицирует состояние на сервере.

### JSON vs XML vs YAML

| Критерий | JSON | XML | YAML |
|----------|------|-----|------|
| Размер | компактный | объёмный (теги) | компактный |
| Парсинг | очень быстрый (нативный в JS) | медленнее, сложнее | медленнее JSON, без нативного парсера в браузере |
| Типы данных | строки, числа, bool, null, массивы, объекты | всё в строках, типы — через схему | как JSON + комментарии, ссылки, even-cleaner синтаксис |
| Читаемость | хорошая | посредственная | отличная |
| Комментарии | нет | да | да |
| Поддержка в браузере | нативная (`JSON.parse`/`stringify`) | через DOMParser | нет |
| Типичное применение | REST API, конфиги фронтенда | SOAP, унаследованные интеграции | конфиги (Kubernetes, GitHub Actions, Ansible) |

**Преимущества JSON для REST API:**
1. Меньший размер пакетов → ниже трафик и быстрее парсинг.
2. Нативная поддержка во всех современных языках, особенно в JS.
3. Простая типизация — числа остаются числами, без приведения.
4. Простая структура: объект, массив, скаляр — больше ничего не нужно.
5. Огромная экосистема инструментов (валидаторы, генераторы схем, форматтеры).

### JSON Schema

Это формальное описание структуры JSON-документа: какие поля обязательны, какие типы у значений, какие диапазоны допустимы и т.п.

Пример минимальной схемы:
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Vacancy",
  "type": "object",
  "required": ["id", "name", "salary"],
  "properties": {
    "id":     { "type": "string" },
    "name":   { "type": "string", "minLength": 1, "maxLength": 256 },
    "salary": {
      "type": "object",
      "required": ["currency"],
      "properties": {
        "from":     { "type": ["integer", "null"], "minimum": 0 },
        "to":       { "type": ["integer", "null"], "minimum": 0 },
        "currency": { "type": "string", "enum": ["RUR", "USD", "EUR"] },
        "gross":    { "type": "boolean" }
      }
    }
  }
}
```

Для тестировщика JSON Schema — это:
- быстрый способ проверить, что контракт API не сломан (assert-схемой в Postman/Pytest);
- основа для генерации mock-данных и автотестов.

### Сериализация и десериализация

- **Сериализация** — превращение внутреннего объекта (Java-класс, Python-dict, JS-object) в JSON-строку для передачи по сети.
- **Десериализация** — обратное преобразование: JSON-строка → объект в памяти приложения.

В контексте JSON это `JSON.stringify(obj)` / `JSON.parse(str)` в JS, `json.dumps()` / `json.loads()` в Python, `ObjectMapper` в Java и т.д.

Типовые баги, которые ловит тестировщик именно на этом стыке:
- Потеря типа (число пришло строкой);
- Потеря точности (большие `long` в JS теряют младшие разряды);
- Дата отдаётся в одном формате, парсится в другом;
- `null` vs отсутствие ключа vs пустая строка — разное поведение;
- Кодировка (UTF-8 BOM, кириллица в строках).

---

## 2. Выбор двух публичных REST API

Для сравнения выбрал два контрастных API:

| | API #1 | API #2 |
|---|--------|--------|
| Название | **HH.ru API** (HeadHunter API) | **JSONPlaceholder** |
| Назначение | Реальный production-API крупнейшего сервиса поиска работы в РФ | Учебно-моделирующий REST API с CRUD без авторизации |
| Документация | https://api.hh.ru/openapi/redoc и https://github.com/hhru/api | https://jsonplaceholder.typicode.com/ |
| Где использую в проекте | теоретический разбор + структура JSON-ответа (§ 4) | пошаговая работа в Postman (см. `task_2.md`) |

Такая пара даёт хороший контраст: production-API с пагинацией, авторизацией и i18n vs обучающий API без авторизации, удобный для практики Postman.

---

## 3. Сравнительная таблица API

| Критерий | **HH.ru API** | **JSONPlaceholder** |
|----------|---------------|---------------------|
| **Ссылка на документацию** | https://api.hh.ru/openapi/redoc<br>https://github.com/hhru/api/tree/master/docs | https://jsonplaceholder.typicode.com/<br>https://github.com/typicode/jsonplaceholder |
| **Базовый URL** | `https://api.hh.ru/` | `https://jsonplaceholder.typicode.com/` |
| **Основные эндпоинты** | `/vacancies` — поиск вакансий<br>`/vacancies/{id}` — одна вакансия<br>`/employers` — работодатели<br>`/areas` — регионы (справочник)<br>`/dictionaries` — справочники<br>`/me` — данные авторизованного пользователя<br>`/resumes/mine` — мои резюме (OAuth)<br>`/negotiations` — отклики на вакансии (OAuth) | `/posts` — посты (100 шт.)<br>`/comments` — комментарии (500 шт.)<br>`/albums`, `/photos`, `/todos`, `/users`<br>`/posts/{id}/comments` — вложенный ресурс |
| **Поддерживаемые методы** | GET — публично;<br>POST / PUT / DELETE — только с OAuth-токеном (для отправки отклика, изменения резюме и т.п.) | GET, POST, PUT, PATCH, DELETE — все доступны без авторизации (моделируется ответ, реальная запись на сервер не происходит) |
| **Формат запроса** | Query-параметры (`?text=qa&area=1&per_page=20`); тело — JSON для POST/PUT | Query-параметры для фильтрации;<br>тело — JSON для POST/PUT/PATCH |
| **Формат ответа** | JSON, кодировка UTF-8;<br>заголовок `Content-Type: application/json; charset=utf-8` | JSON, UTF-8;<br>тот же `Content-Type` |
| **Пагинация** | Курсорно-страничная: `page`, `per_page` (макс 100); в ответе `pages`, `found`, `per_page` | Неявная: можно использовать `_start`, `_limit`, `_page`, `_sort` |
| **Авторизация** | OAuth 2.0 (для приватных эндпоинтов);<br>для публичных GET-запросов — anonymous, но рекомендуется заголовок `HH-User-Agent: ApplicationName (email@example.com)` | Нет авторизации — полностью открытый API для обучения |
| **Версионирование** | Без явной версии в URL; обратная совместимость поддерживается через deprecation-warnings в заголовках; новые поля добавляются как опциональные | Без версионирования (учебный API не меняется) |
| **Лимиты (rate limit)** | Ограничение на количество запросов в минуту, при превышении — HTTP 403 / 429; разные лимиты для anonymous и authorized | Жёстких лимитов нет, но не для нагрузочного тестирования |
| **Локализация** | Поддержка `locale=RU/EN`, заголовок `Accept-Language` | Только английский |
| **Подход к дизайну (REST-зрелость)** | Уровень 2-3 по Richardson Maturity: ресурсо-ориентированные URL, корректные методы, HATEOAS-ссылки в части ответов (`alternate_url`, `apply_alternate_url`); коды состояний используются согласно стандарту | Уровень 2: ресурсо-ориентированные URL, корректные методы, без HATEOAS; коды состояний условные (POST всегда 201 даже на «фейковом» создании) |
| **Структура ответа** | Тело-объект с метаданными и массивом результатов: `{ "items": [...], "found": N, "pages": K, "per_page": M }` | Тело — массив или один объект напрямую, без обёртки |
| **Обработка ошибок** | Тело с описанием ошибки: `{ "errors": [{"type": "...", "value": "..."}], "description": "..." }`;<br>стандартные HTTP-коды | Простое тело-объект с сообщением; для несуществующих ID возвращает `{}` со статусом 404 |

### Главные отличия в подходе

- **Авторизация:** HH.ru — OAuth2 для модифицирующих операций; JSONPlaceholder вообще без авторизации (это учебный mock).
- **Обвязка ответа:** HH.ru обёртывает списки в объект с метаданными (важно для пагинации и сортировки), JSONPlaceholder возвращает «голые» массивы.
- **Версионирование:** HH.ru держит обратную совместимость и не использует v1/v2 в URL — типичный «эволюционный» подход. У JSONPlaceholder вопрос не стоит, потому что это статический mock.
- **Ошибки:** HH.ru имеет регулярную структуру с типизированными ошибками — это удобно для автотестов; JSONPlaceholder упрощён.
- **Production-нюансы:** rate-limit, locale, кэширование, HTTP-заголовки сжатия — есть у HH.ru, отсутствуют у JSONPlaceholder.

---

## 4. Пример JSON-ответа и разбор структуры

Анализируемый API: **HH.ru API** — https://api.hh.ru/openapi/redoc

Запрос: `GET https://api.hh.ru/vacancies/12345678` — получение карточки одной вакансии (ID гипотетический).

### Пример ответа (упрощённо, оставлены ключевые поля)

```json
{
  "id": "12345678",
  "premium": false,
  "name": "Junior QA Engineer",
  "department": null,
  "has_test": true,
  "response_letter_required": false,
  "area": {
    "id": "1",
    "name": "Москва",
    "url": "https://api.hh.ru/areas/1"
  },
  "salary": {
    "from": 100000,
    "to": 150000,
    "currency": "RUR",
    "gross": false
  },
  "type": {
    "id": "open",
    "name": "Открытая"
  },
  "address": null,
  "response_url": null,
  "sort_point_distance": null,
  "published_at": "2026-04-15T11:00:00+0300",
  "created_at": "2026-04-15T11:00:00+0300",
  "archived": false,
  "apply_alternate_url": "https://hh.ru/applicant/vacancy_response?vacancyId=12345678",
  "insider_interview": null,
  "url": "https://api.hh.ru/vacancies/12345678?host=hh.ru",
  "alternate_url": "https://hh.ru/vacancy/12345678",
  "relations": [],
  "employer": {
    "id": "1455",
    "name": "Сбер",
    "url": "https://api.hh.ru/employers/1455",
    "alternate_url": "https://hh.ru/employer/1455",
    "logo_urls": {
      "90":      "https://hhcdn.ru/employer-logo/1455-90.png",
      "240":     "https://hhcdn.ru/employer-logo/1455-240.png",
      "original":"https://hhcdn.ru/employer-logo-original/1455.png"
    },
    "vacancies_url": "https://api.hh.ru/vacancies?employer_id=1455",
    "trusted": true
  },
  "snippet": {
    "requirement": "Опыт ручного тестирования. Знание SQL...",
    "responsibility": "Тестирование сервисов банка..."
  },
  "schedule": { "id": "remote", "name": "Удалённая работа" },
  "experience": { "id": "noExperience", "name": "Нет опыта" },
  "employment": { "id": "full", "name": "Полная занятость" },
  "key_skills": [
    { "name": "Postman" },
    { "name": "SQL" },
    { "name": "REST API" }
  ],
  "languages": [
    {
      "id": "eng",
      "name": "Английский",
      "level": { "id": "b1", "name": "B1 — Средний" }
    }
  ],
  "professional_roles": [
    { "id": "124", "name": "Тестировщик" }
  ]
}
```

### Список ключей и их типов

| Путь к ключу | Тип | Описание |
|--------------|-----|----------|
| `id` | string | Уникальный идентификатор вакансии |
| `premium` | boolean | Является ли вакансия «премиум» |
| `name` | string | Название вакансии |
| `department` | object \| null | Подразделение работодателя |
| `has_test` | boolean | Требуется ли тестовое задание |
| `response_letter_required` | boolean | Требуется ли сопроводительное письмо |
| `area` | object | Регион вакансии |
| `area.id` | string | ID региона |
| `area.name` | string | Название региона |
| `area.url` | string (URL) | Ссылка на регион в API |
| `salary` | object \| null | Зарплата (может отсутствовать) |
| `salary.from` | integer \| null | Минимальная зарплата |
| `salary.to` | integer \| null | Максимальная зарплата |
| `salary.currency` | string | Валюта (`RUR`, `USD`, `EUR` и др.) |
| `salary.gross` | boolean | До налогов или после |
| `type` | object | Тип вакансии (открытая/закрытая) |
| `type.id` | string | ID типа |
| `type.name` | string | Локализованное название |
| `address` | object \| null | Адрес офиса |
| `published_at` | string (ISO 8601 datetime) | Дата публикации |
| `created_at` | string (ISO 8601 datetime) | Дата создания |
| `archived` | boolean | В архиве ли вакансия |
| `apply_alternate_url` | string (URL) | Ссылка на быстрый отклик на веб-сайте |
| `url` | string (URL) | Self-ссылка на ресурс в API |
| `alternate_url` | string (URL) | Ссылка на вакансию на сайте hh.ru |
| `relations` | array | Связанные сущности |
| `employer` | object | Работодатель |
| `employer.id` | string | ID работодателя |
| `employer.name` | string | Название |
| `employer.url` | string (URL) | Self-ссылка |
| `employer.alternate_url` | string (URL) | Ссылка на сайт работодателя |
| `employer.logo_urls` | object \| null | Map: размер → URL |
| `employer.logo_urls.90` | string (URL) | Логотип 90×90 |
| `employer.logo_urls.240` | string (URL) | Логотип 240×240 |
| `employer.logo_urls.original` | string (URL) | Логотип в исходном размере |
| `employer.vacancies_url` | string (URL) | Все вакансии работодателя |
| `employer.trusted` | boolean | Проверенный работодатель |
| `snippet` | object | Короткие фрагменты для списка вакансий |
| `snippet.requirement` | string \| null | Требования (отрывок с подсветкой) |
| `snippet.responsibility` | string \| null | Обязанности (отрывок) |
| `schedule` | object | График |
| `schedule.id` | string (enum: `fullDay`, `shift`, `flexible`, `remote`, `flyInFlyOut`) | ID графика |
| `schedule.name` | string | Локализованное название |
| `experience` | object | Требуемый опыт |
| `experience.id` | string (enum: `noExperience`, `between1And3`, `between3And6`, `moreThan6`) | ID опыта |
| `experience.name` | string | Локализованное название |
| `employment` | object | Тип занятости |
| `employment.id` | string (enum: `full`, `part`, `project`, `volunteer`, `probation`) | ID занятости |
| `employment.name` | string | Локализованное название |
| `key_skills` | array of objects | Ключевые навыки |
| `key_skills[].name` | string | Название навыка |
| `languages` | array of objects | Требуемые языки |
| `languages[].id` | string | ISO-639 код языка |
| `languages[].name` | string | Локализованное название |
| `languages[].level` | object | Уровень владения |
| `languages[].level.id` | string (enum: `a1`-`c2`, `l1`) | ID уровня |
| `languages[].level.name` | string | Локализованное название |
| `professional_roles` | array of objects | Профессиональные роли |
| `professional_roles[].id` | string | ID роли в справочнике HH |
| `professional_roles[].name` | string | Локализованное название |

### Наблюдения тестировщика

- В `salary.from` и `salary.to` явно используется тип `integer | null` — нельзя предполагать, что оба поля заполнены; в тестах учитывать все 4 комбинации.
- Все ID — строки, не числа. Это намеренно: HH допускает буквенно-цифровые идентификаторы, и сравнивать через `==` после JSON-парсинга нужно строго со строкой.
- Несколько полей используют **enum-значения** (`schedule.id`, `experience.id`, `employment.id`, `salary.currency`, `languages[].level.id`). Это хороший повод для теста: попробовать отправить «несуществующее» значение в фильтре и убедиться, что API вернёт 400 с описательной ошибкой.
- Дата приходит как строка ISO 8601 с TZ — нужно проверять формат и согласованность TZ между `published_at` и `created_at`.
- `null` отличается от отсутствия ключа. Тестировщику важно валидировать схему, а не просто «есть/нет значение».

---

## 5. Сводка

| Пункт | Сделано |
|-------|---------|
| Теория: методы, JSON vs XML/YAML, JSON Schema, серилизация | ✓ |
| 2 публичных REST API | ✓ (HH.ru + JSONPlaceholder) |
| Сравнительная таблица (4 критерия) | ✓ + дополнительные нюансы |
| Пример JSON + список ключей и типов | ✓ (43 ключа) |
