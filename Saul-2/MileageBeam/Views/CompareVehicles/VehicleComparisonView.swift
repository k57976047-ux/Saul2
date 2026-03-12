import SwiftUI

struct VehicleComparisonView: View {
    @State private var vehicle1: VehicleSpec = VehicleSpec(name: "Car", consumption: 7.5, fuelType: "Gasoline")
    @State private var vehicle2: VehicleSpec = VehicleSpec(name: "Motorcycle", consumption: 4.2, fuelType: "Gasoline")
    @State private var annualDistance: String = "15000"
    @State private var fuelPrice: String = "1.50"
    
    var comparisonResult: ComparisonResult {
        calculateComparison()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        inputSection
                        comparisonResults
                        savingsBreakdown
                    }
                    .padding()
                }
            }
            .navigationTitle("Vehicle Comparison")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 20) {
            Text("Annual Distance (km)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            TextField("15000", text: $annualDistance)
                .keyboardType(.numberPad)
                .textFieldStyle(CustomTextFieldStyle())
            
            Text("Fuel Price per Liter ($)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            TextField("1.50", text: $fuelPrice)
                .keyboardType(.decimalPad)
                .textFieldStyle(CustomTextFieldStyle())
            
            vehicleSpecSection(title: "Vehicle 1", spec: $vehicle1)
            vehicleSpecSection(title: "Vehicle 2", spec: $vehicle2)
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
    
    private func vehicleSpecSection(title: String, spec: Binding<VehicleSpec>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.titleZephyr)
            
            TextField("Vehicle Name", text: spec.name)
                .textFieldStyle(CustomTextFieldStyle())
            
            HStack {
                Text("Consumption:")
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                TextField("L/100km", value: spec.consumption, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(CustomTextFieldStyle())
            }
        }
    }
    
    private var comparisonResults: some View {
        VStack(spacing: 16) {
            ComparisonCard(
                title: "Annual Fuel Cost",
                vehicle1Value: String(format: "$%.2f", comparisonResult.vehicle1AnnualCost),
                vehicle2Value: String(format: "$%.2f", comparisonResult.vehicle2AnnualCost),
                winner: comparisonResult.vehicle1AnnualCost < comparisonResult.vehicle2AnnualCost ? 1 : 2
            )
            
            ComparisonCard(
                title: "Annual Fuel Used",
                vehicle1Value: String(format: "%.1f L", comparisonResult.vehicle1FuelUsed),
                vehicle2Value: String(format: "%.1f L", comparisonResult.vehicle2FuelUsed),
                winner: comparisonResult.vehicle1FuelUsed < comparisonResult.vehicle2FuelUsed ? 1 : 2
            )
            
            ComparisonCard(
                title: "CO2 Emissions",
                vehicle1Value: String(format: "%.1f kg", comparisonResult.vehicle1CO2),
                vehicle2Value: String(format: "%.1f kg", comparisonResult.vehicle2CO2),
                winner: comparisonResult.vehicle1CO2 < comparisonResult.vehicle2CO2 ? 1 : 2
            )
        }
    }
    
    private var savingsBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Savings Breakdown")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            let savings = abs(comparisonResult.vehicle1AnnualCost - comparisonResult.vehicle2AnnualCost)
            let moreEfficient = comparisonResult.vehicle1AnnualCost < comparisonResult.vehicle2AnnualCost ? vehicle1.name : vehicle2.name
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(ZephyrColorScheme.selectedFilterZephyr)
                    Text("More Efficient: \(moreEfficient)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(ZephyrColorScheme.titleZephyr)
                    VStack(alignment: .leading) {
                        Text("Annual Savings")
                            .font(.system(size: 14))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                        Text("$\(String(format: "%.2f", savings))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                    }
                }
                
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(ZephyrColorScheme.categoryZephyr)
                    VStack(alignment: .leading) {
                        Text("CO2 Saved")
                            .font(.system(size: 14))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                        Text("\(String(format: "%.1f", abs(comparisonResult.vehicle1CO2 - comparisonResult.vehicle2CO2))) kg")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                    }
                }
            }
            .padding()
            .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
            .cornerRadius(16)
        }
    }
    
    private func calculateComparison() -> ComparisonResult {
        guard let distance = Double(annualDistance),
              let price = Double(fuelPrice),
              distance > 0, price > 0 else {
            return ComparisonResult(vehicle1AnnualCost: 0, vehicle2AnnualCost: 0, vehicle1FuelUsed: 0, vehicle2FuelUsed: 0, vehicle1CO2: 0, vehicle2CO2: 0)
        }
        
        let fuel1 = (vehicle1.consumption / 100) * distance
        let fuel2 = (vehicle2.consumption / 100) * distance
        
        let cost1 = fuel1 * price
        let cost2 = fuel2 * price
        
        let co2PerLiter = 2.31
        let co2_1 = fuel1 * co2PerLiter
        let co2_2 = fuel2 * co2PerLiter
        
        return ComparisonResult(
            vehicle1AnnualCost: cost1,
            vehicle2AnnualCost: cost2,
            vehicle1FuelUsed: fuel1,
            vehicle2FuelUsed: fuel2,
            vehicle1CO2: co2_1,
            vehicle2CO2: co2_2
        )
    }
}

struct VehicleSpec {
    var name: String
    var consumption: Double
    var fuelType: String
}

struct ComparisonResult {
    let vehicle1AnnualCost: Double
    let vehicle2AnnualCost: Double
    let vehicle1FuelUsed: Double
    let vehicle2FuelUsed: Double
    let vehicle1CO2: Double
    let vehicle2CO2: Double
}

struct ComparisonCard: View {
    let title: String
    let vehicle1Value: String
    let vehicle2Value: String
    let winner: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(vehicle1Value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(winner == 1 ? ZephyrColorScheme.selectedFilterZephyr : ZephyrColorScheme.primaryTextZephyr)
                    
                    if winner == 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ZephyrColorScheme.selectedFilterZephyr)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(winner == 1 ? ZephyrColorScheme.selectedFilterZephyr.opacity(0.2) : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(12)
                
                VStack(spacing: 8) {
                    Text(vehicle2Value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(winner == 2 ? ZephyrColorScheme.selectedFilterZephyr : ZephyrColorScheme.primaryTextZephyr)
                    
                    if winner == 2 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ZephyrColorScheme.selectedFilterZephyr)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(winner == 2 ? ZephyrColorScheme.selectedFilterZephyr.opacity(0.2) : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
}

