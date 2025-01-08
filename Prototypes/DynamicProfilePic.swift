//
//  MapTile.swift
//  Prototypes
//
//  Created by Josh Nelson on 1/3/25.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreMotion

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

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    private var initialPitch: Double?
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            self?.roll = motion.attitude.roll
            
            if self?.initialPitch == nil {
                self?.initialPitch = motion.attitude.pitch
            }
            
            if let initialPitch = self?.initialPitch {
                self?.pitch = motion.attitude.pitch - initialPitch
            }
        }
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
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
    @State private var flip = false
    @State private var rotationAngle = 0.0
    @State private var scale = 1.0
    @State private var pressedUsername = false
    @State private var pressedLocation = false
    @State private var pressedQR = false
    @State private var showQR = false
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            // Content container
            ZStack {
                // Profile side
                
                QRDesignView()
                    .opacity(showQR ? 1 : 0)
                
                Image("profilepic")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(rotationAngle < 90 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: rotationAngle)
                        .clipShape(RoundedRectangle(cornerRadius: showQR ? 72 : 200, style: .continuous))
                        .scaleEffect(showQR ? 0.22 : 1)
                
                // Map side
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
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(rotationAngle >= 90 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: rotationAngle)
            }
            .frame(width: UIScreen.main.bounds.width - 96)
            .frame(height: UIScreen.main.bounds.width - 96)
            .rotation3DEffect(
                .degrees(rotationAngle),
                axis: (x: 0, y: 1, z: 0)
            )
            .scaleEffect(scale)
            
            // Bottom pills in fixed position
            HStack {
                HStack {
                    Text("@jnelly2")
                        .fontWeight(.semibold)
                }
                .padding(10)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(100)
                .scaleEffect(pressedUsername ? 0.875 : 1)
                .onTapGesture {
                    haptic.impactOccurred()
                    withAnimation(.spring(duration: 0.3)) {
                        pressedUsername = true
                        showQR = false
                    }
                    
                    // Scale down container
                    withAnimation(.spring(duration: 0.18)) {
                        scale = 0.8
                    }
                    
                    // Show profile
                    if rotationAngle != 0 {
                        showQR = false
                        // Flip to profile
                        withAnimation(.spring(duration: 0.5)) {
                            rotationAngle = 0
                        }
                    }
                    
                    // Scale back up
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(duration: 0.25)) {
                            scale = 1.0
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(duration: 0.3)) {
                            pressedUsername = false
                        }
                    }
                }
                
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
                .scaleEffect(pressedLocation ? 0.875 : 1)
                .onTapGesture {
                    haptic.impactOccurred()
                    withAnimation(.spring(duration: 0.3)) {
                        pressedLocation = true
                        showQR = false
                    }
                    
                    // Scale down container
                    withAnimation(.spring(duration: 0.18)) {
                        scale = 0.8
                    }
                    
                    // Show map
                    if rotationAngle != 180 {
                        // Flip to map
                        withAnimation(.spring(duration: 0.5)) {
                            rotationAngle = 180
                        }
                    }
                    
                    // Scale back up
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(duration: 0.25)) {
                            scale = 1.0
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(duration: 0.3)) {
                            pressedLocation = false
                        }
                    }
                }
                
                HStack {
                    Image(systemName: "qrcode")
                }
                .padding(10)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(100)
                .scaleEffect(pressedQR ? 0.875 : 1)
                .onTapGesture {
                    haptic.impactOccurred()
                    withAnimation(.spring(duration: 0.3)) {
                        pressedQR = true
                        showQR = true
                    }
                    
                    // Scale down container
                    withAnimation(.spring(duration: 0.18)) {
                        scale = 0.8
                    }
                    
                    // Show QR code
                    if rotationAngle != 0 {
                        // Flip to profile side
                        withAnimation(.spring(duration: 0.5)) {
                            rotationAngle = 0
                        }
                    }
                    
                    // Scale back up
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(duration: 0.25)) {
                            scale = 1.0
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(duration: 0.3)) {
                            pressedQR = false
                        }
                    }
                }
            }
            .offset(y: 300)
        }
    }
}

struct QRDesignView: View {
    let containerSize: CGFloat = 280
    let padding: CGFloat = 24
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        ZStack {
            // White rectangle with shadow
            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 4)
                .rotation3DEffect(.radians(motionManager.roll * 0.2), axis: (x: 0, y: 1, z: 0))
                .rotation3DEffect(.radians(-motionManager.pitch * 0.2), axis: (x: 1, y: 0, z: 0))
            
            // Base grid of dots
            VStack(spacing: 4) {
                ForEach(0..<25) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<25) { col in
                            if isInPositionMarkerArea(row: row, col: col) {
                                Color.clear
                                    .frame(width: 6, height: 6)
                            } else {
                                Circle()
                                    .fill(.black)
                                    .frame(width: 6, height: 6)
                                    .opacity(Bool.random() ? 1 : 0)
                            }
                        }
                    }
                }
            }
            .padding(padding)
            .rotation3DEffect(.radians(motionManager.roll * 0.2), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.radians(-motionManager.pitch * 0.2), axis: (x: 1, y: 0, z: 0))
            
            // Position Markers
            ZStack {
                // Top-left
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.black)
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                            .frame(width: 34, height: 34)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(.black)
                            .frame(width: 18, height: 18)
                    )
                    .position(x: padding + 25, y: padding + 25)
                
                // Top-right
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.black)
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                            .frame(width: 34, height: 34)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(.black)
                            .frame(width: 18, height: 18)
                    )
                    .position(x: containerSize - padding - 25, y: padding + 25)
                
                // Bottom-left
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.black)
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                            .frame(width: 34, height: 34)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(.black)
                            .frame(width: 18, height: 18)
                    )
                    .position(x: padding + 25, y: containerSize - padding - 25)
            }
            .rotation3DEffect(.radians(motionManager.roll * 0.2), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.radians(-motionManager.pitch * 0.2), axis: (x: 1, y: 0, z: 0))
        }
        .frame(width: containerSize, height: containerSize)
    }
    
    private func isInPositionMarkerArea(row: Int, col: Int) -> Bool {
        // Top-left position marker
        if row < 7 && col < 7 {
            return true
        }
        
        // Top-right position marker
        if row < 7 && col >= 18 {
            return true
        }
        
        // Bottom-left position marker
        if row >= 18 && col < 7 {
            return true
        }
        
        // Center area for profile picture (larger area)
        let centerStart = 8
        let centerEnd = 16
        if row >= centerStart && row <= centerEnd && col >= centerStart && col <= centerEnd {
            return true
        }
        
        return false
    }
}

#Preview {
    MapTile()
}
