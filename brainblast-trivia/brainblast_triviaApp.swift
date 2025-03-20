import SwiftUI
import CloudKit

@main
struct brainblast_triviaApp: App {
    @StateObject private var cloudKit = CloudKitManager.shared
    
    var body: some Scene {
        WindowGroup {
            if cloudKit.isAuthenticated {
                ContentView()
                    .environmentObject(cloudKit)
            } else {
                LoginView()
                    .environmentObject(cloudKit)
            }
        }
    }
}
