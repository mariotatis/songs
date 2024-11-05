import SwiftUI

@main
struct GuitarLyricsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SongStore())
        }
    }
}