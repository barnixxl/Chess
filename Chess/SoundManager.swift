import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioSession()
        loadSounds()
        playBackgroundMusic()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func loadSounds() {
        let soundFiles = [
            "move": "MoveChess",
            "capture": "LoseChes",
            "win": "WinGame",
            "lose": "LoseGame",
            "button": "ClickButton"
        ]
        
        for (key, filename) in soundFiles {
            if let path = findSoundPath(for: filename) {
                do {
                    let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    player.prepareToPlay()
                    soundEffectPlayers[key] = player
                    print("✅ Successfully loaded sound: \(filename)")
                } catch {
                    print("❌ Failed to load sound \(filename): \(error)")
                }
            } else {
                 print("⚠️ Sound file not found: \(filename)")
            }
        }
        
        // Load background music
        if let path = findSoundPath(for: "FonMusic") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
                backgroundMusicPlayer?.volume = Storage.shared.backgroundMusicVolume
                backgroundMusicPlayer?.prepareToPlay()
                print("✅ Successfully loaded background music")
            } catch {
                print("❌ Failed to load background music: \(error)")
            }
        } else {
            print("⚠️ Background music file 'FonMusic' not found")
        }
    }
    
    private func findSoundPath(for filename: String) -> String? {
        // 1. Try root of bundle
        if let path = Bundle.main.path(forResource: filename, ofType: "mp3") {
            return path
        }
        
        // 2. Try "Sounds" subdirectory (if folder reference)
        if let path = Bundle.main.path(forResource: filename, ofType: "mp3", inDirectory: "Sounds") {
            return path
        }
        
        return nil
    }
    
    // MARK: - Background Music
    
    func playBackgroundMusic() {
        backgroundMusicPlayer?.volume = Storage.shared.backgroundMusicVolume
        backgroundMusicPlayer?.play()
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func setBackgroundMusicVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = volume
    }
    
    // MARK: - Sound Effects
    
    func playMoveSound() {
        guard Storage.shared.isMoveSoundEnabled else { return }
        soundEffectPlayers["move"]?.play()
    }
    
    func playCaptureSound() {
        guard Storage.shared.isCaptureSoundEnabled else { return }
        soundEffectPlayers["capture"]?.play()
    }
    
    func playWinSound() {
        guard Storage.shared.isWinSoundEnabled else { return }
        soundEffectPlayers["win"]?.play()
    }
    
    func playLoseSound() {
        guard Storage.shared.isLoseSoundEnabled else { return }
        soundEffectPlayers["lose"]?.play()
    }
    
    func playButtonSound() {
        guard Storage.shared.isKeySoundEnabled else { return }
        soundEffectPlayers["button"]?.play()
    }
}
