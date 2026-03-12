import SwiftUI

struct OnboardingZephyrView: View {
    @ObservedObject var viewModel: PulseOnboardingMatrixViewModel
    @State private var showMainZephyr = false
    
    var body: some View {
        ZStack {
            ZephyrColorScheme.gradientBackgroundZephyr
                .ignoresSafeArea()
            
            TabView(selection: $viewModel.activePageIndex) {
                OnboardingPageZephyr(
                    title: "Welcome to MileageBeam",
                    subtitle: "Learn how to save fuel in every situation",
                    imageName: "car.fill",
                    pageIndex: 0
                )
                .tag(0)
                
                OnboardingPageZephyr(
                    title: "Choose your vehicle & conditions",
                    subtitle: "Select car or motorcycle and the driving scenario to get tips",
                    imageName: "figure.walk",
                    pageIndex: 1
                )
                .tag(1)
                
                OnboardingPageZephyr(
                    title: "Start saving fuel today!",
                    subtitle: "Apply tips for efficient driving and reduce fuel costs",
                    imageName: "fuelpump.fill",
                    pageIndex: 2,
                    isLast: true,
                    onComplete: {
                        viewModel.finalizeOnboardingFlow()
                        showMainZephyr = true
                    }
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .fullScreenCover(isPresented: $showMainZephyr) {
            MainZephyrView()
        }
    }
}

struct OnboardingPageZephyr: View {
    let title: String
    let subtitle: String
    let imageName: String
    let pageIndex: Int
    var isLast: Bool = false
    var onComplete: (() -> Void)? = nil
    
    @State private var isVisibleZephyr = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(ZephyrColorScheme.titleZephyr)
                .scaleEffect(isVisibleZephyr ? 1.0 : 0.5)
                .opacity(isVisibleZephyr ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isVisibleZephyr)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                    .multilineTextAlignment(.center)
                    .offset(y: isVisibleZephyr ? 0 : 30)
                    .opacity(isVisibleZephyr ? 1.0 : 0.0)
                
                Text(subtitle)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .offset(y: isVisibleZephyr ? 0 : 30)
                    .opacity(isVisibleZephyr ? 1.0 : 0.0)
            }
            .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2), value: isVisibleZephyr)
            
            Spacer()
            
            if isLast {
                Button(action: {
                    onComplete?()
                }) {
                    Text("Start")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ZephyrColorScheme.buttonZephyr)
                        .cornerRadius(16)
                        .shadow(color: ZephyrColorScheme.shadowZephyr, radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .scaleEffect(isVisibleZephyr ? 1.0 : 0.8)
                .opacity(isVisibleZephyr ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: isVisibleZephyr)
            }
        }
        .onAppear {
            isVisibleZephyr = true
        }
    }
}



