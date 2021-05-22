//
//  ViewController.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 22/02/2021.
//

import UIKit
import WatchConnectivity
import os.log
import CoreML

class ViewController: UIViewController, WCSessionDelegate, MotionManagerDelegate, UpdateSettingsDelegate
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
    var attData: Cordinates?
    var sensorDataContainter: [SensorData] = []
    var settingsContainer = SettingsContainer()
    let preprocessor = Preprocessor()
    
    
    var isStarted = false
    var isDuringSaving = false
    var session: WCSession?
    let motionManager = MotionManager()
    @IBOutlet weak var KeyboardInput: UITextField!
    @IBOutlet weak var AiOutput: UITextField!
    
    
    //MARK: Configuration
    override func viewDidLoad()
    {
        super.viewDidLoad()
        motionManager.delegate = self
        self.configureWatchSession()
        sensorDataContainter.reserveCapacity(10000)
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
            self.isDuringSaving = true
            let data = try? Data(contentsOf: file.fileURL)
            if let watchData = try? JSONDecoder().decode([SensorData].self, from: data!)
            {
                if !self.sensorDataContainter.isEmpty && !watchData.isEmpty
                {
                    if self.settingsContainer.learningMode
                    {
                        self.learningMode(iphoneData: self.sensorDataContainter, watchData: watchData)
                    }
                    else
                    {
                        self.aiMode(iphoneData: self.sensorDataContainter, watchData: watchData)
                    }
                }
            }
            //Show that file is saved
            self.isDuringSaving = false
        }
    }
        
    func updateWatchSettings()
    {
        if let data = try? JSONEncoder().encode(settingsContainer)
        {
            let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let newFilePath = path?.appendingPathComponent("settingsData")
            
            do
                {
                    try data.write(to: newFilePath!)
                }
            catch
            {
                print("Cannot write to file" + newFilePath!.absoluteString)
            }
            session!.transferFile(newFilePath!, metadata: nil)
        }
    }
    
    func updateSettingInWatch()
    {
        updateWatchSettings()
    }
    
    //MARK: Learning/Classification
    func aiMode(iphoneData: [SensorData], watchData: [SensorData])
    {
        self.preprocessor.LetsSegmentation(clickedNumTab: self.KeyboardInput.text!, sensorData: iphoneData)
        self.preprocessor.makeFullFiltration(sensorData: iphoneData)
        self.preprocessor.makeFullFiltration(sensorData: watchData)
        
        let preparedData: [[Double]] = preprocessor.prapareDataForAI(iphoneData: iphoneData, watchData: watchData, bothDevice: self.settingsContainer.bothDevices, onlyPhone: self.settingsContainer.onlyPhone)
        
        var inputArray: [testModelInput] = []
        for i in 0..<preparedData.count
        {
            let input = try? MLMultiArray(shape: [1, NSNumber(integerLiteral: preparedData[0].count)], dataType: MLMultiArrayDataType.float32)
            for (index, element) in preparedData[i].enumerated()
            {
                input![index] = NSNumber(floatLiteral: element)
            }
            inputArray.append(testModelInput(dense_input:input!))
        }
        
        let output: [testModelOutput] = try! testModel().predictions(inputs: inputArray)
        var outPutArray: [[Float32]] = []
        for out in output
        {
            print(out.featureNames)
            print(out.Identity)
            
            if let buffer = try? UnsafeBufferPointer<Float32>(out.Identity) {
                outPutArray.append(Array(buffer))
            }
            else
            {
                print("Something crashed")
            }
        }
        
        var resultArray: [Int] = []
        for out in outPutArray
        {
            resultArray.append(getIndOfMaxValue(array: out))
        }
        
        self.AiOutput.text = resultArray.map { String($0) }
            .joined()
    }
    
    func getIndOfMaxValue(array: [Float32]) -> Int
    {
        if let maxValue = array.max(), let index = array.firstIndex(of: maxValue)
        {
            return index
        }
        return -1
    }
    
    func learningMode(iphoneData: [SensorData], watchData: [SensorData])
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let now = Date()
        let dateString = dateFormatter.string(from:now)
        
        /*
         if self.settingsContainer.saveAllSensors && !self.settingsContainer.onlyWatch && !self.settingsContainer.onlyPhone
         {
         self.preprocessor.makeFullFiltration(sensorData: self.sensorDataContainter)
         self.preprocessor.makeFullFiltration(sensorData: watchData)
         
         self.preprocessor.LetsSegmentation(clickedNumTab: self.KeyboardInput.text!, sensorData: self.sensorDataContainter)
         
         DataManager.connectSensorsDataAndSaveAll(fileName: "AllSensorsData_\(dateString)", iphoneData: self.sensorDataContainter, watchData: watchData)
         }*/
        
        // Testing preprocessor
        
        if !self.settingsContainer.saveAllSensors && !self.settingsContainer.onlyWatch && !self.settingsContainer.onlyPhone
        {
            self.preprocessor.LetsSegmentation(clickedNumTab: self.KeyboardInput.text!, sensorData: iphoneData)
            DataManager.connectSensorsDataAndSaveGyrAcc(fileName: "Before_\(self.KeyboardInput.text!)_\(dateString)", iphoneData: iphoneData, watchData: watchData)
            
            
            self.preprocessor.makeFullFiltration(sensorData: iphoneData)
            self.preprocessor.makeFullFiltration(sensorData: watchData)
            DataManager.connectSensorsDataAndSaveGyrAcc(fileName: "After_\(self.KeyboardInput.text!)_\(dateString)", iphoneData: iphoneData, watchData: watchData)
        }
        else if self.settingsContainer.bothDevices && !self.settingsContainer.saveAllSensors
        {
            self.preprocessor.makeFullFiltration(sensorData: iphoneData)
            self.preprocessor.makeFullFiltration(sensorData: watchData)
            
            self.preprocessor.LetsSegmentation(clickedNumTab: self.KeyboardInput.text!, sensorData: iphoneData)
            
            DataManager.connectSensorsDataAndSaveGyrAcc(fileName: "SensorsData_\(dateString)", iphoneData: iphoneData, watchData: watchData)
        }
        else if self.settingsContainer.onlyPhone
        {
            self.preprocessor.makeFullFiltration(sensorData: iphoneData)
            self.preprocessor.LetsSegmentation(clickedNumTab: self.KeyboardInput.text!, sensorData: iphoneData)
            DataManager.connectSensorsDataAndSaveGyrAccOnlyPhone(fileName: "ISensorsData_\(dateString)", iphoneData: iphoneData)
        }
        else if self.settingsContainer.onlyWatch
        {
            self.preprocessor.makeFullFiltration(sensorData: watchData)
            self.preprocessor.LetsSegmentation(clickedNumTab: self.KeyboardInput.text!, sensorData: iphoneData)
            
            DataManager.connectSensorsDataAndSaveGyrAccOnlyWatch(fileName: "WSensorsData_\(dateString)", watchData: watchData)
        }
    }

    //MARK: Iphone functions
    
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
            
            self.attLabelR.text = String(format: "%.4f", attData!.x)
            self.attLabelP.text = String(format: "%.4f", attData!.y)
            self.attLabelY.text = String(format: "%.4f", attData!.z)
        }
    }
    
    @IBAction func start()
    {
        if !isDuringSaving
        {
            self.sensorDataContainter.removeAll(keepingCapacity: false)
            isStarted = true
            motionManager.startMeasurement()
            stopButton.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1568627451, alpha: 1)
            startButton.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.3176470588, alpha: 1)
            KeyboardInput.text = ""
            
            let startCollectDataOnWatch = ["info" : "START"]
            session?.sendMessage(startCollectDataOnWatch, replyHandler: nil, errorHandler: { (err) in
                print(err.localizedDescription)
            })
        }
        else
        {
            print("Data is currently saving")
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is OptionsViewController
        {
            let vc = segue.destination as? OptionsViewController
            vc?.settingsContainer = self.settingsContainer
            vc?.delegate = self
        }
    }
}

