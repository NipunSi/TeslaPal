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
import SwiftUICharts

struct StatsView: View {
    let api = TeslaSwift()
    let keychain = KeychainSwift()
    public let teslaJSONDecoder = JSONDecoder()
    public let teslaJSONEncoder = JSONEncoder()
    let themeColor = UserDefaults.standard.color(forKey: "theme")
    
    
    var car: Vehicle {
        let mainCarEncoded = keychain.getData("mainCar")
        let mainCar = try! teslaJSONDecoder.decode(Vehicle.self, from: mainCarEncoded!)
        return mainCar
    }
    
    @EnvironmentObject var carData: CarData
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: CarDataEntry.entity(), sortDescriptors: [
        NSSortDescriptor(key: "timestamp", ascending: true)
    ])
    
    var dataEntries: FetchedResults<CarDataEntry>
    
    @State private var dailyDistances = [(String, Double)]()
    @State private var dailyEnergyAdded = [(String, Double)]()
    
    
    // @State private var isRecordingTrip: Bool?
    @State private var odometer: Int?
    
    var style: ChartStyle?
    
    //var testDistances = ChartData(values: [("Nov 1, 2020", 30), ("Nov 2, 2020", 22), ("Nov 3, 2020", 11), ("Nov 4, 2020", 6), ("Nov 5, 2020", 49), ("Nov 6, 2020", 0), ("Nov 7, 2020", 10), ("Nov 8, 2020", 80), ("Nov 9, 2020", 63), ("Nov 10, 2020", 5), ("Nov 11, 2020", 54), ("Nov 12, 2020", 16), ("Nov 13, 2020", 32), ("Nov 14, 2020", 21), ("Nov 15, 2020", 56), ("Nov 16, 2020", 0), ("Nov 17, 2020", 0), ("Nov 18, 2020", 22), ("Nov 19, 2020", 39), ("Nov 20, 2020", 94)])
    
    // var testCharges = ChartData(values: [("Nov 1, 2020", 32), ("Nov 2, 2020", 5), ("Nov 3, 2020", 8), ("Nov 4, 2020", 6), ("Nov 5, 2020", 12), ("Nov 6, 2020", 50), ("Nov 7, 2020", 16), ("Nov 8, 2020", 0), ("Nov 9, 2020", 0), ("Nov 10, 2020", 2), ("Nov 11, 2020", 12), ("Nov 12, 2020", 2), ("Nov 13, 2020", 15), ("Nov 14, 2020", 6), ("Nov 15, 2020", 20), ("Nov 16, 2020", 0), ("Nov 17, 2020", 0), ("Nov 18, 2020", 12), ("Nov 19, 2020", 19), ("Nov 20, 2020", 60)])
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        //  .padding()
                        BarChartView(data: ChartData(values: dailyDistances), title: "Daily Distance", legend: "Miles Per Day", unit: "mi", style: style ?? ChartStyle(formSize: ChartForm.medium), form: ChartForm.medium, dropShadow: false, cornerImage: Image(systemName: "mappin"), valueSpecifier: "%.0f")
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    
                }
                .background(Color(UIColor.systemBackground))
                
                Section {
                    HStack {
                        Spacer()
                        //  .padding()
                        BarChartView(data: ChartData(values: dailyEnergyAdded), title: "Daily Charge", legend: "kWh Per Day", unit: "kWh", style: style ?? ChartStyle(formSize: ChartForm.medium), form: ChartForm.medium, dropShadow: false, cornerImage: Image(systemName: "bolt"), valueSpecifier: "%.0f")
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    
                }
                .background(Color(UIColor.systemBackground))
                
                Section {
                    Text("Odometer: \(odometer ?? 0) mi")
                }
                
                
                //}
            }.navigationBarTitle("Stats")
        }.onAppear(perform: viewLoaded)
    }
    
    init() {
        style = ChartStyle(backgroundColor: Color(UIColor.secondarySystemGroupedBackground), accentColor: Color(themeColor ?? .green), gradientColor: GradientColor(start: Color(themeColor ?? .green), end: Color(themeColor ?? .green)), textColor: Color(UIColor.label), legendTextColor: Color(UIColor.gray), dropShadowColor: Color(UIColor.gray))
        
    }
    
    func viewLoaded() {
        tryToAuth()
        api.debuggingEnabled = true
        
        if carData.data.count > 0 {
            let data = carData.data[0]
            odometer = Int(data.vehicleState?.odometer ?? 0)
        }
        
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        
        ///Create data for distance per day chart
        
        if dataEntries.isEmpty {
            print("No data entries")
        } else {
            print("\(dataEntries.count) data entries")
            
            if dailyDistances.count == 0 {
                
                dailyDistances = [(String, Double)]()
                dailyEnergyAdded = [(String, Double)]()
                
                
                var lastMiles = Double(dataEntries[0].odometer)
                var lastEnergyAdded = Double(dataEntries[0].energyAdded)
                var lastDate = df.string(from: dataEntries[0].timestamp!)
                //print("Last odometer: \(lastMiles)")
                
                //Add an entry to the array only if its a new day, or its the same day but the odometers higher (and get rid of the old one)
                for (index, entry) in dataEntries.enumerated() {
                    let date = df.string(from: entry.timestamp!)
                    let odometer = Double(entry.odometer)
                    let energyAdded = Double(entry.energyAdded)
                    
                    if date == lastDate {
                        if odometer > lastMiles {
                            //Case: Same day as last, but the odometers higher
                            dailyDistances.removeAll(where: {$0.0 == date})
                            let change = odometer - lastMiles
                            let tuple = (date, change)
                            dailyDistances.append(tuple)
                        } else {
                            //Case: Same day as last, but the odometer isnt higher so ignore it
                        }
                        
                        if energyAdded > lastEnergyAdded {
                            //Case: Same day, but higher energy added
                            dailyEnergyAdded.removeAll(where: {$0.0 == date})
                            let tuple = (date, energyAdded)
                            dailyEnergyAdded.append(tuple)
                            lastEnergyAdded = energyAdded
                        } else {
                            //Case: Same energy added, no update needed
                        }
                    } else { //New date
                        if odometer > lastMiles {
                            //Case: New day and the odometers higher
                            let yesterdaysHigh = Double(dataEntries[index - 1].odometer)
                            
                            let change = odometer - yesterdaysHigh
                            let tuple = (date, change)
                            dailyDistances.append(tuple)
                            
                            lastMiles = odometer
                            lastDate = date
                        } else {
                            //Case: New day, but the odometer isnt higher.
                            let tuple = (date, 0.0)
                            dailyDistances.append(tuple)
                            lastMiles = odometer
                            lastDate = date
                        }
                        
                        let tuple = (date, energyAdded)
                        dailyEnergyAdded.append(tuple)
                    }
                }
            }
        }
        

    }
    
    func tryToAuth() {
        guard let token = keychain.getData("token") else { return }
        guard let newToken = try? teslaJSONDecoder.decode(AuthToken.self, from: token) else { return }
        api.reuse(token: newToken)
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
