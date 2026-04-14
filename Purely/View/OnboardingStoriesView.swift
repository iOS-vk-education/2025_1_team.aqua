//
//  OnboardingStoriesView.swift
//  Purely
//

import SwiftUI

struct OnboardingStoriesView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0
    @State private var segmentProgress: CGFloat = 0
    @State private var storyTimer: Timer?

    private let segmentDuration: TimeInterval = 5

    private var pages: [OnboardingStoryPage] {
        [
            OnboardingStoryPage(
                systemImage: "sparkles",
                title: "Добро пожаловать в Purely",
                subtitle: "Приложение помогает разбираться в составе косметики: переводим упаковку в понятный разбор ингредиентов и общую оценку."
            ),
            OnboardingStoryPage(
                systemImage: "clock.arrow.circlepath",
                title: "История сканирований",
                subtitle: "На вкладке «История» хранятся все товары с рейтингом. Свайпом влево можно удалить запись. Нажмите на карточку, чтобы открыть подробности."
            ),
            OnboardingStoryPage(
                systemImage: "camera.viewfinder",
                title: "Как сканировать",
                subtitle: "На вкладке «Сканировать» наведите камеру на текст состава на упаковке и нажмите «Сделать снимок». Текст отправится на анализ — дождитесь экрана с результатом."
            ),
            OnboardingStoryPage(
                systemImage: "list.clipboard",
                title: "Результат и детали",
                subtitle: "Вы увидите рейтинг, основные компоненты с уровнем риска и полный состав. Состав можно скопировать или поделиться целым отчётом."
            ),
        ]
    }

    var body: some View {
        ZStack {
            AppScreenBackground()

            VStack(spacing: 0) {
                storyProgressHeader
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .safeAreaPadding(.top, 4)

                HStack {
                    Spacer()
                    Button("Пропустить") {
                        stopTimer()
                        onComplete()
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.95))
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        StorySlideView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay {
                    storyTapZones
                }

                if currentPage == pages.count - 1 {
                    Button {
                        stopTimer()
                        onComplete()
                    } label: {
                        Text("Начать пользоваться")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial)
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                } else {
                    Color.clear.frame(height: 28)
                }
            }
        }
        .onAppear {
            startStoryTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: currentPage) { _, _ in
            startStoryTimer()
        }
    }

    private var storyProgressHeader: some View {
        HStack(spacing: 4) {
            ForEach(0..<pages.count, id: \.self) { index in
                StoryProgressSegment(
                    isPast: index < currentPage,
                    progress: segmentProgress(for: index)
                )
            }
        }
        .frame(height: 3)
    }

    private func segmentProgress(for index: Int) -> CGFloat {
        if index < currentPage { return 1 }
        if index > currentPage { return 0 }
        return segmentProgress
    }

    private var storyTapZones: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: geo.size.width * 0.35)
                    .onTapGesture {
                        goToPrevious()
                    }
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        goToNext()
                    }
            }
        }
        .allowsHitTesting(true)
    }

    private func goToPrevious() {
        stopTimer()
        if currentPage > 0 {
            currentPage -= 1
        } else {
            startStoryTimer()
        }
    }

    private func goToNext() {
        stopTimer()
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            onComplete()
        }
    }

    private func startStoryTimer() {
        stopTimer()
        segmentProgress = 0
        let start = Date()
        storyTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { t in
            let elapsed = Date().timeIntervalSince(start)
            let p = min(1, CGFloat(elapsed / segmentDuration))
            segmentProgress = p
            if p >= 1 {
                t.invalidate()
                storyTimer = nil
                if currentPage < pages.count - 1 {
                    currentPage += 1
                } else {
                    onComplete()
                }
            }
        }
        RunLoop.main.add(storyTimer!, forMode: .common)
    }

    private func stopTimer() {
        storyTimer?.invalidate()
        storyTimer = nil
    }
}

private struct OnboardingStoryPage {
    let systemImage: String
    let title: String
    let subtitle: String
}

private struct StoryProgressSegment: View {
    var isPast: Bool
    var progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.28))
                Capsule()
                    .fill(Color.white)
                    .frame(width: max(0, geo.size.width * (isPast ? 1 : progress)))
            }
        }
        .frame(maxHeight: 3)
    }
}

private struct StorySlideView: View {
    let page: OnboardingStoryPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)

            Image(systemName: page.systemImage)
                .font(.system(size: 64, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text(page.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 8)
            }

            Spacer()
        }
        .padding(.horizontal, 28)
    }
}

#Preview {
    OnboardingStoriesView(onComplete: {})
}
