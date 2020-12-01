//
//  LoginView.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/14/20.
//

import SwiftUI
import TeslaSwift
import KeychainSwift
import ExytePopupView

struct LoginView: View {
    let keychain = KeychainSwift()
    let themeColor = UserDefaults.standard.color(forKey: "theme")

    @State var email: String = ""//"nipunbusiness@gmail.com"
    @State var password: String = ""//"Kumar545"
    @State var isAuth = false
    
    @State var showLearnMore = false
    @State var showFailPopup = false
    
    public let teslaJSONEncoder = JSONEncoder()
    public let teslaJSONDecoder = JSONDecoder()

    var cars = [Vehicle]()
    
    var body: some View {
        VStack {
            HStack {
            Image(systemName: "bolt.fill").imageScale(.large)
                .foregroundColor(Color(themeColor ?? .green))
            Text("Welcome to TeslaPal")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                Image(systemName: "bolt.fill").imageScale(.large)
                    .foregroundColor(Color(themeColor ?? .green))
            }
            .padding(.top, 10)
            Text("Sign in below with your Tesla account")
                .padding()
                .font(.headline)
            TextField("Email", text: $email)
                .padding()
                .background(Color(UIColor.systemGray5))
                .cornerRadius(30)
                .padding(.bottom, 20)
            SecureField("Password", text: $password)
                .padding()
                .background(Color(UIColor.systemGray5))
                .cornerRadius(30)
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
                        print("Failed: \(error.localizedDescription)")
                        showFailPopup = true
                        
                    }
                }
                
            }) {
                HStack(spacing: 5){
                    Spacer()
                    Image(systemName: "lock.fill").imageScale(.large)
                        .foregroundColor(.white)
                    Text("Authenticate with Tesla")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        //.frame(width: 180, height: 60)
                    Spacer()
                    
                }
                .background(Color(themeColor ?? .green))
                .cornerRadius(30.0)
            }
            
            Button(action: {
                showLearnMore = true
            }) {
                Text("Why does TeslaPal need my Tesla account?").underline()
                    .foregroundColor(Color(themeColor ?? .green))
                    .padding()
            }
            .alert(isPresented: $showLearnMore) {
                Alert(title: Text("Good question!"), message: Text("TeslaPal uses your Tesla credentials to contact the Tesla servers and get basic information about your car. However, everything is done localy on your device with privacy in mind. That means your credentials never leave your device or connect to any external servers other than Tesla's. Feel free to contact me at nipunbusiness@gmail.com with any further questions or concerns. Thank you!"), dismissButton: .cancel(Text("Dismiss")))
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
            //Spacer()
        }
        .padding()
        .popup(isPresented: $showFailPopup, type: .floater(), position: .top, autohideIn: 2, closeOnTap: true, closeOnTapOutside: false) {
            HStack {
                Image(systemName: "exclamationmark.triangle").imageScale(.large)
                
                Text("Unable to sign in")
                    .font(.headline)
            }
            .frame(width: 300, height: 50)
            .background(Color.yellow)
            .foregroundColor(.white)
            .cornerRadius(30.0)
        }
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
