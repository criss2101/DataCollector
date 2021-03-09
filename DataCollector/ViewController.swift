//
//  ViewController.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 22/02/2021.
//

import UIKit
import WatchConnectivity
import os.log

class ViewController: UIViewController, WCSessionDelegate, MotionManagerDelegate
{
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var isStarted = false
    var sensorDataContainter: [SensorData] = []
    var session: WCSession?
    let motionManager = MotionManager()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        motionManager.delegate = self
        self.configureWatchSession()
    }
    
    func configureWatchSession()
    {
        if WCSession.isSupported()
        {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    //MARK: Session
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceive file: WCSessionFile)
    {
        DispatchQueue.main.async
        {
            let data = try? Data(contentsOf: file.fileURL)
            if let receivedData = try? JSONDecoder().decode([SensorData].self, from: data!)
            {
                self.label.text = String(receivedData.capacity)
            }
        }
    }
    
    func updateMotionData(_ motionManager: MotionManager, sensorData: SensorData)
    {
        DispatchQueue.main.async
        {
            self.label.text = String(format: "X = %@, Y = %@, Z = %@",
                                String(sensorData.rotRateData.x),
                                String(sensorData.rotRateData.y),
                                String(sensorData.rotRateData.z))
        }
    }
    
    @IBAction func start()
    {
        self.sensorDataContainter.removeAll(keepingCapacity: false)
        isStarted = true
        motionManager.startMeasurement()
        stopButton.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1)
        startButton.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.3176470588, alpha: 1)
    }
    
    @IBAction func stop()
    {
        if isStarted
        {
            motionManager.stopMeasurement()
            isStarted = false
            startButton.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1)
            stopButton.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.3176470588, alpha: 1)
        }
    }


}

