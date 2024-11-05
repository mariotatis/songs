import SwiftUI

struct SongRowView: View {
    @EnvironmentObject var songStore: SongStore
    let song: Song
    
    var body: some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: song.pictureUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 80, height: 80)
            .clipped()
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                Text(song.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    songStore.toggleFavorite(song)
                }) {
                    Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(song.isFavorite ? .red : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    songStore.playPreview(song: song)
                }) {
                    Image(systemName: songStore.currentlyPlayingSongId == song.id ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 30))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.trailing, 16)
        }
        .frame(height: 80)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}