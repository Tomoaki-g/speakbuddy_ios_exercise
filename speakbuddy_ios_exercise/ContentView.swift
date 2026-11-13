//
//  ContentView.swift
//  speakbuddy_ios_exercise
//
//  Created by takemoto on 2026/11/06.
//

import SwiftUI
import Charts

struct MonthlyScores: Identifiable {
    let period: String
    let score: Double

    var id: String { period }
}

enum ScreenStyle {
    case small
    case medium
    case large

    init(availableWidth: CGFloat) {
        switch availableWidth {
        case ..<390:
            self = .small
        case ..<440:
            self = .medium
        default:
            self = .large
        }
    }

    var scale: CGFloat {
        switch self {
        case .small: return 0.88
        case .medium: return 1
        case .large: return 1.4
        }
    }

    var spacing: CGFloat {
        switch self {
        case .small: return 4
        case .medium, .large: return 12 * scale
        }
    }

    var contentWidth: CGFloat {
        switch self {
        case .small: 280
        case .medium: 354
        case .large: 540
        }
    }
}

struct ContentView: View {
    @State private var animatedValues: [String: Double] = [:]
    @State private var replayID = 0

    private let data: [MonthlyScores] = [
        MonthlyScores(period: "現在", score: 50),
        MonthlyScores(period: "3ヶ月", score: 80),
        MonthlyScores(period: "1年", score: 180),
        MonthlyScores(period: "2年", score: 250),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: .background, location: 0),
                    .init(color: .background.opacity(0.6), location: 0.25),
                    .init(color: .background.opacity(0.25), location: 0.5),
                    .init(color: .background.opacity(0.05), location: 0.75),
                    .init(color: .white, location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(.white)
            .ignoresSafeArea()

            ViewThatFits(in: [.horizontal, .vertical]) {
                ForEach([ScreenStyle.large, .medium, .small], id: \.self) { style in
                    ScreenContent(data: data, animatedValues: animatedValues, style: style) {
                        replayID += 1
                    }
                }

                ScreenContent(data: data, animatedValues: animatedValues, style: .small) {
                    replayID += 1
                }
                .compactLayout

                ScrollView {
                    ScreenContent(data: data, animatedValues: animatedValues, style: .small) {
                        replayID += 1
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
        .task(id: replayID) {
            await animateBars()
        }
    }

    @MainActor
    private func animateBars() async {
        guard !Task.isCancelled else { return }

        // リセットをアニメーションさせない
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            animatedValues = [:]
        }

        do {
            for (index, item) in data.enumerated() {
                let delay: Duration = index == 0 ? .milliseconds(400) : .milliseconds(100)

                try await Task.sleep(for: delay)

                try Task.checkCancellation()

                withAnimation(.spring(response: 0.8, dampingFraction: 1.0)) {
                    animatedValues[item.id] = item.score
                }
            }
        } catch {
            return
        }
    }
}

struct ScreenContent: View {
    let data: [MonthlyScores]
    let animatedValues: [String: Double]
    let style: ScreenStyle
    let onRegister: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            mainContent

            registrationButton
                .frame(maxWidth: 688)
                .padding(.horizontal, style == .large ? 48 : 0)
        }
    }

    var compactLayout: some View {
        VStack(spacing: 0) {
            closeButton

            HStack(spacing: 24) {
                ScoreChartView(data: data, animatedValues: animatedValues, scale: 0.72)
                    .frame(width: 232)

                VStack(spacing: 12) {
                    title
                    message
                    registrationButton
                }
                .frame(width: style.contentWidth)
            }
        }
        .fixedSize(horizontal: true, vertical: true)
    }

    private var mainContent: some View {
        VStack(spacing: style.spacing) {
            closeButton

            title
                .padding(.bottom, 12 * style.scale)

            Spacer()

            ScoreChartView(
                data: data,
                animatedValues: animatedValues,
                scale: style.scale
            )
            .layoutPriority(-1)

            message
                .padding(.top, style.spacing)
                .padding(.bottom, 14 + style.spacing)
        }
        .frame(width: style.contentWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var closeButton: some View {
        Button(action: {
            print("閉じる")
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 14 * style.scale, weight: .heavy))
                .foregroundStyle(.text)
                .frame(width: 38 * style.scale, height: 38 * style.scale)
                .background(.white, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.top, 8 * style.scale)
    }

    private var title: some View {
        Text("Hello\nSpeakBUDDY")
            .font(.system(size: 36 * style.scale, weight: .bold))
            .foregroundStyle(.text)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var message: some View {
        VStack(spacing: 4 * style.scale) {
            Text("スピークバディで")
                .font(.system(size: 22 * style.scale, weight: .semibold))
                .foregroundStyle(.text)

            Text("レベルアップ")
                .font(.system(size: 32 * style.scale, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.startTextGradient, .endTextGradient],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var registrationButton: some View {
        Button(action: onRegister) {
            Text("プランに登録する")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Capsule().fill(.base))
                .overlay {
                    Capsule().strokeBorder(.white, lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

private struct ScoreChartView: View {
    let data: [MonthlyScores]
    let animatedValues: [String: Double]
    let scale: CGFloat

    private let baseChartWidth: CGFloat = 290
    private let heightToWidthRatio: CGFloat = 300.0 / 270.0
    private let chartPadding: CGFloat = 12
    private let additionalTopPadding: CGFloat = 20
    private let chartTopAdjustment: CGFloat = 10

    var body: some View {
        let verticalPadding = (chartPadding * 2 + additionalTopPadding) * scale + chartTopAdjustment
        let chartWidth = baseChartWidth * scale
        let preferredHeight = chartWidth * heightToWidthRatio + verticalPadding

        ZStack(alignment: .topLeading) {
            Chart(data) { item in
                BarMark(
                    x: .value("期間", item.period),
                    y: .value("スコア", animatedValues[item.id] ?? 0),
                    width: .fixed(48 * scale)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.startGraphGradient, .endGraphGradient],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(width: chartWidth, height: chartWidth * heightToWidthRatio)
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel()
                        .font(.system(size: 14 * scale, weight: .bold))
                        .foregroundStyle(.text)
                }
            }
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...250)
            .padding(chartPadding * scale)
            .padding(.top, additionalTopPadding * scale + chartTopAdjustment)

            Image(.protty)
                .resizable()
                .scaledToFit()
                .frame(width: 190 * scale)
                .offset(x: -16 * scale, y: -12 * scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: preferredHeight)
    }
}

#Preview {
    ContentView()
}
