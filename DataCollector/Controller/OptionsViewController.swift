//
//  OptionsViewController.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 24/03/2021.
//

import Foundation
import UIKit

class OptionsViewController: UIViewController
{
    var settingsContainer: SettingsContainer?
    @IBOutlet weak var switchSaveAllSensor: UISwitch!
    @IBOutlet weak var switchOnlyPhone: UISwitch!
    @IBOutlet weak var switchOnlyWatch: UISwitch!
    @IBOutlet weak var switchBothDevices: UISwitch!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updateSwitchStates()
    }
    
    @IBAction func switchStateChanged(_ sender: UISwitch)
    {
        switch sender
        {
            case switchSaveAllSensor:
                settingsContainer!.saveAllSensors = sender.isOn
                break
            case switchOnlyPhone:
                settingsContainer!.onlyPhone = sender.isOn
                if sender.isOn
                {
                    switchOnlyWatch.isOn = false
                    settingsContainer!.onlyWatch = false
                    switchBothDevices.isOn = false
                    settingsContainer!.bothDevices = false
                }
                break
            case switchOnlyWatch:
                settingsContainer!.onlyWatch = sender.isOn
                if sender.isOn
                {
                    switchOnlyPhone.isOn = false
                    settingsContainer!.onlyPhone = false
                    switchBothDevices.isOn = false
                    settingsContainer!.bothDevices = false
                }
                break
            case switchBothDevices:
                settingsContainer!.bothDevices = sender.isOn
                if sender.isOn
                {
                    switchOnlyPhone.isOn = false
                    settingsContainer!.onlyPhone = false
                    switchOnlyWatch.isOn = false
                    settingsContainer!.onlyWatch = false
                }
                break
            default:
                print("This switch is not supported")
        }
    }
    
    func updateSwitchStates()
    {
        switchSaveAllSensor.isOn = settingsContainer!.saveAllSensors
        switchOnlyPhone.isOn = settingsContainer!.onlyPhone
        switchOnlyWatch.isOn = settingsContainer!.onlyWatch
        switchBothDevices.isOn = settingsContainer!.bothDevices
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.settingsContainer = self.settingsContainer!
        }
    }
    
}
