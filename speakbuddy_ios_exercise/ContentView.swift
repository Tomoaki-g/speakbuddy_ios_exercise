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
    let month: String
    var score: Double
}

struct ContentView: View {
    private var data: [MonthlyScores] = [
        MonthlyScores(month: "現在", score: 50),
        MonthlyScores(month: "3ヶ月", score: 80),
        MonthlyScores(month: "1年", score: 180),
        MonthlyScores(month: "2年", score: 250),
    ]
    
    var body: some View {
        ZStack {
            Color.background
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
                .padding(.trailing, 30)
                
                Text("Hello\nSpeakBUDDY")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.center)
                
                ZStack(alignment: .topLeading) {
                    Chart(data) { item in
                        BarMark(
                            x: .value("月", item.month),
                            y: .value("売上", item.score)
                        )
                        .foregroundStyle(.base)
                    }
                    .chartXAxis {
                        AxisMarks {
                            AxisValueLabel()
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.text)
                        }
                    }
                    .chartYAxis(.hidden)
                    .padding()
                    .animation(.easeInOut(duration: 0.6), value: data)
                    
                    Image(.protty)
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                }
                
                VStack {
                    Text("スピークバディで")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.text)
                    Text("レベルアップ")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.startGradient, .endGradient],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .frame(alignment: .center)
                
                Button(action: {
                    print("ボタンが押されました")
                }) {
                    Text("プランに登録する")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(
                            Capsule().fill(.base)
                        )
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
