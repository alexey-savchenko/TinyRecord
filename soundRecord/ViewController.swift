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
  var recorder = AudioRecorder("demo")
  
  var tempStorageOfGraphData = [Float]()

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
      self.playAudioPlot.gain = 2.0
      
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
    
    //Reseting temporary storage before playback
    self.tempStorageOfGraphData = []
    
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
  
  func audioPlayer(_ audioPlayer: EZAudioPlayer!,
                   playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!,
                   withBufferSize bufferSize: UInt32,
                   withNumberOfChannels numberOfChannels: UInt32,
                   in audioFile: EZAudioFile!) {
    
    DispatchQueue.main.async {
      self.playAudioPlot.updateBuffer(buffer.pointee, withBufferSize: bufferSize)
      
      //Storing audiofile buffer values to temporary storage
      if let bufferValue = buffer.pointee?.pointee{
        self.tempStorageOfGraphData.append(bufferValue)
      }
    }
  }
  
  func audioPlayer(_ audioPlayer: EZAudioPlayer!,
                   reachedEndOf audioFile: EZAudioFile!) {
    DispatchQueue.main.async {
      if self.playButton.isEnabled == false {
        self.playButton.isEnabled = true
      }
      
      self.createJSONFile()
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
  
  func createJSONFile(){
    // create path to json file
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory = urls[0] as NSURL
    guard let jsonURL = documentDirectory.appendingPathComponent("graphData") else {
      print("Failed to create path to json file.")
      return
    }
  
    // creating a .json file in the Documents folder
    if !fileManager.fileExists(atPath: jsonURL.absoluteString){
      fileManager.createFile(atPath: jsonURL.absoluteString, contents: nil, attributes: nil)
      print("file created")
    }
    
    do {
      //Create JSON data varieble from array with graph values
      let jsonData = try JSONSerialization.data(withJSONObject: self.tempStorageOfGraphData, options: .prettyPrinted)
      print(jsonData)
      
      //Write JSON data to file created
      try jsonData.write(to: jsonURL)
      
      
      let content = try String.init(contentsOf: jsonURL, encoding: .utf8)
      print(content)
      
    } catch {
      print(error.localizedDescription)
    }
  }
}
