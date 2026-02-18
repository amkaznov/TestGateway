# Stage 1: Build stage
# Используем официальный образ Gradle, там уже всё настроено
FROM gradle:8-jdk17 AS builder

WORKDIR /app

# Копируем всё содержимое проекта (build.gradle, src и т.д.)
# Gradle образ сам разберется, как собрать проект без внешнего wrapper
COPY --chown=gradle:gradle . .

# Собираем jar (используем установленный в системе gradle вместо ./gradlew)
RUN gradle clean bootJar -x test

# Stage 2: Runtime stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Copy jar from builder stage
COPY --from=builder /app/build/libs/app.jar app.jar

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
