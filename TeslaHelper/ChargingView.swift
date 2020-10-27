//
//  ChargingView.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/15/20.
//

import SwiftUI
import TeslaSwift
import KeychainSwift
import ExytePopupView
import ActivityIndicatorView

struct ChargingView: View {
    let api = TeslaSwift()
    let keychain = KeychainSwift()
    public let teslaJSONDecoder = JSONDecoder()
    public let teslaJSONEncoder = JSONEncoder()
    
    var car: Vehicle {
        let mainCarEncoded = keychain.getData("mainCar")
        let mainCar = try! teslaJSONDecoder.decode(Vehicle.self, from: mainCarEncoded!)
        return mainCar
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var carInfo: CarData
    
    @State var carData: VehicleExtended?
    
    @State var showingSavedPopup = false
    @State var showingFailedSavePopup = false
    
    
    @State private var userIsntAuthenticated = false
    @State private var isLoading = false

    //@State private var chargeState: ChargeState?
    @State private var chargingSites: NearbyChargingSites?
    @State private var superchargers: [NearbyChargingSites.Supercharger]?
    @State private var maxChargeLimit: Float = 0
    @State private var batteryPercentage: Float = 0
    @State private var hasScheduledCharging = false
    
    @State private var isDataLoading = true
    
    var body: some View {
        NavigationView {
            Form {
                Section { //Car/Batttery info
                        Text(car.displayName ?? "")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                    BatteryProgressView(progress: $batteryPercentage)
                            .frame(height: 125)
                            .padding(15)
                   // Text("Est. Range: \(Int(chargeState?.estimatedBatteryRange?.miles ?? 0)) mi") //Estimated driving range
                    Text("Est. Range: \(Int(carData?.chargeState?.estimatedBatteryRange?.miles ?? 0)) mi")
                    
                    Text("Rated Range: \(Int(carData?.chargeState?.ratedBatteryRange?.miles ?? 0)) mi") //Rated driving range
                    Text("Ideal Range: \(Int(carData?.chargeState?.idealBatteryRange?.miles ?? 0)) mi") //Ideal driving range
                    Text("Last updated at \(timestampFormatter())")
                        .font(.subheadline)
                }
                
                Section {
                    switch carData?.chargeState?.chargingState?.rawValue {
                    case "Charging":
                        Text("Status: Charging")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        Text("Time to full charge: \(Int(carData?.chargeState?.timeToFullCharge ?? 0)) mins")
                        Text("Charge rate: \(Int(carData?.chargeState?.chargeRate?.milesPerHour ?? 0)) mi/h")
                        Text("Power: \(carData?.chargeState?.chargerPower ?? 0) KW")
                        Text("Distance Added: \(Int(carData?.chargeState?.chargeDistanceAddedRated?.miles ?? 0)) mi")
                        Text("Energy Added: \(carData?.chargeState?.chargeEnergyAdded ?? 0, specifier: "%g") kWh")
                        HStack {
                            Spacer()
                            Button("Stop Charging") {
                                print("Stop Charging...")
                                stopCharging()
                            }
                            .foregroundColor(.red)
                            Spacer()
                        }
                    case "Stopped":
                        Text("Status: Stopped")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        Text(hasScheduledCharging ? "Charging scheduled at \(getChargingDate())" : "No Charging Scheduled")
                        HStack {
                            Spacer()
                            Button("Start Charging") {
                                print("Start charging...")
                                startCharging()
                            }
                            .foregroundColor(.green)
                            Spacer()
                        }
                    case "Complete":
                        Text("Status: Completed")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        Text("Distance Added: \(Int(carData?.chargeState?.chargeDistanceAddedRated?.miles ?? 0)) mi")
                        Text("Energy Added: \(carData?.chargeState?.chargeEnergyAdded ?? 0, specifier: "%g") kWh")
                        HStack {
                            Spacer()
                            Button("Start Charging") {
                                print("")
                            }
                            .disabled(true)
                            Spacer()
                        }
                    case "Disconnected":
                        Text("Status: Disconnected")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        HStack {
                            Spacer()
                            Button("Start Charging") {
                                print("")
                            }
                            .disabled(true)
                            Spacer()
                        }
                    default:
                        EmptyView()
                    }
                }
                
                Section { //Info about battery settings
                    Text("Preferences")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    VStack {
                        Text("Max Charge Limit: \(Int(maxChargeLimit))%")
                        //Slider(value: $maxChargeLimit, in: 50...100, step: 5)
                        CustomSlider(percentage: $maxChargeLimit)
                            .accentColor(Color.green)
                            .frame(height: 40)
                        
                    }
                    HStack {
                        Spacer()
                        Button("Save") {
                            print("Saving charge limit settings")
                            changeChargeLimit()
                        }
                        .foregroundColor(.green)
                        Spacer()
                    }
                    
                }
                
                Section { //TODO: Create a detail screen for each supercharger with the coordinated passed in to show on a map.
                    Text("Nearby Superchargers")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    ForEach(superchargers ?? [NearbyChargingSites.Supercharger](), id: \.name) { site in
                        NavigationLink(destination: ChargerDetailView(charger: site)) {
                            VStack (alignment: .leading){
                                HStack {
                                    Text(site.name ?? "Loading")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(Int(site.distance?.miles ?? 0)) mi")
                                        .bold()
                                }
                                Text("\(site.availableStalls ?? 0) / \(site.totalStalls ?? 0) available")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                //Spacer()
            }.navigationBarTitle("Battery")
            .navigationBarItems(trailing:
                HStack {
                    ActivityIndicatorView(isVisible: $isLoading, type: .scalingDots)
                        .foregroundColor(.green)
                        .frame(width: 60, height: 40)
                    Button(action: {
                        print("Refresh Pressed")
                        viewLoaded()
                    }) {
                        Image(systemName: "arrow.clockwise").imageScale(.large)
                            .foregroundColor(.green)
                    }
                })
        }.onAppear(perform: viewLoaded)
        .disabled(isDataLoading)
        .fullScreenCover(isPresented: $userIsntAuthenticated) {
            LoginView()
        }
        .popup(isPresented: $showingSavedPopup, type: .floater(), position: .top, autohideIn: 2, closeOnTap: true, closeOnTapOutside: false) {
            HStack {
                Image(systemName: "checkmark").imageScale(.large)
                
                Text("Saved \(Int(maxChargeLimit))% Limit")
                    .font(.headline)
            }
            .frame(width: 250, height: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(30.0)
        }
        .popup(isPresented: $showingFailedSavePopup, type: .floater(), position: .top, autohideIn: 2, closeOnTap: true, closeOnTapOutside: false) {
            HStack {
                Image(systemName: "exclamationmark.triangle").imageScale(.large)
                
                Text("Unable To Save Limit")
                    .font(.headline)
            }
            .frame(width: 250, height: 50)
            .background(Color.yellow)
            .foregroundColor(.white)
            .cornerRadius(30.0)
        }
    }
    
    func timestampFormatter() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    func getChargingDate() -> String {
        let timestamp = carData?.chargeState?.scheduledChargingStartTime ?? 0
        let date = NSDate(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a" //Specify your format that you want
        let strDate = dateFormatter.string(from: date as Date)
        return strDate
    }
    
    func viewLoaded() {
        DispatchQueue.main.async {
            tryToAuth()
            wakeCarAndGetData()
        }
    }
    
    func tryToAuth() {
        guard let token = keychain.getData("token") else { return }
        let newToken = try! teslaJSONDecoder.decode(AuthToken.self, from: token)
        api.reuse(token: newToken)
        if api.isAuthenticated == false {
            print("User isnt authenticated. Sending to login screen.")
            self.userIsntAuthenticated = true
            return
        }
    }
        
    func wakeCarAndGetData() {
        isLoading = true
        var i = 0
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            api.wakeUp(car) { (response: Result<Vehicle, Error>) in
                i += 1
                switch response {
                case .success(let wokeCar):
                    if wokeCar.state == "online" {
                        print("Attempt #\(i): Car is awake.")
                        timer.invalidate()
                        isLoading = false
                        
                        //print("Car: \(wokeCar.jsonString ?? "IDK")")
                        //Get charge state and charging sites data
                        getCarData(vehicle:wokeCar)
                        getChargingSites(vehicle: wokeCar)
                        isDataLoading = false
                        return
                    } else {
                        print("Attempt #\(i): Car still isnt awake.")
                    }
                case .failure(let err):
                    print("Error waking up car: \(err.localizedDescription)")
                    isLoading = false

                }
            }
        }
    }
    
    func getCarData(vehicle: Vehicle) {
        api.debuggingEnabled = true
        isLoading = true
        
            api.getAllData(vehicle) { (response: Result<VehicleExtended, Error>) in
                
                switch response {
                case .success(let data):
                    
                    print("Got car data!: \(data)")
                    
                    DispatchQueue.main.async {
                        carData = data
                        carInfo.data.append(data)
                        batteryPercentage = Float(data.chargeState?.batteryLevel ?? 0) / 100
                        maxChargeLimit = Float(data.chargeState?.chargeLimitSOC ?? 0)
                        hasScheduledCharging = data.chargeState?.scheduledChargingPending ?? false
                        isLoading = false
                        
                        //Save data to CoreData
                        let newEntry = CarDataEntry()

                    }
                case .failure(let err):
                    print("Error getting vehicle data: \(err.localizedDescription)")
                    isLoading = false

                }
            }
        
    }
    
    func getChargingSites(vehicle: Vehicle) {
        isLoading = true
        api.getNearbyChargingSites(vehicle) { (response: Result<NearbyChargingSites, Error>) in
            switch response {
            case .success(let sites):
                //print(sites.jsonString!)
                superchargers = sites.superchargers!
                isLoading = false
            case .failure(let err):
                print("Error finding charging sites: \(err.localizedDescription)")
                isLoading = false
            }
            
        }
    }
    
    func stopCharging() {
        isLoading = true
        api.sendCommandToVehicle(car, command: .stopCharging) { (response: Result<CommandResponse, Error>) in
            switch response {
            case .success(let resp):
                isLoading = false
                if resp.result! {
                    print("Succesfully stopped charging: \(resp.reason ?? "")")
                } else {
                    print("Unable to stop charging: \(resp.reason ?? "")")
                }
            case .failure(let err):
                print("Error when trying to stop charging: \(err.localizedDescription)")
                isLoading = false
            }
        }
    }
    
    func startCharging() {
        isLoading = true
        api.sendCommandToVehicle(car, command: .startCharging) { (response: Result<CommandResponse, Error>) in
            switch response {
            case .success(let resp):
                isLoading = false
                if resp.result! {
                    print("Succesfully started charging: \(resp.reason ?? "")")
                } else {
                    print("Unable to start charging: \(resp.reason ?? "")")
                }
            case .failure(let err):
                print("Error when trying to start charging: \(err.localizedDescription)")
                isLoading = false
            }
        }
    }
    
    func changeChargeLimit() {
        api.sendCommandToVehicle(car, command: .chargeLimitPercentage(limit: Int(maxChargeLimit))) { (response: Result<CommandResponse, Error>) in
            switch response {
            case .success(let resp):
                if resp.result! {
                    print("Succesfully updated max charge limit to \(Int(maxChargeLimit))")
                    showingSavedPopup = true
                    
                } else {
                    print("Unable to update max charge limit to \(Int(maxChargeLimit)): \(resp.reason ?? "")")
                    showingFailedSavePopup = true
                    
                }
            case .failure(let err):
                print("Error when trying update max charge limit to \(Int(maxChargeLimit)): \(err.localizedDescription)")
                showingFailedSavePopup = true
                
            }
        }
    }
    
    func reloadData() {
        wakeCarAndGetData()
    }
}

//struct ChargingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChargingView()
//    }
//}
