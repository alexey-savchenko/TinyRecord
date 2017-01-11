//
//  secViewController.swift
//  soundRecord
//
//  Created by Alexey Savchenko on 09.01.17.
//  Copyright © 2017 Alexey Savchenko. All rights reserved.
//


import Foundation

import AVFoundation





public class AudioRecorder {
  
  var internalRecorder: AVAudioRecorder
  
  /// Initialize the recorder
  
  ///
  
  /// - parameter file: Path to the audio file
  
  ///
  
  public init(_ file: String) {
    
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory = urls[0] as NSURL
    let soundURL = documentDirectory.appendingPathComponent(file)
    
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatAppleLossless) as Int32),
                          AVNumberOfChannelsKey : NSNumber(value: 2 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue) as Int32)]
    
    try! internalRecorder = AVAudioRecorder(url: soundURL!, settings: recordSettings)
    
  }
  
  
  public func getUrlString() -> String{
    return internalRecorder.url.path
  }
  /// Record audio
  
  public func record() {
    internalRecorder.prepareToRecord()
    internalRecorder.record()
  }
  /// Stop recording
  
  public func stop() {
    internalRecorder.stop()
  }
  
}
