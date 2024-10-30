# Документация для OdooRPC

## Содержание
1. [Введение](#введение)
2. [Установка](#установка)
3. [Начало работы](#начало-работы)
4. [OdooClient](#odooclient)
5. [Основные компоненты](#основные-компоненты)
   - [RPCClient](#rpcclient)
   - [AuthenticationService](#authenticationservice)
   - [UserDataService](#userdataservice)
   - [DatabaseService](#databaseservice)
   - [AttachmentService](#attachmentservice)
   - [ContactsService](#contactsservice)
   - [MessagesServer](#messagesserver)
   - [CetmixCommunicatorService](#cetmixcommunicatorservice)
   - [MailboxOperation](#mailboxoperation)
   - [MessageFetchRequest](#messagefetchrequest)
   - [ContactParameters](#contactparameters)
   - [ContactAction](#contactaction)
6. [Тестирование](#тестирование)
7. [CI/CD](#cicd)
8. [Примеры использования](#примеры-использования)
9. [Обработка ошибок](#обработка-ошибок)

## Введение
Библиотека OdooRPC предоставляет удобный интерфейс для взаимодействия с API Odoo через удалённые вызовы процедур (RPC). Библиотека предназначена для внутреннего использования и доступна только для команды разработчиков. Она облегчает выполнение операций, таких как аутентификация, получение и манипуляция данными различных моделей Odoo с безопасной типизацией.

## Установка
Чтобы установить библиотеку OdooRPC, вы можете использовать Swift Package Manager. Добавьте следующую строку в ваш `Package.swift`:
```swift
.package(url: "https://github.com/your-repo/OdooRPC.git", from: "1.0.0")
```

## Начало работы
Импортируйте библиотеку в свой проект Swift:
```swift
import OdooRPC
```

Создайте экземпляр `OdooClient` с URL сервера Odoo:
```swift
let odooClient = OdooClient(baseURL: URL(string: "https://your-odoo-server.com")!)
```

## OdooClient
Класс `OdooClient` является точкой входа в библиотеку и предоставляет доступ ко всем основным сервисам библиотеки. Он инициализирует клиент RPC и необходимые сервисы.

### Свойства
- `rpcClient`: Экземпляр `RPCClient`, используемый для выполнения запросов к серверу.
- `authService`: Сервис для аутентификации.
- `baseURL`: Базовый URL сервера Odoo.

### Инициализация
- `init(baseURL: URL)`: Инициализирует `OdooClient` с указанным базовым URL и настраивает необходимые сервисы.

### Ленивая инициализация сервисов
- `messagesService`: Сервис для работы с сообщениями.
- `userDataService`: Сервис для работы с данными пользователя.
- `odooService`: Общий сервис для выполнения различных операций Odoo.
- `authenticationServiceTotp`: Сервис для аутентификации с использованием TOTP.
- `databaseService`: Сервис для работы с базами данных.
- `databaseServiceCetmixCommunicator`: Сервис для работы с коммуникацией Cetmix.
- `moduleServiceOdoo`: Сервис для работы с модулями Odoo.
- `contactsService`: Сервис для работы с контактами.
- `attachmentService`: Сервис для работы с вложениями.

## Основные компоненты

### RPCClient
Класс `RPCClient` обрабатывает все RPC-запросы к серверу Odoo.

#### Методы
- `sendRPCRequest`: Отправляет универсальный RPC-запрос. Обрабатывает создание и отправку запроса, а также управление сессией.
- `sendAuthenticationRequest`: Специфично для запросов аутентификации.
- `executeNetworkRequest`: Выполняет сетевой запрос с использованием URLSession и обрабатывает ответ.
- `isSessionValid`: Проверяет, действительна ли текущая сессия.
- `refreshSession`: Обновляет сессию, если она недействительна.

### AuthenticationService
Класс `AuthenticationService` отвечает за аутентификацию пользователя, включая обработку TOTP (одноразового пароля на основе времени).

#### Методы
- `authenticate(credentials:completion:)`: Аутентификация пользователя с использованием имени пользователя и пароля.
- `authenticateTotp(_:database:completion:)`: Аутентификация пользователя с использованием TOTP.

### UserDataService
Этот сервис предоставляет методы для получения данных пользователя из базы данных Odoo.

#### Методы
- `fetchUserData(uid:completion:)`: Получает данные пользователя для данного идентификатора пользователя.

### DatabaseService
Этот сервис позволяет взаимодействовать с базой данных, в частности, выводит список доступных баз данных на сервере Odoo.

#### Методы
- `listDatabases(completion:)`: Выводит все базы данных.

### AttachmentService
Сервис `AttachmentService` управляет файлами вложений, связанными с записями Odoo.

#### Методы
- `fetchAttachment(request:userID:completion:)`: Получает данные вложения.
- `uploadAttachment(request:userID:completion:)`: Загружает новое вложение.

### ContactsService
Сервис `ContactsService` отвечает за загрузку и поиск контактов.

#### Методы
- `loadContacts(action:searchParameters:completion:)`: Загружает контакты по заданным параметрам.

### MessagesServer
Класс `MessagesServer` управляет сообщениями в Odoo, позволяя их получать, искать, удалять и архивировать.

#### Методы
- `fetchMessages(request:completion:)`: Получает сообщения.
- `searchMessages(request:completion:)`: Ищет сообщения по заданным параметрам.
- `deleteMessages(messageIDs:type:completion:)`: Удаляет сообщения.
- `archiveMessages(messageIDs:type:completion:)`: Архивирует сообщения.
- `markReadMessages(messageIDs:type:completion:)`: Помечает сообщения как прочитанные.
- `fetchExistingMessageIDs(localMessagesID:completion:)`: Получает существующие идентификаторы сообщений.

### CetmixCommunicatorService
Этот сервис взаимодействует с API для получения информации о базе данных и выполнения операций с ней.

#### Методы
- `fetchDatabase(login:password:completion:)`: Получает имя базы данных.

### MailboxOperation
Энум `MailboxOperation` представляет различные операции с почтовыми ящиками.

#### Методы
- `domain(for:)`: Возвращает домен для выбранной операции, который используется при запросах к серверу.

### MessageFetchRequest
Структура `MessageFetchRequest` представляет параметры запроса для получения сообщений.

#### Инициализатор
- `init(operation:messageId:limit:comparisonOperator:...)`: Инициализирует параметры запроса.

### ContactParameters
Структура `ContactParameters` представляет параметры для поиска контактов.

#### Инициализатор
- `init(uid:sessionId:searchName:searchEmail:...)`: Инициализирует параметры для поиска.

### ContactAction
Энум `ContactAction` представляет действия для загрузки контактов.

## Тестирование
Библиотека включает модульные тесты для проверки функциональности каждого компонента. Тесты написаны с использованием XCTest и расположены в каталоге `Tests`. Перед каждым коммитом рекомендуется запускать тесты, чтобы убедиться в стабильности кода.

## CI/CD
В проекте настроена система непрерывной интеграции (CI), которая автоматически запускает тесты и сборку при каждом изменении в репозитории. Это помогает поддерживать высокое качество кода и минимизировать количество ошибок. Также используется `SwiftLint` для проверки стиля кода.

## Примеры использования

### Получение данных пользователя
```swift
let odooClient = OdooClient(baseURL: URL(string: "https://your-odoo-server.com")!)
odooClient.userDataService.fetchUserData(uid: 1) { result in
    switch result {
    case .success(let userData):
        print("Данные пользователя: \(userData)")
    case .failure(let error):
        print("Ошибка: \(error)")
    }
}
```

### Аутентификация пользователя
```swift
let credentials = Credentials(username: "user", password: "password", database: "db_name")
odooClient.authService.authenticate(credentials: credentials) { result in
    switch result {
    case .success(let userData):
        print("Аутентифицированный пользователь: \(userData.name)")
    case .failure(let error):
        print("Ошибка аутентификации: \(error)")
    }
}
```

### Получение списка баз данных
```swift
odooClient.databaseService.listDatabases { result in
    switch result {
    case .success(let databases):
        print("Базы данных: \(databases)")
    case .failure(let error):
        print("Ошибка получения баз данных: \(error)")
    }
}
```

## Обработка ошибок
Библиотека использует тип `Result` Swift для обработки ошибок. Вы можете поймать ошибки в обработчиках завершения и обрабатывать их соответствующим образом.

