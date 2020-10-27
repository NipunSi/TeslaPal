//
//  ControlsView.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/18/20.
//

import SwiftUI
import TeslaSwift
import KeychainSwift
import ExytePopupView
import ActivityIndicatorView

struct ControlsView: View {
    
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
    
    @State private var isLoading = false
    
    @State var showSuccessPopup = false
    @State var showFailPopup = false
    @State var popupMessage = ""
    
    @State private var userIsntAuthenticated = false
    
    @State private var isLocked = false
    @State private var isPortOpen = false
    @State private var isClimateOn = false
    @State private var isRemoteStartEnabled = false
    @State private var isSteeringWheelHeaterOn = false
    @State private var isWindowOpen = false
    @State private var isSentryModeOn = false

    //@State private var carData: VehicleExtended?
    
    @State private var driverTemp: Double = 0
    @State private var passengerTemp: Double = 0
    
    @State var askingForPassword = false
    @State var userPassword = ""
//    @State var sendStart = false {
//        didSet {
//            remoteStart()
//        }
//    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: 10){
                    VStack(spacing: 10){
                        HStack{
                            if isLocked == false {
                               CommandButton(imageName: "lock", title: "Lock Doors", command: sendCommand, commandName: .lockDoors, successMessage: "Locked Doors", failMessage: "Couldn't Lock Doors")
                            } else {
                                CommandButton(imageName: "lock.open", title: "Unlock Doors", command: sendCommand, commandName: .unlockDoors, successMessage: "Unlocked Doors", failMessage: "Couldn't Unlock Doors")
                            }
                            
                            if isPortOpen == true {
                                CommandButton(imageName: "bolt.slash", title: "Close Charge Port", command: sendCommand, commandName: .closeChargeDoor, successMessage: "Close Charge Port", failMessage: "Couldn't Close Charge Port")
                            } else {
                                CommandButton(imageName: "bolt", title: "Open Charge Port", command: sendCommand, commandName: .openChargeDoor, successMessage: "Opened Charge Port", failMessage: "Couldn't Open Charge Port")
                            }
                        }
                        HStack{
                            CommandButton(imageName: "speaker.2", title: "Honk Horn", command: sendCommand, commandName: .honkHorn, successMessage: "Honked Horn", failMessage: "Couldn't Honk Horn")
                            if isSentryModeOn == false {
                                CommandButton(imageName: "eye.fill", title: "Turn On Sentry Mode", command: sendCommand, commandName: .sentryMode(activated: true) , successMessage: "Turned On Sentry Mode", failMessage: "Couldn't Turn On Sentry Mode")
                            } else {
                                CommandButton(imageName: "eye", title: "Turn Off Sentry Mode", command: sendCommand, commandName: .sentryMode(activated: false) , successMessage: "Turned Off Sentry Mode", failMessage: "Couldn't Turn Off Sentry Mode")
                            }
                        }
                        HStack {
                            CommandButton(imageName: "car", title: "Open Trunk", command: sendCommand, commandName: .lockDoors, successMessage: "Opened Trunk", failMessage: "Couldn't Open Trunk")
                            if isWindowOpen == false {
                                CommandButton(imageName: "chevron.compact.down", title: "Vent Windows", command: sendCommand, commandName: .windowControl(state: .vent), successMessage: "Vented Windows", failMessage: "Couldn't Vent Windows")
                            } else {
                                CommandButton(imageName: "chevron.compact.up", title: "Close Windows", command: sendCommand, commandName: .windowControl(state: .close), successMessage: "Closed Windows", failMessage: "Couldn't Close Windows")
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    
                    VStack(spacing: 10) {
                        Text("Temperature")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        HStack {
                            //Text("Outside: \(Int(carData.data[0].climateState?.outsideTemperature?.fahrenheit ?? 0))°")
                            Text("Outside: \(Int(driverTemp))°")

                                .font(.headline)
                            //Text("Inside: \(Int(carData.data[0].climateState?.insideTemperature?.fahrenheit ?? 0))°")
                            Text("Inside: \(Int(passengerTemp))°")

                                .font(.headline)
                        }
                        HStack {
                            if isClimateOn == false {
                                CommandButton(imageName: "wind", title: "Enable Climate", command: sendCommand, commandName: .startAutoConditioning , successMessage: "Enabled Climate", failMessage: "Couldn't Enable Climate")
                            } else {
                                CommandButton(imageName: "wind", title: "Disable Climate", command: sendCommand, commandName: .stopAutoConditioning , successMessage: "Disabled Climate", failMessage: "Couldn't Disable Climate")
                            }
                            
                            if isSteeringWheelHeaterOn == false {
                                CommandButton(imageName: "sun.min.fill", title: "Enable Steering Wheel Heater", command: sendCommand, commandName: .setSteeringWheelHeater(on: true) , successMessage: "Enabled Steering Wheel Heater", failMessage: "Couldn't Enable Steering Wheel Heater")
                            } else {
                                CommandButton(imageName: "sun.min", title: "Disable Steering Wheel Heater", command: sendCommand, commandName: .setSteeringWheelHeater(on: false) , successMessage: "Disabled Steering Wheel Heater", failMessage: "Couldn't Disable Steering Wheel Heater")
                            }
                        }
                        
                        HStack {
                            Text("Driver: \(Int(driverTemp))°")
                                .font(.headline)
                                .frame(width: 125)

                            Slider(value: $driverTemp, in: 65...85, step: 1) {_ in
                                print("Setting driver temp to \(driverTemp)")
                                setTemp()
                            }
                        }
                        HStack{
                            Text("Passenger: \(Int(passengerTemp))°")
                                .font(.headline)
                                .frame(width: 125)

                            Slider(value: $passengerTemp, in: 65...85, step: 1) {_ in
                                print("Setting passenger temp to \(passengerTemp)")
                                setTemp()
                            }
                           
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    
                    
                    VStack {
                        Button(action: {
                            print("Remote start")
                            askingForPassword = true
                        }) {
                            HStack {
                                Image(systemName: "power").imageScale(.large)
                                Text("Remote Start")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                            }
                            .padding()
                            .frame(width: 300, height: 70)
                            .background(askingForPassword ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .disabled(!isRemoteStartEnabled)
                        }
                        
                        if askingForPassword {
                            CustomAlert(textEntered: $userPassword, showingAlert: $askingForPassword, command: remoteStart)
                                .opacity(askingForPassword ? 1 : 0)
                                .animation(.default)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .animation(.default)
                    Spacer()
                }
            }.navigationBarTitle("Controls")
            .padding()
            .navigationBarItems(trailing: ActivityIndicatorView(isVisible: $isLoading, type: .scalingDots)
                                    .foregroundColor(.green)
                                    .frame(width: 60, height: 40))
        }.onAppear(perform: prepareScreen)
        .fullScreenCover(isPresented: $userIsntAuthenticated) {
            LoginView()
        }
        .popup(isPresented: $showSuccessPopup, type: .floater(), position: .top, autohideIn: 2, closeOnTap: true, closeOnTapOutside: false) {
            HStack {
                Image(systemName: "checkmark").imageScale(.large)
                
                Text(popupMessage)
                    .font(.headline)
            }
            .frame(width: 300, height: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(30.0)
        }
        .popup(isPresented: $showFailPopup, type: .floater(), position: .top, autohideIn: 2, closeOnTap: true, closeOnTapOutside: false) {
            HStack {
                Image(systemName: "exclamationmark.triangle").imageScale(.large)
                
                Text(popupMessage)
                    .font(.headline)
            }
            .frame(width: 300, height: 50)
            .background(Color.yellow)
            .foregroundColor(.white)
            .cornerRadius(30.0)
        }
    }
    
    func prepareScreen() {
        tryToAuth()
        //getCarData()
        isLoading = false
        
        let data = carData.data[0]
        isLocked = data.vehicleState?.locked ?? true
        isPortOpen = data.chargeState?.chargePortDoorOpen ?? false
        isClimateOn = data.climateState?.isClimateOn ?? false
        isRemoteStartEnabled = data.vehicleState?.remoteStartSupported ?? false
        isSteeringWheelHeaterOn = data.climateState?.steeringWheelHeater ?? false
        isSentryModeOn = data.vehicleState?.sentryMode ?? false
        if data.vehicleState?.driverWindowOpen ?? false || data.vehicleState?.driverWindowOpen ?? false || data.vehicleState?.driverWindowOpen ?? false || data.vehicleState?.driverWindowOpen ?? false {
            isWindowOpen = true
        }
        driverTemp = (data.climateState?.driverTemperatureSetting?.fahrenheit ?? 0)
        passengerTemp = (data.climateState?.passengerTemperatureSetting?.fahrenheit ?? 0)
        
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
    
    func getCarData() {
        isLoading = true
        api.getAllData(car) { (response: Result<VehicleExtended, Error>) in
            isLoading = false
            switch response {
            case .success(let data):
                print("Succesfully fetched all vehicle data for ControlsView.")
                //carData = data
                isLocked = data.vehicleState?.locked ?? true
                isPortOpen = data.chargeState?.chargePortDoorOpen ?? false
                isClimateOn = data.climateState?.isClimateOn ?? false
                isRemoteStartEnabled = data.vehicleState?.remoteStartSupported ?? false
                isSteeringWheelHeaterOn = data.climateState?.steeringWheelHeater ?? false
                if data.vehicleState?.driverWindowOpen ?? false || data.vehicleState?.driverWindowOpen ?? false || data.vehicleState?.driverWindowOpen ?? false || data.vehicleState?.driverWindowOpen ?? false {
                    isWindowOpen = true
                }
                driverTemp = (data.climateState?.driverTemperatureSetting?.fahrenheit ?? 0)
                passengerTemp = (data.climateState?.passengerTemperatureSetting?.fahrenheit ?? 0)
                
                print("isLocked: \(isLocked), isPortOpen: \(isPortOpen), isClimateOn: \(isClimateOn), isRemoteStartEnabled: \(isRemoteStartEnabled)")
                
            case .failure(let err):
                print("Error getting car data: \(err.localizedDescription)")
            }
        }
    }
    
    func sendCommand(commandName: VehicleCommand, successMessage: String, failMessage: String) {
        isLoading = true
        api.sendCommandToVehicle(car, command: commandName) { (response: Result<CommandResponse, Error>) in
            isLoading = false
            switch response {
            case .success(let resp):
                if resp.result ?? false {
                    print("Command Success: \(commandName)")
                    popupMessage = successMessage
                    showSuccessPopup = true
                    
                    switch commandName {
                    case .lockDoors:
                        isLocked = true
                    case .unlockDoors:
                        isLocked = false
                    case .openChargeDoor:
                        isPortOpen = true
                    case .closeChargeDoor:
                        isPortOpen = false
                    case .windowControl(state: .close):
                        isWindowOpen = false
                    case .windowControl(state: .vent):
                        isWindowOpen = true
                    default:
                        print("No variabled to toggle with \(commandName)")
                    }
                } else {
                    print("Command Failed: \(commandName), \(resp.reason ?? "")")
                    popupMessage = failMessage
                    showFailPopup = true
                }
            case .failure(let err):
                print("Command Error: \(commandName), \(err.localizedDescription)")
                popupMessage = failMessage
                showFailPopup = true
            }
        }
    }
    
    func setTemp() {
        isLoading = true
        api.sendCommandToVehicle(car, command: .setTemperature(driverTemperature: driverTemp, passengerTemperature: passengerTemp)) { (response: Result<CommandResponse, Error>) in
            isLoading = false
            switch response {
            case .success(let resp):
                if resp.result ?? false {
                    print("Successfully changed temps")
                    showSuccessPopup = true
                    popupMessage = "Changed temperature"
                } else {
                    print("Couldnt change temp")
                    showFailPopup = true
                    popupMessage = "Couldn't change temperature"
                }
            case .failure(let err):
                print("Error changing temp: \(err.localizedDescription)")
                showFailPopup = true
                popupMessage = "Couldn't change temperature"
            }
        }
    }
    
    func remoteStart() {
        print("Attempting remote start!")
        isLoading = true
         api.sendCommandToVehicle(car, command: .startVehicle(password: userPassword)) { (response: Result<CommandResponse, Error>) in
         isLoading = false
            switch response {
            case .success(let resp):
                if resp.result == true {
                    print("Remote start succesfull!")
                    showSuccessPopup = true
                    popupMessage = "Started car"
                } else {
                    print("Remote start failed: \(resp.reason ?? "")")
                    showFailPopup = true
                    popupMessage = "Couldn't start car"
                }
            case .failure(let err):
                print("Error starting car: \(err.localizedDescription)")
                showFailPopup = true
                popupMessage = "Couldn't start car"
            }
        }
    }
    
}



struct CommandButton: View {
    var imageName: String
    var title: String
    var command: (VehicleCommand, String, String) -> Void
    var height: CGFloat? = 85
    var commandName: VehicleCommand
    var successMessage: String
    var failMessage: String
     
    var body: some View {
        Button(action: {
            print("Trying \(title)")
            command(commandName, successMessage, failMessage)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "\(imageName)").imageScale(.large)
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }.frame(maxWidth: .infinity, maxHeight: height, alignment: .leading)
        }
        .padding(.horizontal)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: height)
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}

//struct ControlsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ControlsView()
//    }
//}
