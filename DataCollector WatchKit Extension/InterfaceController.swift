//
//  InterfaceController.swift
//  DataCollector WatchKit Extension
//
//  Created by Krystian Rodzaj on 22/02/2021.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, MotionManagerDelegate {

    
    @IBOutlet weak var gravLabel: WKInterfaceLabel!
    @IBOutlet weak var accLabel: WKInterfaceLabel!
    @IBOutlet weak var attLabel: WKInterfaceLabel!
    @IBOutlet weak var rotLabel: WKInterfaceLabel!
    
    var gravStr = ""
    var accStr = ""
    var attStr = ""
    var rotStr = ""
    
    
    let motionManager = MotionManager()
    var active = false
    
    override init()
    {
        super.init()
        motionManager.delegate = self
        motionManager.startMeasurement()
    }
    
    func updateMotionData(_ motionManager: MotionManager, gravStr: String, rotRateStr: String, userAccStr: String, attStr: String)
    {
        DispatchQueue.main.async
        {
            self.gravStr = gravStr
            self.accStr = userAccStr
            self.rotStr = rotRateStr
            self.attStr = attStr
            self.updateLabels()
        }
    }
    
    func updateLabels()
    {
        if active
        {
            self.gravLabel.setText(gravStr)
            self.accLabel.setText(accStr)
            self.rotLabel.setText(rotStr)
            self.attLabel.setText(attStr)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        active = true
        updateLabels()
    }

    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }

}
