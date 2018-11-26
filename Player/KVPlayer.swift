//
//  KVPlayer.swift
//  VideoApp
//
//  Created by Vikash on 20/11/18.
//  Copyright © 2018 Vikash. All rights reserved.
//

import AVKit



class KVPlayer {
    
    var player: AVPlayer = AVPlayer()
    
    var timeObserver: Any?
    
    var isPlayManually = false
    var isPlayInLoop = false
    
    let playerQueue = DispatchQueue(label: "PlayerQueue")
    
    func playMedia(url: URL, progress: @escaping (Float) -> Void) {
        playerQueue.async { [weak self] in
            guard let self = self else { return }
            
            let item = AVPlayerItem(url: url)
                
            self.player.replaceCurrentItem(with: item)
            
            if self.timeObserver == nil {
                self.addPeriodicTimeObserver(block: progress)
            }
            
            if !self.isPlayManually {
                self.player.play()
            }
        }
    }
    
    
    
    func addPeriodicTimeObserver(block: @escaping (Float) -> Void) {
        // Invoke callback every half second
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
       
        // Queue on which to invoke the callback
        let queue = DispatchQueue.global()
        
        // Add time observer
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: queue) {
            [weak self] time in
            
            if let selff = self {
                
                if selff.player.currentItem?.status == .readyToPlay {
                    
                    let time : Float64 = CMTimeGetSeconds(selff.player.currentTime());
                    let duration = CMTimeGetSeconds(selff.player.currentItem!.asset.duration)
                    let progress = Float(time/duration)

                    DispatchQueue.main.async {
                        
                        block(progress)
                        
                        // finish playing
                        if progress >= 1 {
                            
                            // play in loop
                            if self?.isPlayInLoop == true {
                                self?.player.seek(to: .zero)
                                self?.player.play()
                            }
                            
                        }
                        
                    }
                }
            }
            
        }
    }
    
    
    func togglePlaying() {
        isPlaying ? self.pause() : self.play()
    }
    
    func play() {
        self.player.play()
    }
    
    func pause() {
        self.player.pause()
    }
    
    var isPlaying: Bool {
        return  player.rate > Float(0)
    }
    
}
