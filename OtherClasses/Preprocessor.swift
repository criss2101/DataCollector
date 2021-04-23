//
//  Preprocessor.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 14/04/2021.
//

import Foundation

class Preprocessor
{
    //LowPassFilter helper value
    let filterFactor: Double = 0.85
    var helperValues: Cordinates?
    
    //MedianFilter helper value
    let windowSize = 5
    
    
    init()
    {
        helperValues = Cordinates(x: 0, y: 0, z: 0)
    }
    
    func makeFullFiltration(sensorData: [SensorData])
    {
        lowPassPreprocessor(sensorData: sensorData)
        medianPreprocessor(sensorData: sensorData)
    }
    
    func medianPreprocessor(sensorData: [SensorData])
    {
        var windowAccX: [Double] = []
        var windowAccY: [Double] = []
        var windowAccZ: [Double] = []
        
        var windowAttX: [Double] = []
        var windowAttY: [Double] = []
        var windowAttZ: [Double] = []
        
        var windowRotX: [Double] = []
        var windowRotY: [Double] = []
        var windowRotZ: [Double] = []
        
        for i in 0...sensorData.count - 1
        {
            for j in 0 ..< windowSize
            {
                let it = (i + j) < sensorData.count ? i + j : i
                windowAccX.append(sensorData[it].userAccData.x)
                windowAccY.append(sensorData[it].userAccData.y)
                windowAccZ.append(sensorData[it].userAccData.z)
                
                windowAttX.append(sensorData[it].attData.x)
                windowAttY.append(sensorData[it].attData.y)
                windowAttZ.append(sensorData[it].attData.z)
                
                windowRotX.append(sensorData[it].rotRateData.x)
                windowRotY.append(sensorData[it].rotRateData.y)
                windowRotZ.append(sensorData[it].rotRateData.z)
            }
            windowAccX.sort(); windowAccY.sort(); windowAccZ.sort();
            windowAttX.sort(); windowAttY.sort(); windowAttZ.sort();
            windowRotX.sort(); windowRotY.sort(); windowRotZ.sort();
            
            sensorData[i].userAccData.x = windowAccX[windowSize/2]
            sensorData[i].userAccData.y = windowAccY[windowSize/2]
            sensorData[i].userAccData.z = windowAccZ[windowSize/2]
            
            sensorData[i].attData.x = windowAttX[windowSize/2]
            sensorData[i].attData.y = windowAttY[windowSize/2]
            sensorData[i].attData.z = windowAttZ[windowSize/2]
            
            sensorData[i].rotRateData.x = windowRotX[windowSize/2]
            sensorData[i].rotRateData.y = windowRotY[windowSize/2]
            sensorData[i].rotRateData.z = windowRotZ[windowSize/2]
            
            windowAccX.removeAll(); windowAccY.removeAll(); windowAccZ.removeAll();
            windowAttX.removeAll(); windowAttY.removeAll(); windowAttZ.removeAll();
            windowRotX.removeAll(); windowRotY.removeAll(); windowRotZ.removeAll();
        }

    }
    
    func lowPassPreprocessor(sensorData: [SensorData])
    {
        for data in sensorData
        {
            lowPassFilter(data: data.userAccData)
        }
        helperValues!.resetValue()
        for data in sensorData
        {
            lowPassFilter(data: data.rotRateData)
        }
        helperValues!.resetValue()
        for data in sensorData
        {
            lowPassFilter(data: data.attData)
        }
        helperValues!.resetValue()
    }
        
    func lowPassFilter(data: Cordinates)
    {
        helperValues!.x = filterFactor * helperValues!.x + (1.0 - filterFactor) * data.x
        data.x = helperValues!.x
        helperValues!.y = filterFactor * helperValues!.y + (1.0 - filterFactor) * data.y
        data.y = helperValues!.y
        helperValues!.z = filterFactor * helperValues!.z + (1.0 - filterFactor) * data.z
        data.z = helperValues!.z
    }
}

