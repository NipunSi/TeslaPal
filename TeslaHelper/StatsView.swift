//
//  StatsView.swift
//  Pods
//
//  Created by Nipun Singh on 10/26/20.
//


//Get vehicle data every certain amount of hours.

import SwiftUI
import TeslaSwift
import KeychainSwift
import ExytePopupView
import ActivityIndicatorView

struct StatsView: View {
    let api = TeslaSwift()
    let keychain = KeychainSwift()
    public let teslaJSONDecoder = JSONDecoder()
    public let teslaJSONEncoder = JSONEncoder()
    
    var car: Vehicle {
        let mainCarEncoded = keychain.getData("mainCar")
        let mainCar = try! teslaJSONDecoder.decode(Vehicle.self, from: mainCarEncoded!)
        return mainCar
    }
    
    @EnvironmentObject var carData: CarData
    
    @State private var isRecordingTrip: Bool?
    @State private var odometer: Int?
    
    var body: some View {
        NavigationView {
            ScrollView {
//                HStack {
//                    Button(action: {
//                        print("Starting trip recording...")
//                    }) {
//                        Text("Start Trip")
//                    }
//                }
                Form {
                    Section {
                        Text("Current Trip Stats")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        Text("MPGe:") //How many miles the car goes while consuming 33.7 kWh
                        Text("Time Elapsed:") //How long the trip is
                        Text("Distance:")
                        Text("Range Used:")
                        Text("Energy Used:")
                    }
                    Section {
                        Text("Past Trips")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                    }
                    
                    Section {
                        Text("Odometer: \(odometer ?? 0) mi")
                        
                    }
                }
            }.navigationBarTitle("Stats")
        }.onAppear(perform: viewLoaded)
    }
    
    func viewLoaded() {
        tryToAuth()
        api.debuggingEnabled = true
        let data = carData.data[0]
        odometer = Int(data.vehicleState?.odometer ?? 0)
        
//        api.openStream(vehicle: car, reloadsVehicle: true) { (event: TeslaStreamingEvent) in
//            switch event {
//            case .open:
//                print("Case open?")
//            case .event(let streamEvent):
//                print(streamEvent)
//            case .error(let err):
//                print("Streaming Error: \(err.localizedDescription)")
//            case .disconnected:
//                break
//            }
//        }
        
        api.openStream(vehicle: car) { (event: TeslaStreamingEvent) in
            switch event {
            case .open:
                print("Case open?")
            case .event(let streamEvent):
                print(streamEvent)
            case .error(let err):
                print("Streaming Error: \(err)")
            case .disconnected:
                break
            }
        }
        
        
    }
    
    func tryToAuth() {
        let email = "nipunbusiness@gmail.com"
        guard let token = keychain.getData("token") else { return }
        let newToken = try! teslaJSONDecoder.decode(AuthToken.self, from: token)
        api.reuse(token: newToken, email: email)
        //api.reuse(token: newToken)
        if api.isAuthenticated == false {
            print("User isnt authenticated. Sending to login screen.")
            //self.userIsntAuthenticated = true
            return
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
