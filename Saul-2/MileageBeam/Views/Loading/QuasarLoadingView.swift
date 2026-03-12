import SwiftUI

struct StreamLoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            ZephyrColorScheme.gradientBackgroundZephyr
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "fuelpump.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ZephyrColorScheme.titleZephyr)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotationAngle)
                
                Text("MileageBeam")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            }
        }
        .onAppear {
            rotationAngle = 360
        }
    }
}

