//
//  ContentView.swift
//  speakbuddy_ios_exercise
//
//  Created by takemoto on 2026/11/06.
//

import SwiftUI
import Charts

struct MonthlyScores: Equatable, Identifiable {
    let id = UUID()
    let period: String
    let score: Double
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
}

let data: [MonthlyScores] = [
    MonthlyScores(period: "現在", score: 50),
    MonthlyScores(period: "3ヶ月", score: 80),
    MonthlyScores(period: "1年", score: 180),
    MonthlyScores(period: "2年", score: 250),
]

struct ContentView: View {
    @State private var animatedValues: [UUID: Double] = [:]

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
                ViewThatFits {
                    if geometry.size.width >= 600 {
                        ScreenContent(animatedValues: $animatedValues, style: .large, geometry: geometry)
                    }

                    ScreenContent(animatedValues: $animatedValues, style: .medium, geometry: geometry)

                    ScreenContent(animatedValues: $animatedValues, style: .small, geometry: geometry)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateBars(animatedValues: $animatedValues)
        }
    }
}

struct ScreenContent: View {
    @Binding var animatedValues: [UUID: Double]
    let style: ScreenStyle
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: style.spacing) {
            Button(action: {
                print("閉じる")
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14 * style.scale, weight: .heavy))
                    .frame(width: 38 * style.scale, height: 38 * style.scale)
                    .background(.white, in: Circle())
                    .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 0)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 8 * style.scale)

            Text("Hello\nSpeakBUDDY")
                .font(.system(size: 36 * style.scale, weight: .bold))
                .foregroundStyle(.text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 12 * style.scale)

            Spacer()

            ScoreChartView(
                data: data,
                animatedValues: animatedValues,
                availableWidth: max(0, min(geometry.size.width - 32, 400 * style.scale)),
                scale: style.scale
            )
            .layoutPriority(-1)

            Spacer()

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

            Spacer()

            Button(action: {
                animatedValues = [:]
                animateBars(animatedValues: $animatedValues)
            }) {
                Text("プランに登録する")
                    .font(.system(size: 18 * style.scale, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 58 * style.scale)
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
        .frame(width: max(0, min(geometry.size.width - 32, 400 * style.scale)))
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ScoreChartView: View {
    let data: [MonthlyScores]
    let animatedValues: [UUID: Double]
    let availableWidth: CGFloat
    let scale: CGFloat

    private let baseChartWidth: CGFloat = 290
    private let heightToWidthRatio: CGFloat = 300.0 / 270.0
    private let chartPadding: CGFloat = 12
    private let additionalTopPadding: CGFloat = 20
    private let chartTopAdjustment: CGFloat = 10

    var body: some View {
        let horizontalPadding = chartPadding * 2 * scale
        let verticalPadding = (chartPadding * 2 + additionalTopPadding) * scale + chartTopAdjustment
        let chartWidth = max(0, min(baseChartWidth * scale, availableWidth - horizontalPadding))
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
                .offset(x: -16 * scale, y: -8 * scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: preferredHeight)
    }
}

func animateBars(animatedValues: Binding<[UUID: Double]>) {
    for (index, item) in data.enumerated() {
        let delay = Double(index) * 0.10

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + delay) {
            withAnimation(.spring(response: 0.8, dampingFraction: 1.0)) {
                animatedValues.wrappedValue[item.id] = item.score
            }
        }
    }
}

#Preview {
    ContentView()
}
