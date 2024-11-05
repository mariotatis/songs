import SwiftUI

struct AddSongView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var songStore: SongStore
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var searchResults: [Song] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        TextField("Search songs...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button(action: {
                            Task {
                                isSearching = true
                                do {
                                    searchResults = try await songStore.fetchSongs(query: searchText)
                                } catch {
                                    print("Search error: \(error)")
                                }
                                isSearching = false
                            }
                        }) {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                    }
                    .padding(.vertical)
                    
                    if isSearching {
                        Spacer()
                        LoadingView()
                        Spacer()
                    } else {
                        List(searchResults) { song in
                            SearchResultRow(song: song, isPresented: $isPresented)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Add Song")
            .navigationBarItems(trailing: Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            })
        }
    }
}