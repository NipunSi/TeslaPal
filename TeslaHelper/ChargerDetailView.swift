//
//  ChargerDetailView.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/24/20.
//

import SwiftUI
import TeslaSwift
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct ChargerDetailView: View {
    
    var charger: NearbyChargingSites.Supercharger
    @State private  var locations: [Location] = []
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    var body: some View {
        VStack(spacing: 5) {
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapAnnotation(
                    coordinate: location.coordinate,
                    anchorPoint: CGPoint(x: 0.5, y: 0.5)
                ) {
                    Text("Charger")
                    Circle()
                        .fill(Color.green)
                        .frame(width: 15, height: 15)
                }
            }
            .frame(height: 250)

            Text(charger.name ?? "")
                .font(.title)
                .layoutPriority(2)
            Text("\(charger.availableStalls ?? 0) / \(charger.totalStalls ?? 0) stalls available")
                .font(.headline)
            Text("\(charger.distance?.miles ?? 0, specifier: "%.1f") mi away")
                .font(.headline)
            
            Button(action: {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: charger.location?.latitude ?? 0, longitude: charger.location?.longitude ?? 0)))
                destination.name = "\(charger.name ?? "Charger")"
                
                MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            }) {
                HStack {
                    Image(systemName: "map").imageScale(.large)
                    Text("Get Directions")
                        .font(.headline)
                }
            }
            
            if charger.siteClosed == true {
                Text("This site is currently closed")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            //}
            Spacer()
        }.onAppear(perform: setCoords)
    }
    
    func setCoords() {
        let chargerLat = charger.location?.latitude
        let chargerLon = charger.location?.longitude
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: chargerLat ?? 0, longitude: chargerLon ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
        let chargerLocation = Location(coordinate: .init(latitude: chargerLat ?? 0, longitude: chargerLon ?? 0))
        locations.append(chargerLocation)
    }
}

//struct ChargerDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChargerDetailView()
//    }
//}
