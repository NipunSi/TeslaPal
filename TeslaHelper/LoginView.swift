//
//  LoginView.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/14/20.
//

import SwiftUI
import TeslaSwift
import KeychainSwift

struct LoginView: View {
    let keychain = KeychainSwift()

    @State var email: String = "nipunbusiness@gmail.com"
    @State var password: String = "Kumar545"
    @State var isAuth = false
    
    public let teslaJSONEncoder = JSONEncoder()
    public let teslaJSONDecoder = JSONDecoder()

    var cars = [Vehicle]()
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                //.background(Color.gray)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            SecureField("Password", text: $password)
                .padding()
                //.background(Color.gray)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            Button(action: {
                print("Atempting login")
                let api = TeslaSwift()
                api.authenticate(email: email, password: password) {
                    (result: Result<AuthToken, Error>) in
                    switch result {
                    case .success(let token):
                        // Logged in
                        print("Logged in. Token: \(token)")
                        
                        saveToken(token: token)
                        
                        self.isAuth = true
                        
                    case .failure(let error):
                        // Failed
                        print("Failed: \(error)")
                        
                    }
                }
                
            }) {
                Text("Authenticate with Tesla")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.red)
                    .cornerRadius(15.0)
            }
            .fullScreenCover(isPresented: $isAuth, content: {
                
                if (keychain.getData("mainCar") != nil) {
                  // Keychain item is fetched successfully
                    MainTabViewController()
                } else {
                  // No main car saved
                    ChooseVehicle()
                }
            })
        }
        .padding()
    }
    func saveToken(token: AuthToken) {
        let newToken = try! teslaJSONEncoder.encode(token)
        keychain.set(email, forKey: "email")
        if keychain.set(newToken, forKey: "token") {
          // Keychain item is saved successfully
            print("Success")
        } else {
          // Report error
            print("Error")
        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
