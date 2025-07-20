import SwiftUI

@main
struct EthereumPriceChartApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                PriceChartView()
                    .navigationTitle("Ethereum Price")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
            }
        }
    }
}
