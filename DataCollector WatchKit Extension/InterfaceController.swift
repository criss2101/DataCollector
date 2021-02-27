//
//  InterfaceController.swift
//  DataCollector WatchKit Extension
//
//  Created by Krystian Rodzaj on 22/02/2021.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, MotionManagerDelegate {

    
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
    
    var gravCor: Cordinates?
    var rotRateCor: Cordinates?
    var userAccCor: Cordinates?
    var attDes: AttitudeDes?
        
    
    let motionManager = MotionManager()
    var active = false
    var isStarted = false
    
    override init()
    {
        super.init()
        motionManager.delegate = self
        motionManager.startMeasurement()
    }
    
    func updateMotionData(_ motionManager: MotionManager, gravCor: Cordinates, rotRateCor: Cordinates, userAccCor: Cordinates, attDes: AttitudeDes)
    {
        DispatchQueue.main.async
        {
            self.gravCor = gravCor
            self.rotRateCor = rotRateCor
            self.userAccCor = userAccCor
            self.attDes = attDes
            self.isStarted = true
            self.updateLabels()
        }
    }
    
    func updateLabels()
    {
        if active && isStarted
        {
            self.gravLabelX.setText(String(format: "%.2f", gravCor!.x))
            self.gravLabelY.setText(String(format: "%.2f",gravCor!.y))
            self.gravLabelZ.setText(String(format: "%.2f",gravCor!.z))
            
            self.rotLabelX.setText(String(format: "%.2f",rotRateCor!.x))
            self.rotLabelY.setText(String(format: "%.2f",rotRateCor!.y))
            self.rotLabelZ.setText(String(format: "%.2f",rotRateCor!.z))
            
            self.accLabelX.setText(String(format: "%.2f",userAccCor!.x))
            self.accLabelY.setText(String(format: "%.2f",userAccCor!.y))
            self.accLabelZ.setText(String(format: "%.2f",userAccCor!.z))
            
            self.attLabelR.setText(String(format: "%.2f",attDes!.roll))
            self.attLabelP.setText(String(format: "%.2f",attDes!.pitch))
            self.attLabelY.setText(String(format: "%.2f",attDes!.yaw))
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
