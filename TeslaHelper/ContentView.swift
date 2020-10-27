//
//  ContentView.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/14/20.
//

import SwiftUI
import TeslaSwift
import KeychainSwift

struct ContentView: View {
    @State private var showLogin = false
    @State private var showApp = false
    let api = TeslaSwift()
    let keychain = KeychainSwift()
    public let teslaJSONDecoder = JSONDecoder()
    
    var body: some View {
        
        ZStack {
            Text("")
        }.onAppear(perform: auth)
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
        .fullScreenCover(isPresented: $showApp) {
            if api.isAuthenticated {
                if (keychain.getData("mainCar") != nil) {
                    // Keychain item is fetched successfully
                    MainTabViewController()
                } else {
                    // No main car saved
                    ChooseVehicle()
                }
            } else {
                LoginView()
            }
        }
    }
    func auth() {
        guard let token = keychain.getData("token") else { return }
        let newToken = try! teslaJSONDecoder.decode(AuthToken.self, from: token)
        
        api.reuse(token: newToken)
        print("Is user authenticated?: \(api.isAuthenticated)")
        if api.isAuthenticated {
            print("Authenticated. Showing app...")
            self.showApp = true
            
            
        } else {
            print("Not Authenticated. Showing login...")
            self.showLogin = true
            
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
