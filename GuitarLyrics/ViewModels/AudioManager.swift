import Foundation
import AVFoundation

class AudioManager {
    private var audioPlayer: AVPlayer?
    private(set) var isPlaying = false
    var onPlayingStateChanged: ((Bool) -> Void)?
    
    func playPreview(url: String) {
        stopPreview()
        
        guard let url = URL(string: url) else { return }
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.play()
        isPlaying = true
        onPlayingStateChanged?(true)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    func stopPreview() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
        onPlayingStateChanged?(false)
    }
    
    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        onPlayingStateChanged?(false)
    }
}