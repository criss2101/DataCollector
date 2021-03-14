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
    //MARK: Variable
    @IBOutlet weak var gravLabelX: UILabel!
    @IBOutlet weak var gravLabelY: UILabel!
    @IBOutlet weak var gravLabelZ: UILabel!
    
    @IBOutlet weak var accLabelX: UILabel!
    @IBOutlet weak var accLabelY: UILabel!
    @IBOutlet weak var accLabelZ: UILabel!
    
    @IBOutlet weak var rotLabelX: UILabel!
    @IBOutlet weak var rotLabelY: UILabel!
    @IBOutlet weak var rotLabelZ: UILabel!
    
    @IBOutlet weak var attLabelR: UILabel!
    @IBOutlet weak var attLabelP: UILabel!
    @IBOutlet weak var attLabelY: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    var gravData: Cordinates?
    var rotRateData: Cordinates?
    var userAccData: Cordinates?
    var attData: AttCordinates?
    var sensorDataContainter: [SensorData] = []
    
    var isStarted = false
    var session: WCSession?
    let motionManager = MotionManager()
    @IBOutlet weak var KeyboardInput: UITextField!
    
    
    //MARK: Configuration
    override func viewDidLoad()
    {
        super.viewDidLoad()
        motionManager.delegate = self
        self.configureWatchSession()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        KeyboardInput.becomeFirstResponder()
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
            if let watchData = try? JSONDecoder().decode([SensorData].self, from: data!)
            {
                if !self.sensorDataContainter.isEmpty
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                    let now = Date()
                    let dateString = dateFormatter.string(from:now)
                    DataManager.connectSensorDataAndSave(fileName: "SensorsData_\(dateString)", iphoneData: self.sensorDataContainter, watchData: watchData)
                }
            }
        }
    }
    
    //MARK: Functions
    func updateMotionData(_ motionManager: MotionManager, sensorData: SensorData)
    {
        DispatchQueue.main.async
        {
            self.sensorDataContainter.append(sensorData)
            self.gravData = sensorData.gravData
            self.rotRateData = sensorData.rotRateData
            self.userAccData = sensorData.userAccData
            self.attData = sensorData.attData
            
            self.updateLabels()
        }
    }
    
    func updateLabels()
    {
        if isStarted
        {
            self.gravLabelX.text = String(format: "%.4f", gravData!.x)
            self.gravLabelY.text = String(format: "%.4f", gravData!.y)
            self.gravLabelZ.text = String(format: "%.4f", gravData!.z)
            
            self.rotLabelX.text = String(format: "%.4f", rotRateData!.x)
            self.rotLabelY.text = String(format: "%.4f", rotRateData!.y)
            self.rotLabelZ.text = String(format: "%.4f", rotRateData!.z)
            
            self.accLabelX.text = String(format: "%.4f", userAccData!.x)
            self.accLabelY.text = String(format: "%.4f", userAccData!.y)
            self.accLabelZ.text = String(format: "%.4f", userAccData!.z)
            
            self.attLabelR.text = String(format: "%.4f", attData!.roll)
            self.attLabelP.text = String(format: "%.4f", attData!.pitch)
            self.attLabelY.text = String(format: "%.4f", attData!.yaw)
        }
    }
    
    @IBAction func start()
    {
        self.sensorDataContainter.removeAll(keepingCapacity: false)
        isStarted = true
        motionManager.startMeasurement()
        stopButton.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1)
        startButton.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.3176470588, alpha: 1)
        
        let startCollectDataOnWatch = ["info" : "START"]
        session?.sendMessage(startCollectDataOnWatch, replyHandler: nil, errorHandler: { (err) in
            print(err.localizedDescription)
        })
    }
    
    @IBAction func stop()
    {
        if isStarted
        {
            motionManager.stopMeasurement()
            isStarted = false
            startButton.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1)
            stopButton.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.3176470588, alpha: 1)
            
            let stopCollectDataOnWatch = ["info" : "STOP"]
            session?.sendMessage(stopCollectDataOnWatch, replyHandler: nil, errorHandler: { (err) in
                print(err.localizedDescription)
            })

        }
    }


}

