//
//  InterfaceController.swift
//  DataCollector WatchKit Extension
//
//  Created by Krystian Rodzaj on 22/02/2021.
//

import WatchKit
import Foundation
import WatchConnectivity
import HealthKit

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
    var attData: Cordinates?
    var sensorDataContainter: [SensorData] = []
    var settingsContainer = SettingsContainer()
        
    let motionManager = MotionManager()
    var workoutSession: HKWorkoutSession?
    
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
        sensorDataContainter.reserveCapacity(10000)
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
            
            self.attLabelR.setText(String(format: "%.2f", attData!.x))
            self.attLabelP.setText(String(format: "%.2f", attData!.y))
            self.attLabelY.setText(String(format: "%.2f", attData!.z))
        }
    }
    
    @IBAction func start()
    {
        self.sensorDataContainter.removeAll(keepingCapacity: false)
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .tennis
        workoutConfiguration.locationType = .outdoor

        do
        {
            workoutSession = try HKWorkoutSession(healthStore: HKHealthStore(), configuration: workoutConfiguration)
        } catch
        {
            fatalError("Error occured during init session !")
        }
        
        workoutSession?.startActivity(with: Date())
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
            workoutSession?.stopActivity(with: Date())
            workoutSession?.end()
            isStarted = false
            startButton.setBackgroundColor(#colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1))
            stopButton.setBackgroundColor(#colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.3176470588, alpha: 1))
        }
    }
    
    func saveCollectedData()
    {
        if let data = try? JSONEncoder().encode(sensorDataContainter)
        {
            let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let newFilePath = path?.appendingPathComponent("watchData")
            
            do
            {
                try data.write(to: newFilePath!)
            }
            catch
            {
                print("Cannot write to file" + newFilePath!.absoluteString)
            }
            session.transferFile(newFilePath!, metadata: nil)
        }
    }
    
    //MARK: Session
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any])
    {
        DispatchQueue.main.async
        {
            let info = message["info"] as! String
            if info == "STOP"
            {
                self.stop()
                self.saveCollectedData()
            }
            if info == "START"
            {
                self.start()
            }
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile)
    {
        DispatchQueue.main.async
        {
            let data = try? Data(contentsOf: file.fileURL)
            if let settngsData = try? JSONDecoder().decode(SettingsContainer.self, from: data!)
            {
                self.settingsContainer = settngsData
            }
        }
    }
    
}
