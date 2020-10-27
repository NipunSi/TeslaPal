//
//  MainTabViewController.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/15/20.
//

import SwiftUI
//import TeslaSwift
//import KeychainSwift

struct MainTabViewController: View {
//    let api = TeslaSwift()
//    let keychain = KeychainSwift()
//    public let teslaJSONDecoder = JSONDecoder()
//    public let teslaJSONEncoder = JSONEncoder()
    var theData = CarData()
    
    @State var selectedView = 0
    
    var body: some View {
        TabView(selection: $selectedView) {
            ChargingView()
                .tabItem {
                    Image(systemName: "battery.100")
                    Text("Battery")
                    
                }.tag(0)
            ControlsView()
                .tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Controls")
                }.tag(1)
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }.tag(2)
            Text("Settings")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }.tag(3)
        }
        //.onAppear(perform: getCarData)
        .accentColor(.green)
        .environmentObject(theData)
    }
    
//    func getCarData() {
//        print("Getting car data")
//        let mainCarEncoded = keychain.getData("mainCar")
//        let car = try! teslaJSONDecoder.decode(Vehicle.self, from: mainCarEncoded!)
//
//        guard let token = keychain.getData("token") else { return }
//        let newToken = try! teslaJSONDecoder.decode(AuthToken.self, from: token)
//        api.reuse(token: newToken)
//        if api.isAuthenticated == false {
//            print("User isnt authenticated. Sending to login screen.")
//            //self.userIsntAuthenticated = true
//            return
//        }
//        var isCarAwake = false
//        var i = 0
//        while isCarAwake == false {
//            i += 1
//            sleep(1)
//            api.wakeUp(car) { (response: Result<Vehicle, Error>) in
//                switch response {
//                case .success(let wokeCar):
//                    print("Attempt #\(i) to wake up car: \(wokeCar.state ?? "")")
//                    if wokeCar.state == "online" {
//                        print("Car is awake!")
//
//                        print("Getting data!")
//                        isCarAwake = true
//                    } else {
//                        print("Car still isnt awake.")
//                    }
//                case .failure(let err):
//                    print("Error trying to wake car: \(err.localizedDescription)")
//
//                }
//            }
//        }
//
//    }
}

struct MainTabViewController_Previews: PreviewProvider {
    static var previews: some View {
        MainTabViewController()
    }
}
