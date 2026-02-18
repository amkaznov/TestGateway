# API Gateway - Spring Cloud Gateway

Проект Spring Cloud Gateway на Java 17 с Gradle (Groovy DSL).

## Технический стек

- Java 17
- Spring Boot 3.3.0
- Spring Cloud Gateway 2023.0.0
- Gradle (Groovy DSL)

## Структура проекта

```
.
├── build.gradle                    # Gradle конфигурация с зависимостями
├── settings.gradle                 # Настройки Gradle
├── gradle.properties               # Свойства Gradle
├── Dockerfile                      # Многоэтапный Dockerfile
├── .gitignore                      # Git ignore правила
└── src/
    ├── main/
    │   ├── java/com/example/gateway/
    │   │   └── GatewayApplication.java   # Главный класс приложения
    │   └── resources/
    │       └── application.yml           # Конфигурация маршрутов
    └── test/
```

## Маршруты

### `/service1/**` → `http://api-service-1:8080`
- Все запросы к `/service1/**` перенаправляются на `api-service-1:8080`
- Префикс `/service1` обрезается
- **Пример:** `gateway:8080/service1/api/hello` → `api-service-1:8080/api/hello`

### `/mock/**` → `http://wiremock:8080`
- Все запросы к `/mock/**` перенаправляются на `wiremock:8080`
- Префикс `/mock` обрезается
- **Пример:** `gateway:8080/mock/users` → `wiremock:8080/users`

## Локальная сборка и запуск

### Требования
- Java 17
- Gradle (встроен через gradlew)

### Сборка
```bash
./gradlew clean build
```

### Запуск
```bash
./gradlew bootRun
```

Приложение будет доступно на `http://localhost:8080`

## Docker сборка

### Построить образ
```bash
docker build -t api-gateway:latest .
```

### Запустить контейнер
```bash
docker run -p 8080:8080 \
  --name api-gateway \
  --network gateway-network \
  api-gateway:latest
```

### Docker Compose пример

```yaml
version: '3.8'

services:
  gateway:
    build: .
    container_name: api-gateway
    ports:
      - "8080:8080"
    networks:
      - gateway-network
    environment:
      - SPRING_PROFILES_ACTIVE=prod

  api-service-1:
    image: mock-service:latest
    container_name: api-service-1
    ports:
      - "8081:8080"
    networks:
      - gateway-network

  wiremock:
    image: wiremock/wiremock:latest
    container_name: wiremock
    ports:
      - "8082:8080"
    networks:
      - gateway-network

networks:
  gateway-network:
    driver: bridge
```

## Конфигурация

Основная конфигурация находится в `src/main/resources/application.yml`:

**Фильтры:**
- `StripPrefix=1` - обрезает первый сегмент пути
- `retry()` - автоматический повтор при ошибках (для service1)

**Глобальные настройки:**
- Максимальный размер запроса: 5MB
- Compression: включен для ответов > 1KB

## Health Check

```bash
curl http://localhost:8080/actuator/health
```

## Разработка

### Логирование

Логирование настроено на DEBUG уровень для Spring Cloud Gateway:

```yaml
logging:
  level:
    org.springframework.cloud.gateway: DEBUG
```

### ActuatorЭндпоинты

- `/actuator/health` - статус приложения
- `/actuator/gateway/routes` - список всех маршрутов
- `/actuator/info` - информация о приложении

## Особенности

✅ Java 17 на Alpine Linux (минимальный образ)
✅ Многоэтапная сборка Docker
✅ Non-root пользователь в контейнере
✅ Health checks встроены
✅ Retry логика для критических сервисов
✅ Full request/response logging для отладки
✅ Graceful shutdown

## Лицензия

MIT
