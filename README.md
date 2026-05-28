# Purely

Purely — iOS-приложение для анализа состава косметики. Пользователь сканирует INCI-состав с камеры или выбирает фото из галереи, приложение распознаёт текст, отправляет его на backend и показывает оценку продукта, риск отдельных компонентов и полный состав.

Проект команды `team.aqua` по курсу "Мобильный разработчик на iOS" от VK.

## Возможности

- Сканирование состава через камеру.
- Импорт изображения из галереи.
- OCR-распознавание текста с помощью Vision.
- Анализ состава через backend `LLMAPI`.
- История проверенных продуктов.
- Детальная карточка продукта с рейтингом, компонентами и уровнями риска.
- Генерация красивой share-картинки с результатом анализа.

## Структура проекта

```
├── Purely/                         # iOS-приложение
│   ├── AppDelegate.swift           # Точка входа UIKit
│   ├── SceneDelegate.swift         # Управление сценой
│   ├── CameraService.swift         # Камера, OCR (Vision) и отправка текста на backend
│   ├── GradientBackgroundView.swift
│   ├── HistoryViewController.swift
│   ├── ScanViewController.swift
│   ├── ProductDetailViewController.swift
│   ├── Model/
│   │   ├── ProductModel.swift      # Модели Product, Ingredient, RiskLevel, ProductStore
│   │   └── PersistenceController.swift  # CoreData: хранение истории сканирований
│   └── View/
│       ├── AuthView.swift          # Экран авторизации
│       ├── OnboardingStoriesView.swift  # Онбординг
│       ├── MainTabBarController.swift   # Таб-бар (SwiftUI + UIKit)
│       ├── ScanView.swift          # Экран сканирования
│       ├── HistoryView.swift       # История проверок
│       ├── HistoryItemView.swift   # Ячейка истории
│       ├── ItemView.swift          # GlassButton — карточка продукта в списке
│       ├── ProductDetailView.swift # Детальная карточка продукта
│       ├── ProductShareCard.swift  # Генерация share-картинки (ImageRenderer)
│       └── View+GlassEffect.swift  # Общий фон и glass-стиль
├── LLMAPI/                         # Backend на Vapor
│   ├── entrypoint.swift            # Точка входа сервера
│   ├── configure.swift             # Настройка Vapor
│   └── routes.swift                # POST /analyze + Jaccard-кэш
└── Package.swift                   # Swift Package (зависимости backend)
```

## Запуск iOS-приложения

1. Откройте `Purely.xcodeproj` в Xcode.
2. Выберите схему `Purely`.
3. Запустите приложение на реальном устройстве или симуляторе с доступной iOS runtime.
4. Для сканирования на устройстве потребуется доступ к камере и фотографиям.


## Технологии

**iOS**
- Swift, SwiftUI, UIKit
- AVFoundation — работа с камерой
- Vision — OCR-распознавание текста
- CoreData — персистентное хранение истории
- Combine — реактивное состояние (`ObservableObject`)
- URLSession — сетевые запросы
- ImageRenderer — генерация share-картинки

**Backend**
- Swift, Vapor
- BotHub API → Gemini 2.5 Flash (LLM-анализ состава)
- In-memory Jaccard similarity кэш

## Основной пользовательский сценарий

1. Пользователь открывает экран сканирования.
2. Наводит камеру на состав или выбирает фото из галереи.
3. Приложение распознаёт текст и отправляет его на backend.
4. Backend возвращает структурированный результат.
5. Приложение показывает карточку продукта и сохраняет её в историю.
