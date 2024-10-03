import SwiftUI

@main
struct CurrencyConverterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: .init(initialState: .init(), reducer: {
                CurrencyConverter()
            }))
        }
    }
}
