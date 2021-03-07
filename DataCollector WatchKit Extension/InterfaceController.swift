//
//  InterfaceController.swift
//  DataCollector WatchKit Extension
//
//  Created by Krystian Rodzaj on 22/02/2021.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, MotionManagerDelegate, WCSessionDelegate
{
    //MARK: Variable
    @IBOutlet weak var gravLabelX: WKInterfaceLabel!
    @IBOutlet weak var gravLabelY: WKInterfaceLabel!
    @IBOutlet weak var gravLabelZ: WKInterfaceLabel!
    
    @IBOutlet weak var accLabelX: WKInterfaceLabel!
    @IBOutlet weak var accLabelY: WKInterfaceLabel!
    @IBOutlet weak var accLabelZ: WKInterfaceLabel!
    
    @IBOutlet weak var rotLabelX: WKInterfaceLabel!
    @IBOutlet weak var rotLabelY: WKInterfaceLabel!
    @IBOutlet weak var rotLabelZ: WKInterfaceLabel!
    
    @IBOutlet weak var attLabelR: WKInterfaceLabel!
    @IBOutlet weak var attLabelP: WKInterfaceLabel!
    @IBOutlet weak var attLabelY: WKInterfaceLabel!
    
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var stopButton: WKInterfaceButton!
    
    
    var gravData: Cordinates?
    var rotRateData: Cordinates?
    var userAccData: Cordinates?
    var attData: AttCordinates?
    var sensorDataContainter: [SensorData] = []
        
    let motionManager = MotionManager()
    let session = WCSession.default
    var active = false
    var isStarted = false
    
    
    //MARK: Functions
    override init()
    {
        super.init()
        motionManager.delegate = self
        session.delegate = self
        session.activate()
    }
    
    override func willActivate()
    {
        super.willActivate()
        active = true
        updateLabels()
    }

    override func didDeactivate()
    {
        super.didDeactivate()
        active = false
    }
    
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
        if active && isStarted
        {
            self.gravLabelX.setText(String(format: "%.2f", gravData!.x))
            self.gravLabelY.setText(String(format: "%.2f", gravData!.y))
            self.gravLabelZ.setText(String(format: "%.2f", gravData!.z))
            
            self.rotLabelX.setText(String(format: "%.2f", rotRateData!.x))
            self.rotLabelY.setText(String(format: "%.2f", rotRateData!.y))
            self.rotLabelZ.setText(String(format: "%.2f", rotRateData!.z))
            
            self.accLabelX.setText(String(format: "%.2f", userAccData!.x))
            self.accLabelY.setText(String(format: "%.2f", userAccData!.y))
            self.accLabelZ.setText(String(format: "%.2f", userAccData!.z))
            
            self.attLabelR.setText(String(format: "%.2f", attData!.roll))
            self.attLabelP.setText(String(format: "%.2f", attData!.pitch))
            self.attLabelY.setText(String(format: "%.2f", attData!.yaw))
        }
    }
    
    @IBAction func start()
    {
        self.sensorDataContainter.removeAll(keepingCapacity: true) // Is it improvement ?
        isStarted = true
        motionManager.startMeasurement()
        stopButton.setBackgroundColor(#colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1))
        startButton.setBackgroundColor(#colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.3176470588, alpha: 1))
    }
    
    @IBAction func stop()
    {
        if isStarted
        {
            motionManager.stopMeasurement()
            isStarted = false
            startButton.setBackgroundColor(#colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1))
            stopButton.setBackgroundColor(#colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.3176470588, alpha: 1))
            saveCollectedData()
        }
        
    }
    
    func saveCollectedData()
    {
        if let data = try? JSONEncoder().encode(sensorDataContainter)
        {
            session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
        }
    }
    
    //MARK: Session
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
