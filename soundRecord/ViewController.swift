//
//  secViewController.swift
//  soundRecord
//
//  Created by Alexey Savchenko on 10.01.17.
//  Copyright © 2017 Alexey Savchenko. All rights reserved.
//

import UIKit
import AVFoundation



class ViewController: UIViewController, EZAudioPlayerDelegate {
  
  
  //MARK: Properities
  var microphone = EZMicrophone()
  var player = EZAudioPlayer()
  var recorder = AKAudioRecorder("demo")
  
		
  //MARK: Outlets
  @IBOutlet weak var recButton: UIButton!
  @IBOutlet weak var playAudioPlot: EZAudioPlot!
  @IBOutlet weak var playButton: UIButton!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    playButton.isEnabled = false
    
    do{
      let session = AVAudioSession.sharedInstance()
      try session.setCategory("AVAudioSessionCategoryPlayAndRecord")
      try session.setActive(true)
      
      self.playAudioPlot.color = UIColor.orange
      self.playAudioPlot.shouldMirror = true
      self.playAudioPlot.shouldFill = true
      self.playAudioPlot.plotType = .rolling
      self.playAudioPlot.gain = 6.0
      
      self.player = EZAudioPlayer(delegate: self)
      
      try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
      
    } catch {
      print(error.localizedDescription)
    }
  }
  
  //MARK: Playback implementation
  
  @IBAction func play(_ sender: UIButton) {
    
    playButton.isEnabled = false
    
    self.playAudioPlot.clear()
    
    let audiofile = EZAudioFile(url: ViewController.URLforRecord())
    
    self.player.playAudioFile(audiofile)
    
  }
  
  //MARK: Recording implementation
  
  @IBAction func record(_ sender: UIButton) {
    
    if recButton.titleLabel?.text == "Record"{
      playButton.isEnabled = false
      
      recButton.setTitle("Stop", for: .normal)
      recorder.record()
      
    } else {
      
      playButton.isEnabled = true
      
      recButton.setTitle("Record", for: .normal)
      recorder.stop()
    }
    
  }
  
  
  //MARK: EZAudioPlayer delegate methods
  
  func audioPlayer(_ audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, in audioFile: EZAudioFile!) {
    DispatchQueue.main.async {
      self.playAudioPlot.updateBuffer(buffer.pointee, withBufferSize: bufferSize)
      print(buffer.pointee?.pointee.binade)
    }
  }
  
  func audioPlayer(_ audioPlayer: EZAudioPlayer!, reachedEndOf audioFile: EZAudioFile!) {
    if playButton.isEnabled == false {
      playButton.isEnabled = true
    }
  }
  
  
  //MARK: Utility
  
  static func URLforRecord() -> URL{
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory = urls[0] as NSURL
    let soundURL = documentDirectory.appendingPathComponent("demo")
    
    return soundURL!
  }
}
