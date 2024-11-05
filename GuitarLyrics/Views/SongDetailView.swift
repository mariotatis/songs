import SwiftUI

struct SongDetailView: View {
    let song: Song
    @State private var lyrics: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingDeleteAlert = false
    @EnvironmentObject var songStore: SongStore
    @Environment(\.dismiss) var dismiss
    
    var formattedLyrics: String {
        // Remove excessive line breaks and normalize spacing
        let cleanedLyrics = lyrics
            .replacingOccurrences(of: "\r\n", with: "\n")  // Convert Windows line endings
            .replacingOccurrences(of: "\r", with: "\n")    // Convert old Mac line endings
            .components(separatedBy: .newlines)            // Split into lines
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } // Remove empty lines
            .joined(separator: "\n")                       // Join with single line breaks
        
        return cleanedLyrics
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Header
                ZStack(alignment: .bottom) {
                    // Image
                    AsyncImage(url: URL(string: song.pictureUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(height: 300)
                    .clipped()
                    
                    // Gradient Overlay
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Song Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(song.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(song.artist)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(song.formattedDuration)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        LoadingView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if let error = errorMessage {
                        ErrorView(error: error) {
                            loadLyrics()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        Text("Lyrics")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.top, 20)
                        
                        Text(formattedLyrics)
                            .font(.system(size: 18))
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Delete Song", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                songStore.removeSong(song)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this song?")
        }
        .task {
            loadLyrics()
        }
    }
    
    private func loadLyrics() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                lyrics = try await songStore.fetchLyrics(for: song)
                isLoading = false
            } catch let error as AppError {
                errorMessage = error.localizedDescription
                isLoading = false
            } catch {
                errorMessage = "An unexpected error occurred"
                isLoading = false
            }
        }
    }
}