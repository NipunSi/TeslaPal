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
import CoreData
import MapKit
import CoreLocation

struct ChargingView: View {
    let themeColor = UserDefaults.standard.color(forKey: "theme")
    
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
    
    @FetchRequest(entity: CarDataEntry.entity(), sortDescriptors: [])
    
    var dataEntries: FetchedResults<CarDataEntry>
    
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
    @State private var carAddress = String()
    
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
                    
                    VStack{
                        HStack {
                            Spacer()
                            Text("Range")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                            Spacer()
                        }//.padding(.bottom, 8)
                        
                        HStack(spacing: 25){
                            Spacer()
                            VStack{
                                Text("Est.")
                                    .font(.system(size: 20, design: .rounded))
                                Text("\(Int(carData?.chargeState?.estimatedBatteryRange?.miles ?? 0)) mi")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                
                            }
                            VStack{
                                Text("Rated")
                                    .font(.system(size: 20, design: .rounded))
                                Text("\(Int(carData?.chargeState?.ratedBatteryRange?.miles ?? 0)) mi")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                
                            }
                            VStack{
                                Text("Ideal")
                                    .font(.system(size: 20, design: .rounded))
                                Text("\(Int(carData?.chargeState?.idealBatteryRange?.miles ?? 0)) mi")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    //                    Text("Est. Range: \(Int(carData?.chargeState?.estimatedBatteryRange?.miles ?? 0)) mi")
                    //                    Text("Rated Range: \(Int(carData?.chargeState?.ratedBatteryRange?.miles ?? 0)) mi") //Rated driving range
                    //                    Text("Ideal Range: \(Int(carData?.chargeState?.idealBatteryRange?.miles ?? 0)) mi") //Ideal driving range
                    HStack {
                        Spacer()
                        
                        Image(systemName: "location.fill")
                        Text("\(carAddress)")
                        Spacer()
                        
                    }
                    HStack {
                        Spacer()
                        
                        Image(systemName: "arrow.counterclockwise.icloud.fill")
                        Text("Last updated at \(timestampFormatter())")
                        Spacer()
                        
                    }
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
                            .foregroundColor(Color(themeColor ?? .green))
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
                        CustomSlider(percentage: $maxChargeLimit)
                            .accentColor(Color(themeColor ?? .green))
                            .frame(height: 40)
                        
                    }
                    HStack {
                        Spacer()
                        Button("Save") {
                            print("Saving charge limit settings")
                            changeChargeLimit()
                        }
                        .foregroundColor(Color(themeColor ?? .green))
                        Spacer()
                    }
                    
                }
                
                Section {
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
                                            .foregroundColor(Color(themeColor ?? .green))
                                            .frame(width: 60, height: 40)
                                        Button(action: {
                                            print("Refresh Pressed")
                                            viewLoaded()
                                        }) {
                                            Image(systemName: "arrow.clockwise").imageScale(.large)
                                                .foregroundColor(Color(themeColor ?? .green))
                                        }
                                    })
        }.onAppear(perform: viewLoaded)
        //.disabled(isDataLoading)
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
            .background(Color(themeColor ?? .green))
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
                    print("Car state: \(wokeCar.state ?? "")")
                    if wokeCar.state == "online" {
                        print("Attempt #\(i): Car is awake.")
                        timer.invalidate()
                        isLoading = false
                        
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
                    print("Error type: \(err)")
                    if "\(err)" == "tokenRevoked" {
                        print("Token revoked")
                        self.userIsntAuthenticated = true
                        timer.invalidate()
                    }
                    isLoading = false
                    
                }
            }
        }
    }
    
    func getCarData(vehicle: Vehicle) {
        //api.debuggingEnabled = true
        isLoading = true
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        
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
                    
                    let address = CLGeocoder.init()
                    address.reverseGeocodeLocation(CLLocation(latitude: data.driveState?.latitude ?? 0, longitude: data.driveState?.longitude ?? 0)) { (places, err) in
                        if err == nil {
                            if let place = places {
                                print("Location: \(place)")
                                let placemark = place[0]
                                
                                carAddress = "\(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
                            }
                        }
                    }
                    
                    isLoading = false
                    
                    //Save data to CoreData
                    let newEntry = CarDataEntry(context: viewContext)
                    newEntry.batteryLevel = Int16(data.chargeState?.batteryLevel ?? 0)
                    newEntry.energyAdded = Int32(data.chargeState?.chargeEnergyAdded ?? 0)
                    newEntry.odometer = Int32(data.vehicleState?.odometer ?? 0)
                    newEntry.timestamp = Date()
                    newEntry.vehicleID = String(data.vehicleID ?? 0)
                    newEntry.id = UUID()
                    
                    //Check if the entry is worth adding to coredata by checking the odometer, energy added, and date
                    /// If the date is new, save it. If the date is the same, check further for if the odometer is bigger or the energysaved is different
                    guard let previousEntry = dataEntries.last else { return }
                    let previousEntryDate = df.string(from: previousEntry.timestamp ?? Date())
                    let currentDate = df.string(from: Date())
                    
                    if currentDate == previousEntryDate {
                        //There are previous entries on this day
                        if newEntry.odometer != previousEntry.odometer || newEntry.energyAdded != previousEntry.energyAdded {
                            //New odometer or energyadded value, so save it
                            do {
                                try viewContext.save()
                                print("Success: New vehicle data saved to core data.")
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else {
                            //No new information, so dont save to core data
                            print("No new vehicle data to save to core data")
                        }
                    } else {
                        //Save entry since its the first of the day
                        do {
                            try viewContext.save()
                            print("Success: Vehicle data saved to core data.")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            case .failure(let err):
                print("Error getting vehicle data: \(err)")
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
                print("Error finding charging sites: \(err)")
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
