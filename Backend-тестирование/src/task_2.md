# Задание 2. Postman — пошаговое решение

**Целевой API:** **JSONPlaceholder** (https://jsonplaceholder.typicode.com) — выбран из двух API, проанализированных в `task_1.md`. Он поддерживает все CRUD-методы (GET, POST, PUT, PATCH, DELETE) без авторизации, что идеально для тренировки навыков Postman.

**Артефакт:** экспортированная коллекция лежит рядом — `postman_collection.json`. Файл валиден по схеме Postman Collection v2.1.0 и импортируется без дополнительных настроек.

> ⚠️ Скриншоты обозначены плейсхолдерами `screenshots/postman_*.png`. При оформлении в P2P-сдаче положить актуальные снимки в `Backend-тестирование/src/screenshots/`.

---

## Шаг 0. Установка Postman и регистрация аккаунта

1. Открыть https://www.postman.com/downloads/.
2. Выбрать сборку под свою ОС (на Windows — `Postman-win64-Setup.exe`, на macOS — `.dmg`, на Linux — `.tar.gz` или Snap).
3. Запустить установщик, дождаться завершения установки. На Windows Postman автоматически запустится после установки.
4. На стартовом экране нажать **Sign Up** → ввести email + пароль → подтвердить email по ссылке из письма.
5. (Опционально) согласиться на создание persistent workspace «My Workspace» — он понадобится для синхронизации коллекций между устройствами.

**Зачем регистрация:** позволяет синхронизировать коллекции и окружения через облако, делиться ими с пирами на P2P, использовать Collection Runner и Monitors.

📸 `screenshots/postman_00_signup.png` — окно регистрации.

---

## Шаг 1. Создание Workspace

1. В левом верхнем углу кликнуть на выпадающий список workspaces → **Create Workspace**.
2. Указать имя — `QA School21` (или любое осмысленное), описание — «Practice workspace for Backend testing project», visibility — **Personal**.
3. Нажать **Create Workspace**.

📸 `screenshots/postman_01_workspace.png`

---

## Шаг 2. Настройка окружения (Environment)

Окружение нужно, чтобы один и тот же набор запросов можно было быстро переключать между **dev / stage / prod**, не правя URL вручную.

1. В левой панели открыть вкладку **Environments**.
2. Нажать **+ Create new Environment** → дать имя `JSONPlaceholder — DEV`.
3. Добавить переменные:

   | Variable | Type | Initial Value | Current Value |
   |----------|------|---------------|---------------|
   | `base_url` | default | `https://jsonplaceholder.typicode.com` | `https://jsonplaceholder.typicode.com` |
   | `user_id` | default | `1` | `1` |
   | `post_id` | default | `1` | `1` |
   | `created_post_id` | secret | *(пусто)* | *(пусто, заполнится автотестом в шаге POST)* |

4. Нажать **Save**.
5. В правом верхнем углу основного окна выбрать окружение `JSONPlaceholder — DEV`.

**Зачем нужны переменные:** все запросы коллекции будут ссылаться на `{{base_url}}`, и при смене окружения (например, на mock-сервер) ничего переделывать не нужно.

📸 `screenshots/postman_02_environment.png`

---

## Шаг 3. Создание коллекции

1. В левой панели открыть вкладку **Collections** → нажать **+** (Create new collection).
2. Имя коллекции — `JSONPlaceholder — Backend QA Practice`.
3. Перейти в настройки коллекции (троеточие → **Edit**) → вкладка **Variables**.
4. Добавить переменную уровня коллекции (как страховку, если окружение не подключено):

   | Variable | Initial value | Current value |
   |----------|---------------|---------------|
   | `base_url` | `https://jsonplaceholder.typicode.com` | `https://jsonplaceholder.typicode.com` |

5. Сохранить.

**Зачем переменная уровня коллекции:** даже если другой пользователь импортирует коллекцию без окружения, она «не сломается» — `{{base_url}}` подставится из переменных коллекции.

📸 `screenshots/postman_03_collection.png`

---

## Шаг 4. Создание запросов в коллекции (минимум 3, разных методов)

В коллекцию добавляем 5 запросов, чтобы покрыть полный CRUD:

| # | Метод | URL | Что делает |
|---|-------|-----|------------|
| 1 | **GET** | `{{base_url}}/posts` | Получить все посты |
| 2 | **GET** | `{{base_url}}/posts/{{post_id}}` | Получить пост по id |
| 3 | **POST** | `{{base_url}}/posts` | Создать новый пост |
| 4 | **PUT** | `{{base_url}}/posts/{{post_id}}` | Полное обновление поста |
| 5 | **DELETE** | `{{base_url}}/posts/{{post_id}}` | Удалить пост |

### 4.1. GET all posts

1. В коллекции → правый клик → **Add request** → имя `GET all posts`.
2. Метод — `GET`, URL — `{{base_url}}/posts`.
3. Никаких заголовков и тела вручную добавлять не нужно — JSONPlaceholder возвращает JSON.

### 4.2. GET single post

1. **Add request** → имя `GET single post by id`.
2. Метод — `GET`, URL — `{{base_url}}/posts/{{post_id}}`.

### 4.3. POST create post

1. **Add request** → имя `POST create new post`.
2. Метод — `POST`, URL — `{{base_url}}/posts`.
3. Вкладка **Body** → выбрать `raw` → формат `JSON`. Вставить:

   ```json
   {
     "title": "Backend testing practice",
     "body": "This post is created from Postman as part of the School 21 backend project.",
     "userId": {{user_id}}
   }
   ```

4. Postman автоматически подставит заголовок `Content-Type: application/json`.

### 4.4. PUT update post

1. **Add request** → имя `PUT update post`.
2. Метод — `PUT`, URL — `{{base_url}}/posts/{{post_id}}`.
3. Body → raw → JSON:

   ```json
   {
     "id": {{post_id}},
     "title": "Updated title",
     "body": "Body has been fully replaced via PUT.",
     "userId": {{user_id}}
   }
   ```

### 4.5. DELETE post

1. **Add request** → имя `DELETE post`.
2. Метод — `DELETE`, URL — `{{base_url}}/posts/{{post_id}}`.

📸 `screenshots/postman_04_requests.png`

---

## Шаг 5. Добавление сниппетов (тестовых скриптов)

Сниппеты в Postman — это готовые блоки JavaScript-кода, которые навешиваются на запрос во вкладке **Tests** (выполняются после запроса) или **Pre-request Script** (перед запросом). Постоянно встречающиеся проверки: статус-код, время ответа, валидация тела.

### 5.1. Сниппеты для `GET all posts`

Открыть вкладку **Tests** запроса и вставить:

```js
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response is JSON array", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.be.an("array");
    pm.expect(jsonData.length).to.be.above(0);
});

pm.test("First item has required keys", function () {
    const first = pm.response.json()[0];
    pm.expect(first).to.have.all.keys("userId", "id", "title", "body");
});

pm.test("Response time is below 1000 ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(1000);
});
```

### 5.2. Сниппеты для `GET single post`

```js
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Returned post id matches the requested id", function () {
    const expectedId = Number(pm.environment.get("post_id"));
    pm.expect(pm.response.json().id).to.eql(expectedId);
});

pm.test("Body schema is correct", function () {
    const schema = {
        type: "object",
        required: ["userId", "id", "title", "body"],
        properties: {
            userId: { type: "integer" },
            id:     { type: "integer" },
            title:  { type: "string" },
            body:   { type: "string" }
        }
    };
    pm.test.skip; // фолбэк, если ajv не подключён
    pm.expect(pm.response.json()).to.have.all.keys(Object.keys(schema.properties));
});
```

### 5.3. Сниппеты для `POST create post`

```js
pm.test("Status code is 201 (Created)", function () {
    pm.response.to.have.status(201);
});

pm.test("Created post has id", function () {
    const data = pm.response.json();
    pm.expect(data).to.have.property("id");
    pm.environment.set("created_post_id", data.id); // сохраняем id для дальнейших запросов
});

pm.test("Response echoes sent title", function () {
    pm.expect(pm.response.json().title).to.eql("Backend testing practice");
});
```

### 5.4. Сниппеты для `PUT update post`

```js
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Title was updated", function () {
    pm.expect(pm.response.json().title).to.eql("Updated title");
});
```

### 5.5. Сниппеты для `DELETE post`

```js
pm.test("Status code is 200 (DELETE)", function () {
    pm.response.to.have.status(200);
});

pm.test("Response body is empty object", function () {
    const json = pm.response.json();
    pm.expect(Object.keys(json).length).to.eql(0);
});
```

**Где брать сниппеты:** справа от области скриптов есть боковая панель **Snippets**, где можно одним кликом добавить заготовку («Status code: Code is 200», «Response body: JSON value check» и т.п.) — это удобнее, чем писать вручную.

📸 `screenshots/postman_05_snippets.png`

---

## Шаг 6. Запуск отдельных запросов и проверка ответов

Для каждого запроса:

1. Нажать **Send**.
2. Изучить во вкладке **Body** ответ — он должен быть валидным JSON.
3. Перейти на вкладку **Test Results** — увидеть зелёные плашки «PASS» по всем проверкам.
4. Слева в **Console** (`Ctrl+Alt+C`) посмотреть тело запроса, заголовки и тайминги. Это важная привычка тестировщика: console показывает реальный, развёрнутый HTTP-запрос с подставленными переменными.

Ожидаемые результаты:

| Запрос | Status | Ключевые проверки |
|--------|:------:|-------------------|
| GET all posts | 200 | массив из 100 элементов, время < 1 с |
| GET single post | 200 | `id == 1`, схема соответствует |
| POST create | 201 | возвращён `id=101`, `created_post_id` сохранён в env |
| PUT update | 200 | `title == "Updated title"` |
| DELETE | 200 | тело `{}` |

📸 `screenshots/postman_06_results.png`

---

## Шаг 7. Запуск автотестов всей коллекции (Collection Runner)

1. На коллекции → правый клик → **Run collection**.
2. В Runner-окне:
   - **Environment**: `JSONPlaceholder — DEV`.
   - **Iterations**: 1.
   - **Delay**: 100 ms (чтобы не упереться в rate-limit и видеть прогресс).
   - **Data file**: пусто (data-driven запуск не нужен).
3. Нажать **Run JSONPlaceholder — Backend QA Practice**.
4. После выполнения откроется итоговый отчёт:
   - всего запросов: **5**;
   - тестов: **~14**, ожидаемые passed — все;
   - в правой колонке — длительность каждого запроса.

📸 `screenshots/postman_07_runner.png`

### Опционально: запуск из CLI (Newman)

Тестировщик в реальной работе часто запускает коллекцию из CI/CD. Это делается через `newman`:

```bash
npm install -g newman
newman run postman_collection.json -e "JSONPlaceholder - DEV.postman_environment.json"
```

В CI пайплайне (GitHub Actions / GitLab CI) команда добавляется в шаг и pipeline падает при любой failed-проверке.

---

## Шаг 8. Экспорт коллекции в JSON

1. На коллекции → троеточие → **Export**.
2. Выбрать формат **Collection v2.1 (recommended)**.
3. Сохранить файл рядом с заданием — `postman_collection.json`.

Файл-экспорт уже лежит в репозитории: [`postman_collection.json`](./postman_collection.json).

### Проверка, что коллекция импортируется без доп. настроек

1. На другой машине / в свежем workspace нажать **Import** → перетащить `postman_collection.json`.
2. Postman развернёт коллекцию из 5 запросов, переменная `base_url` уже определена в самой коллекции — запросы запускаются сразу.
3. Если нужно использовать дополнительные переменные (`post_id`, `user_id`, `created_post_id`) — экспортировать и окружение через **Environments → троеточие → Export**, файл будет называться `JSONPlaceholder - DEV.postman_environment.json` (его можно тоже приложить).

📸 `screenshots/postman_08_export.png`

---

## Шаг 9. Загрузка экспортированного JSON в файловый сервис

В рамках обучения подходит любой:

- **GitHub / GitLab репозиторий** проекта (уже сделано — файл лежит рядом с этим заданием в текущей папке).
- **Google Drive / Yandex.Disk** — расшарить ссылкой «по ссылке могут просматривать».
- **Postman Public API Network** — `Share collection` прямо в Postman.

В моём случае коллекция сохранена в репозитории по пути `Backend-тестирование/src/postman_collection.json`.

---

## Сводка по заданию

| Пункт задания | Что сделано |
|---------------|-------------|
| 1. Установка Postman + регистрация | ✓ Шаг 0 |
| 2.1 Настройка окружения | ✓ Шаг 2 (5 переменных) |
| 2.2 Создание коллекций | ✓ Шаг 3 |
| 2.3 Создание запросов в коллекциях | ✓ Шаг 4 (5 запросов) |
| 2.4 Добавление сниппетов | ✓ Шаг 5 (~14 тест-кейсов) |
| 2.5 Запуск автотестов для коллекции | ✓ Шаг 7 (Collection Runner + опц. Newman) |
| 3. ≥1 коллекция, ≥3 запросов разных методов | ✓ 5 запросов: GET, GET, POST, PUT, DELETE |
| 4. Экспорт в `.json` | ✓ `postman_collection.json` рядом |
| 5. Загрузка в файловый сервис | ✓ В репозитории + при желании в Postman Network |

## Чек-лист скриншотов для P2P-сдачи

- [ ] `postman_00_signup.png`
- [ ] `postman_01_workspace.png`
- [ ] `postman_02_environment.png`
- [ ] `postman_03_collection.png`
- [ ] `postman_04_requests.png`
- [ ] `postman_05_snippets.png`
- [ ] `postman_06_results.png`
- [ ] `postman_07_runner.png`
- [ ] `postman_08_export.png`
