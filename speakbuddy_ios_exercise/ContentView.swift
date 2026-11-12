//
//  ContentView.swift
//  speakbuddy_ios_exercise
//
//  Created by takemoto on 2026/11/06.
//

import SwiftUI
import Charts

struct MonthlyScores: Identifiable {
    let id = UUID()
    let period: String
    let score: Double
}

struct ContentView: View {
    private enum LayoutSize {
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
            case .large: return 1.1
            }
        }

        var spacing: CGFloat {
            switch self {
            case .small: return 4
            case .medium, .large: return 8 * scale
            }
        }
    }

    @State private var animatedValues: [UUID: Double] = [:]
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
                    .init(color: .background, location: 0.2),
                    .init(color: .white, location: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                let layoutSize = LayoutSize(availableWidth: geometry.size.width)
                let scale = layoutSize.scale
                let horizontalPadding: CGFloat = 16
                let contentWidth = max(0, min(geometry.size.width - horizontalPadding * 2, 400 * scale))

                VStack(spacing: layoutSize.spacing) {
                    Button(action: {
                        print("閉じる")
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14 * scale, weight: .heavy))
                            .frame(width: 38 * scale, height: 38 * scale)
                            .background(.white, in: Circle())
                            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 0)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 8 * scale)

                    Text("Hello\nSpeakBUDDY")
                        .font(.system(size: 36 * scale, weight: .bold))
                        .foregroundStyle(.text)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    ScoreChartView(
                        data: data,
                        animatedValues: animatedValues,
                        availableWidth: contentWidth,
                        scale: scale
                    )
                    .layoutPriority(-1)

                    Spacer(minLength: 0)

                    VStack(spacing: 4 * scale) {
                        Text("スピークバディで")
                            .font(.system(size: 22 * scale, weight: .semibold))
                            .foregroundStyle(.text)

                        Text("レベルアップ")
                            .font(.system(size: 32 * scale, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.startTextGradient, .endTextGradient],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    Button(action: {
                        replayID += 1
                    }) {
                        Text("プランに登録する")
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 58 * scale)
                            .background(
                                Capsule().fill(.base)
                            )
                            .overlay {
                                Capsule().strokeBorder(.white, lineWidth: 1)
                            }
                    }
                    .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 0)

                    Spacer(minLength: 0)
                }
                .frame(width: contentWidth)
                .padding(.horizontal, horizontalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task(id: replayID) {
                    await animateBars()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

private struct ScoreChartView: View {
    let data: [MonthlyScores]
    let animatedValues: [UUID: Double]
    let availableWidth: CGFloat
    let scale: CGFloat

    private let baseChartWidth: CGFloat = 290
    private let heightToWidthRatio: CGFloat = 300.0 / 270.0
    private let chartPadding: CGFloat = 20
    private let additionalTopPadding: CGFloat = 20

    var body: some View {
        let horizontalPadding = chartPadding * 2 * scale
        let verticalPadding = (chartPadding * 2 + additionalTopPadding) * scale
        let chartWidth = max(0, min(baseChartWidth * scale, availableWidth - horizontalPadding))
        let preferredHeight = chartWidth * heightToWidthRatio + verticalPadding

        GeometryReader { geometry in
            let fit = preferredHeight > 0
                ? min(1, max(0, geometry.size.height) / preferredHeight)
                : 0
            let chartScale = scale * fit
            let fittedChartWidth = chartWidth * fit

            ZStack(alignment: .topLeading) {
                Chart(data) { item in
                    BarMark(
                        x: .value("期間", item.period),
                        y: .value("スコア", animatedValues[item.id] ?? 0),
                        width: .fixed(48 * chartScale)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.startGraphGradient, .endGraphGradient],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(width: fittedChartWidth, height: fittedChartWidth * heightToWidthRatio)
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel()
                            .font(.system(size: 14 * chartScale, weight: .bold))
                            .foregroundStyle(.text)
                    }
                }
                .chartYAxis(.hidden)
                .chartYScale(domain: 0...250)
                .padding(chartPadding * chartScale)
                .padding(.top, additionalTopPadding * chartScale)

                Image(.protty)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 185 * chartScale)
                    .padding(.top, 8 * chartScale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxHeight: preferredHeight)
    }
}

#Preview {
    ContentView()
}
