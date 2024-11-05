import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            Text("Loading...")
                .foregroundColor(.gray)
                .padding(.top)
        }
    }
}