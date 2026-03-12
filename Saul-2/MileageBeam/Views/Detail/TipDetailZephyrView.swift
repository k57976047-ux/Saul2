import SwiftUI

struct TipDetailZephyrView: View {
    let tipId: UUID
    @StateObject private var viewModel: EdgeTipDetailSparkViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isVisibleZephyr = false
    
    init(tipId: UUID) {
        self.tipId = tipId
        _viewModel = StateObject(wrappedValue: EdgeTipDetailSparkViewModel(dataRepository: BoltFuelTipRepository(), tipIdentifier: tipId))
    }
    
    var body: some View {
        ZStack {
            ZephyrColorScheme.gradientBackgroundZephyr
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let tip = viewModel.currentTip {
                        Text(tip.headerTitle)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(ZephyrColorScheme.titleZephyr)
                            .offset(y: isVisibleZephyr ? 0 : 20)
                            .opacity(isVisibleZephyr ? 1.0 : 0.0)
                        
                        Text(tip.contextScenario)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(ZephyrColorScheme.categoryZephyr)
                            .offset(y: isVisibleZephyr ? 0 : 20)
                            .opacity(isVisibleZephyr ? 1.0 : 0.0)
                        
                        Text(tip.contentDescription)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                            .lineSpacing(4)
                            .offset(y: isVisibleZephyr ? 0 : 20)
                            .opacity(isVisibleZephyr ? 1.0 : 0.0)
                        
                        Button(action: {
                            viewModel.toggleFavoriteStatus()
                        }) {
                            HStack {
                                Image(systemName: viewModel.currentTip?.favoriteStatus == true ? "heart.fill" : "heart")
                                    .font(.system(size: 20))
                                Text(viewModel.currentTip?.favoriteStatus == true ? "Remove from Favorites" : "Add to Favorites")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(viewModel.currentTip?.favoriteStatus == true ? ZephyrColorScheme.selectedFilterZephyr : ZephyrColorScheme.buttonZephyr)
                            .cornerRadius(16)
                            .shadow(color: ZephyrColorScheme.shadowZephyr, radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 20)
                        .offset(y: isVisibleZephyr ? 0 : 20)
                        .opacity(isVisibleZephyr ? 1.0 : 0.0)
                    }
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundColor(ZephyrColorScheme.titleZephyr)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisibleZephyr = true
            }
        }
    }
}



