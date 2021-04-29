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
        let count = self.count < labeledSensorData.count ? self.count : labeledSensorData.count
        
        for ind in 0..<count
        {
            if ind + offset == self.count || ind == labeledSensorData.count
            {
                break;
            }
            self[ind + offset].label = labeledSensorData[ind].label
        }
    }
}
