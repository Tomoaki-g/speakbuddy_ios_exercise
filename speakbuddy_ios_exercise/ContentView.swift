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
    var score: Double
}

struct ContentView: View {
    @State private var animatedValues: [UUID: Double] = [:]
    private var data: [MonthlyScores] = [
        MonthlyScores(period: "現在", score: 50),
        MonthlyScores(period: "3ヶ月", score: 80),
        MonthlyScores(period: "1年", score: 180),
        MonthlyScores(period: "2年", score: 250),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let chartWidth = min(geometry.size.width, 290)
            let chartHeight = chartWidth * (300 / 270)
            
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
                
                VStack {
                    Button(action: {
                        print("閉じる")
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .heavy))
                            .frame(width: 38, height: 38)
                            .background(.white, in: Circle())
                            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 0)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: -20, y: -6)
                    
                    Text("Hello\nSpeakBUDDY")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.text)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 54)
                    
                    ZStack(alignment: .topLeading) {
                        Chart(data) { item in
                            BarMark(
                                x: .value("期間", item.period),
                                y: .value("スコア", animatedValues[item.id] ?? 0),
                                width: .fixed(48)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.startGraphGradient, .endGraphGradient],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .frame(width: chartWidth, height: chartHeight)
                        .chartXAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.text)
                            }
                        }
                        .chartYAxis(.hidden)
                        .chartYScale(domain: 0...250)
                        .padding()
                        
                        Image(.protty)
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .offset(x: -10, y: -30)
                    }
                    .padding(.bottom, 12)
                    
                    VStack(spacing: 4) {
                        Text("スピークバディで")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.text)
                        
                        Text("レベルアップ")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.startTextGradient, .endTextGradient],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .frame(alignment: .center)
                    .padding(.bottom, 24)
                    
                    Button(action: {
                        animatedValues = [:]
                        animateBars()
                    }) {
                        Text("プランに登録する")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 350, height: 58)
                            .background(
                                Capsule().fill(.base)
                            )
                    }
                }
            }
        }
        .onAppear {
            animateBars()
        }
    }
    
    private func animateBars() {
        for (index, item) in data.enumerated() {
            let delay = Double(index) * 0.10
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + delay) {
                withAnimation(.spring(response: 0.8, dampingFraction: 1.0)) {
                    animatedValues[item.id] = item.score
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
