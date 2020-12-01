//
//  CustomAlert.swift
//  Pods
//
//  Created by Nipun Singh on 10/23/20.
//

import SwiftUI

struct CustomAlert: View {
    @Binding var textEntered: String
    @Binding var showingAlert: Bool
    let themeColor = UserDefaults.standard.color(forKey: "theme")

    //@Binding var sendStartCommand: Bool
    var command: () -> Void
    
    var body: some View {
        
        VStack(spacing: 5){
            //VStack {
            Image(systemName: "lock.fill").imageScale(.large)
                .padding(-10)
            Text("Authorize with your Tesla password")
                .font(.headline)
                .frame(height: 50)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding()
            //}
            SecureField("Password", text: $textEntered)
                .padding()
                .frame(height: 40)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            HStack {
               // Spacer()
                Button("Cancel") {
                    print("Cancelling car!")
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    self.showingAlert.toggle()
                }
                .font(.headline)
                .foregroundColor(.red)
                .padding()
                .frame(width: 125, height: 50)
                .overlay(
                       RoundedRectangle(cornerRadius: 10)
                           .stroke(Color.red, lineWidth: 1)
                   )

                Spacer(minLength: 30)
                
            Button("Start") {
               // print("Starting car!")
                
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                command()

                self.showingAlert.toggle()
            }.font(.headline)
            .padding()
            .frame(width: 125, height: 50)
            .overlay(
                   RoundedRectangle(cornerRadius: 10)
                       .stroke(Color(themeColor ?? .green), lineWidth: 1)
               )

                
               // Spacer()
            }
            .padding()
            
        }
        .padding()
        //.background(Color(UIColor.secondarySystemGroupedBackground))
        //.cornerRadius(20)
        .frame(width: 300, height: 250)
        .animation(.default)
    }
}
