//
//  Extensions.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 29/04/2021.
//

import Foundation

extension Date
{
    func currentTimeMillis() -> Int64
    {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension String {
    func strToIntTab() -> [Int] {
        var result: [Int] = []
        
        for v in self
        {
            result.append(v.wholeNumberValue!)
        }
        
        return result
    }
}

extension Array where Element == SensorData
{
    func copyLabeling(labeledSensorData: [SensorData], offset: Int)
    {
        if self.count > labeledSensorData.count
        {
            let count = labeledSensorData.count
            
            for ind in 0..<count
            {
                if ind + offset == self.count || ind == labeledSensorData.count
                {
                    break;
                }
                self[ind + offset].label = labeledSensorData[ind].label
            }
        }
        else
        {
            let count = self.count
            
            for ind in 0..<count
            {
                if ind + offset == labeledSensorData.count || ind == self.count
                {
                    break;
                }
                self[ind].label = labeledSensorData[ind + offset].label
            }
        }

    }
}
