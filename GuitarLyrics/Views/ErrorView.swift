import SwiftUI

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(error)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}