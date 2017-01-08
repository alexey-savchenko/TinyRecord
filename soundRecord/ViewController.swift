//
//  ViewController.swift
//  soundRecord
//
//  Created by Alexey Savchenko on 05.01.17.
//  Copyright © 2017 Alexey Savchenko. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
  
  @IBOutlet weak var audioPlot: EZAudioPlot!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var recordButton: UIButton!
  
  let fileName = "recordedFile"
  var recorder = AKAudioRecorder("recordedFile")

  
  var count = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  @IBAction func record(_ sender: UIButton) {
    count += 1
    recorder.record()
    check()
  }
  
  func check(){
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory = urls[0] as NSURL
    let soundURL = documentDirectory.appendingPathComponent(fileName)?.path
    
    if fileManager.fileExists(atPath: soundURL!){
      print("file exists: \(soundURL)")
    } else {
      print("file does not exist")
    }
  }
  
  @IBAction func stop(_ sender: UIButton) {
    recorder.stop()
  }
  @IBAction func play(_ sender: UIButton) {
    
    do{
      let fileManager = FileManager.default
      let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
      let documentDirectory = urls[0] as NSURL
      let soundURL = documentDirectory.appendingPathComponent(fileName)
      
      let tempPlayer = try AKAudioPlayer(file: try AKAudioFile(forReading: soundURL!))
      
      AudioKit.output = tempPlayer
      AudioKit.start()
      
      tempPlayer.play()
      
      let plot = AKNodeOutputPlot(tempPlayer, frame: audioPlot.bounds)
      plot.plotType = .buffer
      plot.shouldFill = true
      plot.shouldMirror = true
      plot.color = UIColor.blue
      audioPlot.addSubview(plot)
      
      
      
      if tempPlayer.isStarted {
        print("Player started playing")
      }
      if tempPlayer.isPlaying{
        print("PLaying sound")
      }
      
      if tempPlayer.isStopped{
        print("Player stopped")
      }
      
    } catch {
      print(error.localizedDescription)
    }
    
    
//    if sender.titleLabel?.text == "Play"{
//      playButton.titleLabel?.text = "Stop"
//      do {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let path = paths[0] + "recordedFile"
//        let filePath = URL(fileURLWithPath: path)
//        let player = try AKAudioPlayer(file: try AKAudioFile(forReading: filePath))
//        
//        AudioKit.output = player
//        AudioKit.start()
//        player.play()
//      } catch{
//        print(error.localizedDescription)
//      }
//    } else{
//      playButton.titleLabel?.text = "Play"
//      do {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let path = paths[0] + "recordedFile"
//        let filePath = URL(fileURLWithPath: path)
//        let player = try AKAudioPlayer(file: try AKAudioFile(forReading: filePath))
//        player.stop()
//      } catch{
//        print(error.localizedDescription)
//      }
//    }
  }
  
  
  
  
}

