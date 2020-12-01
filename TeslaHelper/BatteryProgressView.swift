//
//  BatteryProgressView.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/18/20.
//

import SwiftUI

struct BatteryProgressView: View {
    @Binding var progress: Float
    let themeColor = UserDefaults.standard.color(forKey: "theme")

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color(themeColor ?? .green))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(themeColor ?? .green))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                .font(.system(size: 26, weight: .bold, design: .rounded))
        }
    }
}
