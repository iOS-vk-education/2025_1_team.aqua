# Сборка
FROM swift:5.9-jammy AS build
WORKDIR /app

COPY Package.swift ./
COPY LLMAPI ./LLMAPI

RUN swift build -c release

# Запуск
FROM swift:5.9-jammy-slim
WORKDIR /app

RUN useradd -m appuser
USER appuser

COPY --from=build /app/.build/release/Run ./

EXPOSE 8080

ENTRYPOINT ["./Run"]
