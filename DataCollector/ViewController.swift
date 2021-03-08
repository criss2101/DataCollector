//
//  ViewController.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 22/02/2021.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate
{
    var session: WCSession?
    
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
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


}

