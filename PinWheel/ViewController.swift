//
//  ViewController.swift
//  PinWheel
//
//  Created by Xuanyi Liu on 16/8/28.
//  Copyright © 2016年 Xuanyi Liu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    @IBOutlet private weak var recordButton: UIControl!
    @IBOutlet private weak var pinwhellImageView: UIImageView!
    
    private var audioSession: AVAudioSession!
    private var recordSession: AVAudioRecorder!
    
    private var wheelTimer = Timer()
    
    func updatePower() {
        recordSession.updateMeters()
        let power = recordSession.averagePower(forChannel: 0)
        print("\(power)")
        if power > -40 {
            spin(speed: 0.2)
        }
    }
    
    func spin (speed: Float) {
        UIView.animate(withDuration: TimeInterval(speed), delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.pinwhellImageView.transform = self.pinwhellImageView.transform.rotated(by: CGFloat(M_PI))
        }) { (finished) -> Void in
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioRecorderSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupAudioRecorderSession() {
        
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("allowed")
                    } else {
                        print("failed")
                    }
                }
            }
        } catch {
            print("failed")
        }
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory as URL
    }
    
    class func getWhistleURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("whistle.m4a") as URL
    }
    
    func startRecord() {
        let audioURL = ViewController.getWhistleURL()
        print(audioURL.absoluteString)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recordSession = try AVAudioRecorder(url: audioURL, settings: settings)
            recordSession.delegate = self
            recordSession.isMeteringEnabled = true
            recordSession.prepareToRecord()
            recordSession.record()
            wheelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePower), userInfo: nil
                , repeats: true)
        } catch {
            print("failed")
            recordSession.stop()
            recordSession = nil
            wheelTimer.invalidate()
        }
    }


    @IBAction func recordingAction(_ sender: UIControl) {
        if recordSession == nil {
            startRecord()
        }
    }
    
    @IBAction func recodingStopAction(_ sender: UIControl) {
        if recordSession != nil {
            print("finish")
            recordSession.stop()
            recordSession = nil
            wheelTimer.invalidate()
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag == true {
            print("failed")
            recordSession.stop()
            recordSession = nil
            wheelTimer.invalidate()
        }
        else {
            print("delegate finish")
        }
    }
}

