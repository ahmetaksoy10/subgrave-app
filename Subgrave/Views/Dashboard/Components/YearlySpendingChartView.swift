//
//  YearlySpendingChartView.swift
//  Subgrave
//
//  Son 12 ay için aylık harcama bar grafiği.
//

import SwiftUI
import Charts

struct YearlySpendingChartView: View {
    let data: [MonthlySpending]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.subgraveAccent)
                Text("Yıllık Harcama Akışı")
                    .font(.headline)
                    .foregroundStyle(Color.subgraveText)
                Spacer()
            }
            if data.allSatisfy({ $0.amount == 0 }) {
                Text("Henüz harcama izi yok.")
                    .font(.subheadline)
                    .foregroundStyle(Color.subgraveTextSecondary)
                    .padding(.vertical, 8)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Ay", item.monthLabel),
                        y: .value("Tutar", item.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.subgraveAccent, Color.subgraveAccent.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine().foregroundStyle(Color.subgraveGrave.opacity(0.4))
                        AxisValueLabel().foregroundStyle(Color.subgraveTextSecondary)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel().foregroundStyle(Color.subgraveTextSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .subgraveCard()
    }
}
