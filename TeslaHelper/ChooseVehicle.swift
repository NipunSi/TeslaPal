//
//  ChooseVehicle.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/14/20.
//

import SwiftUI
import TeslaSwift
import KeychainSwift

struct ChooseVehicle: View {
    let api = TeslaSwift()
    let keychain = KeychainSwift()
    public let teslaJSONDecoder = JSONDecoder()
    let themeColor = UserDefaults.standard.color(forKey: "theme")

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @State private var cars = [Vehicle]()
    
    @State private var showMainApp = false
    
    var body: some View {
//        NavigationView {
        VStack {
            List(cars, id: \.displayName) { car in
                HStack(spacing: 10){
                    Image(systemName: "car").imageScale(.large)
                        .foregroundColor(Color(themeColor ?? .green))
                    Button(action: {
                        //set as main car and move to main app
                        let mainCar = car
                        let encodedMainCar = try! teslaJSONEncoder.encode(mainCar)
                        if keychain.set(encodedMainCar, forKey: "mainCar") {
                          // Keychain item is saved successfully
                            print("Successfully saved main car")
                            self.showMainApp = true
                            self.mode.wrappedValue.dismiss()
                        } else {
                          // Report error
                            print("Error saving main car")
                        }
                    }) {
                        Text("\(car.displayName ?? "")")
                            .font(.headline)
                    }
                    
                }
            //}
        }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            MainTabViewController()
        }
        .navigationBarTitle("Choose A Car")
        .onAppear(perform: {
            getCars()
        })
    }
    
    func getCars() {
        guard let token = keychain.getData("token") else { return }
        let newToken = try! teslaJSONDecoder.decode(AuthToken.self, from: token)

       api.reuse(token: newToken)
        print("isAuth: \(api.isAuthenticated)")
        api.getVehicles { (response: Result<[Vehicle], Error>) in
           
            switch response {
                    case .success(let fetchedCars):
                        // Logged in
                        self.cars = fetchedCars
                        if cars.count == 1 {
                            //Automatically set this as the main car and move on the the app
                            let mainCar = cars[0]
                            let encodedMainCar = try! teslaJSONEncoder.encode(mainCar)
                            if keychain.set(encodedMainCar, forKey: "mainCar") {
                              // Keychain item is saved successfully
                                print("Successfully saved main car")
                                self.showMainApp = true
                            } else {
                              // Report error
                                print("Error saving main car")
                            }
                        } else if cars.count == 0 {
                            //Could not find any vehicles connected to this account
                            
                        }
                        
                    case .failure(let error):
                        // Failed
                        print("Failed to get cars")
                }
                
        }
    }
}

//struct ChooseVehicle_Previews: PreviewProvider {
//    static var previews: some View {
//        ChooseVehicle()
//    }
//}
