import SwiftUI

struct FuelSavingsCalculatorView: View {
    @State private var currentFuelConsumption: String = ""
    @State private var distancePerMonth: String = ""
    @State private var fuelPrice: String = ""
    @State private var selectedVehicleType: String = "Car"
    
    private var calculatedSavings: Double {
        guard let consumption = Double(currentFuelConsumption),
              let distance = Double(distancePerMonth),
              let price = Double(fuelPrice),
              consumption > 0, distance > 0, price > 0 else {
            return 0
        }
        
        let currentCost = (consumption / 100) * distance * price
        let optimizedConsumption = consumption * 0.85
        let optimizedCost = (optimizedConsumption / 100) * distance * price
        return currentCost - optimizedCost
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        vehicleTypeSelector
                        inputFieldsSection
                        resultsSection
                        tipsPreviewSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Fuel Savings Calculator")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var vehicleTypeSelector: some View {
        HStack(spacing: 16) {
            VehicleTypeButton(
                title: "Car",
                icon: "car.fill",
                isSelected: selectedVehicleType == "Car",
                action: { selectedVehicleType = "Car" }
            )
            
            VehicleTypeButton(
                title: "Motorcycle",
                icon: "bicycle",
                isSelected: selectedVehicleType == "Motorcycle",
                action: { selectedVehicleType = "Motorcycle" }
            )
        }
    }
    
    private var inputFieldsSection: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Current Fuel Consumption",
                placeholder: "Liters per 100 km",
                text: $currentFuelConsumption,
                icon: "fuelpump.fill"
            )
            
            InputField(
                title: "Monthly Distance",
                placeholder: "Kilometers per month",
                text: $distancePerMonth,
                icon: "road.lanes"
            )
            
            InputField(
                title: "Fuel Price",
                placeholder: "Price per liter",
                text: $fuelPrice,
                icon: "dollarsign.circle.fill"
            )
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var resultsSection: some View {
        VStack(spacing: 16) {
            Text("Potential Monthly Savings")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            Text("$\(String(format: "%.2f", calculatedSavings))")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(ZephyrColorScheme.titleZephyr)
            
            Text("Annual savings: $\(String(format: "%.2f", calculatedSavings * 12))")
                .font(.system(size: 16))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.9))
        .cornerRadius(20)
    }
    
    private var tipsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Tips to Achieve Savings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            TipRow(icon: "speedometer", text: "Maintain optimal speed (90-110 km/h)")
            TipRow(icon: "tirepressure", text: "Check tire pressure regularly")
            TipRow(icon: "wind", text: "Remove roof racks when not needed")
            TipRow(icon: "gearshift", text: "Use higher gears efficiently")
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
}

struct VehicleTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(isSelected ? .black : ZephyrColorScheme.primaryTextZephyr)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(isSelected ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
            .cornerRadius(16)
        }
    }
}

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(ZephyrColorScheme.titleZephyr)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            }
            
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(ZephyrColorScheme.titleZephyr)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

