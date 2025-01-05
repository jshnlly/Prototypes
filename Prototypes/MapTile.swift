//
//  MapTile.swift
//  Prototypes
//
//  Created by Josh Nelson on 1/3/25.
//

import SwiftUI
import MapKit
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MapRegion: Equatable {
    var center: CLLocationCoordinate2D
    var span: MKCoordinateSpan
    
    static func == (lhs: MapRegion, rhs: MapRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude &&
        lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
        lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var region = MapRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.activityType = .other
        manager.allowsBackgroundLocationUpdates = false
        manager.pausesLocationUpdatesAutomatically = false
        manager.headingOrientation = .portrait
        
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        case .denied, .restricted:
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.region = MapRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        objectWillChange.send()
    }
}

struct CustomUserAnnotation: View {
    var body: some View {
        Image("pin")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 44, height: 44)
            .scaleEffect(3)
    }
}

struct MapTile: View {
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            
            VStack {
                ZStack {
                    ZStack {
                        Map(position: $position) {
                            if let location = locationManager.userLocation {
                                Annotation("", coordinate: location) {
                                    CustomUserAnnotation()
                                }
                            }
                        }
                        .mapStyle(.standard)
                        .mapControls {
                            MapUserLocationButton()
                            MapCompass()
                            MapScaleView()
                        }
                        .allowsHitTesting(false)
                        .onChange(of: locationManager.userLocation) { oldLocation, newLocation in
                            if let location = newLocation {
                                position = .userLocation(followsHeading: true, fallback: .region(MKCoordinateRegion(
                                    center: location,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )))
                            }
                        }
                        .onAppear {
                            if let location = locationManager.userLocation {
                                position = .userLocation(followsHeading: true, fallback: .region(MKCoordinateRegion(
                                    center: location,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )))
                            }
                        }
                        .mask {
                            Image("maskshape")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        
                        Image("maskshape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.01)
                        
                    }
                    
                    Image("profilepic")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    
                }
                .frame(width: UIScreen.main.bounds.width - 96)
                
                HStack {
                    HStack {
                        Text("@jnelly2")
                            .fontWeight(.semibold)
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(100)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .foregroundStyle(Color.blue)
                        Text("Ann Arbor")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.primary.opacity(1))
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(100)
                    
                    HStack {
                        Image(systemName: "qrcode")
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(100)
                }
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    MapTile()
}
