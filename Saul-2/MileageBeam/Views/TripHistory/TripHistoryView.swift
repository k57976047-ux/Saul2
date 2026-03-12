import SwiftUI

struct TripHistoryView: View {
    @State private var trips: [TripRecord] = sampleTrips
    @State private var selectedFilter: TripFilter = .all
    @State private var showAddTrip = false
    
    var filteredTrips: [TripRecord] {
        switch selectedFilter {
        case .all:
            return trips
        case .car:
            return trips.filter { $0.vehicleType == "Car" }
        case .motorcycle:
            return trips.filter { $0.vehicleType == "Motorcycle" }
        case .thisMonth:
            return trips.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
        }
    }
    
    var totalDistance: Double {
        filteredTrips.reduce(0) { $0 + $1.distance }
    }
    
    var totalFuelUsed: Double {
        filteredTrips.reduce(0) { $0 + $1.fuelConsumed }
    }
    
    var averageConsumption: Double {
        guard totalDistance > 0 else { return 0 }
        return (totalFuelUsed / totalDistance) * 100
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    statisticsHeader
                    filterSection
                    tripsList
                }
            }
            .navigationTitle("Trip History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTrip = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(ZephyrColorScheme.titleZephyr)
                    }
                }
            }
            .sheet(isPresented: $showAddTrip) {
                AddTripView(onSave: { newTrip in
                    trips.append(newTrip)
                    trips.sort { $0.date > $1.date }
                })
            }
        }
    }
    
    private var statisticsHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 30) {
                StatisticCard(
                    title: "Total Distance",
                    value: String(format: "%.0f km", totalDistance),
                    icon: "road.lanes"
                )
                
                StatisticCard(
                    title: "Fuel Used",
                    value: String(format: "%.1f L", totalFuelUsed),
                    icon: "fuelpump.fill"
                )
            }
            
            StatisticCard(
                title: "Average Consumption",
                value: String(format: "%.2f L/100km", averageConsumption),
                icon: "chart.line.uptrend.xyaxis",
                isLarge: true
            )
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "All", isSelected: selectedFilter == .all) {
                    selectedFilter = .all
                }
                FilterChip(title: "Car", isSelected: selectedFilter == .car) {
                    selectedFilter = .car
                }
                FilterChip(title: "Motorcycle", isSelected: selectedFilter == .motorcycle) {
                    selectedFilter = .motorcycle
                }
                FilterChip(title: "This Month", isSelected: selectedFilter == .thisMonth) {
                    selectedFilter = .thisMonth
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
    
    private var tripsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if filteredTrips.isEmpty {
                    EmptyStateView(
                        icon: "road.lanes",
                        title: "No Trips Recorded",
                        message: "Start tracking your trips to see your fuel consumption history"
                    )
                    .padding(.top, 100)
                } else {
                    ForEach(filteredTrips) { trip in
                        TripCard(trip: trip)
                    }
                }
            }
            .padding()
        }
    }
}

enum TripFilter {
    case all, car, motorcycle, thisMonth
}

struct TripRecord: Identifiable {
    let id: UUID
    let date: Date
    let distance: Double
    let fuelConsumed: Double
    let vehicleType: String
    let route: String
    let notes: String?
    
    var consumptionPer100km: Double {
        guard distance > 0 else { return 0 }
        return (fuelConsumed / distance) * 100
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    var isLarge: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: isLarge ? 28 : 24))
                .foregroundColor(ZephyrColorScheme.titleZephyr)
            
            Text(value)
                .font(.system(size: isLarge ? 24 : 20, weight: .bold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            Text(title)
                .font(.system(size: isLarge ? 14 : 12))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .black : ZephyrColorScheme.primaryTextZephyr)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(20)
        }
    }
}

struct TripCard: View {
    let trip: TripRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.route)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ZephyrColorScheme.titleZephyr)
                    
                    Text(trip.date, style: .date)
                        .font(.system(size: 14))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                }
                
                Spacer()
                
                Text(trip.vehicleType)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ZephyrColorScheme.categoryZephyr)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                    .cornerRadius(8)
            }
            
            HStack(spacing: 20) {
                TripMetric(icon: "road.lanes", value: "\(String(format: "%.0f", trip.distance)) km")
                TripMetric(icon: "fuelpump.fill", value: "\(String(format: "%.2f", trip.fuelConsumed)) L")
                TripMetric(icon: "chart.bar.fill", value: "\(String(format: "%.2f", trip.consumptionPer100km)) L/100km")
            }
            
            if let notes = trip.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 14))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.8))
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: ZephyrColorScheme.shadowZephyr, radius: 4, x: 0, y: 2)
    }
}

struct TripMetric: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(ZephyrColorScheme.titleZephyr)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
            
            Text(title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct AddTripView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (TripRecord) -> Void
    
    @State private var distance: String = ""
    @State private var fuelConsumed: String = ""
    @State private var vehicleType: String = "Car"
    @State private var route: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        vehicleTypeSelector
                        inputFields
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var vehicleTypeSelector: some View {
        HStack(spacing: 16) {
            Button(action: { vehicleType = "Car" }) {
                Text("Car")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(vehicleType == "Car" ? .black : ZephyrColorScheme.primaryTextZephyr)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vehicleType == "Car" ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                    .cornerRadius(12)
            }
            
            Button(action: { vehicleType = "Motorcycle" }) {
                Text("Motorcycle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(vehicleType == "Motorcycle" ? .black : ZephyrColorScheme.primaryTextZephyr)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vehicleType == "Motorcycle" ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                    .cornerRadius(12)
            }
        }
    }
    
    private var inputFields: some View {
        VStack(spacing: 20) {
            TextField("Route (e.g., Home to Work)", text: $route)
                .textFieldStyle(CustomTextFieldStyle())
            
            TextField("Distance (km)", text: $distance)
                .keyboardType(.decimalPad)
                .textFieldStyle(CustomTextFieldStyle())
            
            TextField("Fuel Consumed (liters)", text: $fuelConsumed)
                .keyboardType(.decimalPad)
                .textFieldStyle(CustomTextFieldStyle())
            
            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
    
    private var saveButton: some View {
        Button(action: saveTrip) {
            Text("Save Trip")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ZephyrColorScheme.buttonZephyr)
                .cornerRadius(16)
        }
        .disabled(!isValidInput)
        .opacity(isValidInput ? 1.0 : 0.6)
    }
    
    private var isValidInput: Bool {
        !route.isEmpty &&
        Double(distance) != nil && Double(distance)! > 0 &&
        Double(fuelConsumed) != nil && Double(fuelConsumed)! > 0
    }
    
    private func saveTrip() {
        guard let distanceValue = Double(distance),
              let fuelValue = Double(fuelConsumed) else { return }
        
        let trip = TripRecord(
            id: UUID(),
            date: Date(),
            distance: distanceValue,
            fuelConsumed: fuelValue,
            vehicleType: vehicleType,
            route: route,
            notes: notes.isEmpty ? nil : notes
        )
        
        onSave(trip)
        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
            .cornerRadius(12)
            .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
    }
}

let sampleTrips: [TripRecord] = [
    TripRecord(id: UUID(), date: Date().addingTimeInterval(-86400), distance: 45.5, fuelConsumed: 4.2, vehicleType: "Car", route: "Home to Office", notes: "Heavy traffic"),
    TripRecord(id: UUID(), date: Date().addingTimeInterval(-172800), distance: 120.0, fuelConsumed: 8.5, vehicleType: "Car", route: "City to Beach", notes: nil),
    TripRecord(id: UUID(), date: Date().addingTimeInterval(-259200), distance: 25.0, fuelConsumed: 2.1, vehicleType: "Motorcycle", route: "Local Ride", notes: "Perfect weather")
]

