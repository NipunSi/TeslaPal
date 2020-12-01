//
//  SettingView.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/31/20.
//

import SwiftUI
import TeslaSwift
import KeychainSwift

struct SettingView: View {
    let api = TeslaSwift()
    let keychain = KeychainSwift()
    
    let themeColor = UserDefaults.standard.color(forKey: "theme")
    let colorThemes = ["Red", "Orange", "Yellow", "Green", "Blue", "Purple"]
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    @Environment(\.presentationMode) var presentationMode
    
    @State var chosenTheme: Int
    @State private var isLoggedOut = false
    @State private var tappedLogOut = false
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Change Theme", selection: $chosenTheme) {
                        ForEach(Array(colorThemes.enumerated()), id: \.offset) { index, element in
                            
                            HStack {
                                Image(systemName: "stop.fill").imageScale(.large)
                                    .foregroundColor(colors[index])
                                
                                Text(element)
                                    .font(.headline)
                                    .foregroundColor(colors[index])
                            }
                        }
                    }.onChange(of: chosenTheme, perform: { (color) in
                        UserDefaults.standard.set(UIColor(colors[chosenTheme ]), forKey: "theme")
                        print("Theme changed to \(colorThemes[chosenTheme ])")
                        
                    })
                }
                Section {
                    NavigationLink(destination: ChooseVehicle()){
                        Text("Change Selected Car")
                    }
                }
                Section {
                    Button(action: {
                        tappedLogOut = true
                    }) {
                        Text("Log Out")
                    }
                }
            }.navigationBarTitle("Settings")
        }.actionSheet(isPresented: $tappedLogOut) {
            ActionSheet(title: Text("Logging Out"), message: Text("Are you sure you want to do this?"), buttons: [
                .destructive(Text("Log Out"), action: logOut), .cancel()
            ])
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
        }
    }
    
    init() {
        let index = colorThemes.firstIndex(of: themeColor?.accessibilityName.capitalized ?? "Green") ?? 3
        _chosenTheme = State(initialValue: index)
    }
    
    func logOut() {
        api.logout()
        api.revoke { (response:Result<Bool, Error>) in
            switch response {
            case .success(let bool):
                if bool == true {
                } else {
                    print("False: \(bool)")
                    print("isAuth:\(api.isAuthenticated)")
                    keychain.clear()
                    isLoggedOut = true
                    //presentationMode.wrappedValue.dismiss()
                    
                }
            case .failure(let err):
                print("Error: \(err)")
            }
        }
        
    }
}

extension UserDefaults {
    
    func color(forKey key: String) -> UIColor? {
        
        guard let colorData = data(forKey: key) else { return nil }
        
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func set(_ value: UIColor?, forKey key: String) {
        
        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }
        
    }
    
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
