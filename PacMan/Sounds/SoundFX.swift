//
//  SoundFX.swift
//  PacMan
//
//  Created by Jonathan French on 22.11.26.
//

import Foundation
import AVFoundation

// MARK: - Sound Types
private enum SoundType {
    case effect
    case background
    case music
    
    var volume: Float {
        switch self {
        case .effect: return GameConstants.Sound.effectsVolume
        case .background: return GameConstants.Sound.backgroundVolume
        case .music: return GameConstants.Sound.musicVolume
        }
    }
}

// MARK: - Sound Asset Names
private enum SoundAsset {
    static let beginning = "pacman_beginning"
    static let chomp = "pacman_chomp"
    static let death = "pacman_death"
    static let eatfruit = "pacman_eatfruit"
    static let eatghost = "pacman_eatghost"
    static let extrapac = "pacman_extrapac"
    static let intermission = "pacman_intermission"
}

final class SoundFX {
    // MARK: - Properties
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let audioExtension = "mp3"
    var musicOn = true
    var soundOn = true
    var hapticOn = true
    
    // MARK: - Initialization
    init() {
        setupAudioSession()
        loadSoundAssets()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func loadSoundAssets() {
        // Load effects
        loadSound(SoundAsset.beginning, type: .effect)
        loadSound(SoundAsset.chomp, type: .effect)
        loadSound(SoundAsset.death, type: .effect)
        loadSound(SoundAsset.eatfruit, type: .effect)
        loadSound(SoundAsset.eatghost, type: .effect)
        loadSound(SoundAsset.extrapac, type: .effect)
        loadSound(SoundAsset.intermission, type: .effect)

    }
    
    private func loadSound(_ name: String, type: SoundType) {
        guard let url = Bundle.main.url(forResource: name, withExtension: audioExtension) else {
            print("Failed to find sound file: \(name).\(audioExtension)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            player.volume = type.volume
            audioPlayers[name] = player
        } catch {
            print("Failed to load sound \(name): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Playback Control
    @objc private func play(audioPlayer: AVAudioPlayer) {
        guard soundOn else { return }
        audioPlayer.play()
    }
    
    private func playOnNewThread(_ name: String, loops: Int = 0) {
        guard soundOn else { return }
        guard let player = audioPlayers[name] else { return }
        player.numberOfLoops = loops
        Thread.detachNewThreadSelector(#selector(play), toTarget: self, with: player)
    }
    
    private func stop(_ name: String) {
        audioPlayers[name]?.stop()
    }
    
    // MARK: - Public Interface
    func startSound() { playOnNewThread(SoundAsset.beginning) }
    func chompSound() { playOnNewThread(SoundAsset.chomp) }
    func deathSound() { playOnNewThread(SoundAsset.death) }
    func fruitSound() { playOnNewThread(SoundAsset.eatfruit) }
    func ghostSound() { playOnNewThread(SoundAsset.eatghost) }
    func extraSound() { playOnNewThread(SoundAsset.extrapac) }
    func intermissionSound() { playOnNewThread(SoundAsset.intermission,loops: 1) }
    
}
