//
//  Preprocessor.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 14/04/2021.
//

import Foundation

class Preprocessor
{
    init()
    {
        helperValues = Cordinates(x: 0, y: 0, z: 0)
    }
    
    func makeFullFiltration(sensorData: [SensorData])
    {
        lowPassPreprocessor(sensorData: sensorData)
        medianPreprocessor(sensorData: sensorData)
    }
    
    //MARK: Median filter
    //MedianFilter helper value
    let windowSize = 5
    
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
    
    //MARK: Low pass filter
    //LowPassFilter helper value
    let filterFactor: Double = 0.85
    var helperValues: Cordinates?
    
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
    
    
    //MARK: Peak segmentation
    var clickedNumTab: [Int] = []
    let startPosition = 35 //Ignored first 35 samples
    let windowSizePeak = 25
    
    func LetsSegmentation(clickedNumTab: String, sensorData: [SensorData])
    {
        self.clickedNumTab = clickedNumTab.strToIntTab()
        
        let indexOfPeaks: [Int] = getSegmentInd(sensorData: sensorData)
        
        saveTabOfPeaksToSensorData(tabOfIndPeaks: indexOfPeaks, sensorData: sensorData)
    }
    
    func getSegmentInd(sensorData: [SensorData]) -> [Int]
    {
        let numberOfClickedBtn = self.clickedNumTab.count
        var signalMeanTab: [Double] = []
        
        for data in sensorData
        {
            signalMeanTab.append( (data.rotRateData.x + data.rotRateData.y + data.rotRateData.z) / Double(numberOfClickedBtn))
        }
        
        var sumOfGSquare: Double = 0.0
        for g in signalMeanTab
        {
            sumOfGSquare += pow(g, 2)
        }
        
        let rootMeanSquareValue = sqrt( sumOfGSquare / Double(signalMeanTab.count) )
        
        //Peak to Average Power Ratio
        var PtAPRtab: [Double] = []
        for g in signalMeanTab
        {
            PtAPRtab.append( pow((g / rootMeanSquareValue), 2) )
        }
                
        return getTabOfPeaks(PtAPRtab: PtAPRtab)
    }
    
    func getTabOfPeaks(PtAPRtab: [Double]) -> [Int]
    {
        var actualValue = 0.0, prevValue = 0.0, nextValue = 0.0
        var tabOfPeaks: [(Int, Double)] = []
        
        for ind in 1..<PtAPRtab.count-1
        {
            actualValue = PtAPRtab[ind]
            prevValue = PtAPRtab[ind - 1]
            nextValue = PtAPRtab[ind + 1]
            
            if actualValue > prevValue && actualValue > nextValue
            {
                tabOfPeaks.append((ind, actualValue))
            }
        }
        
        let sortedTabOfPeaks = tabOfPeaks.sorted{ $0.1 < $1.1 }
        
        tabOfPeaks.sort{ $0.1 < $1.1 }
        
        var resultTab: [Int] = []
        
        var i = sortedTabOfPeaks.count - 1
        var N = self.clickedNumTab.count
        while N > 0 && i > 0
        {
            if resultTab.count != 0
            {
                if !checkIfTooClose(tabOfPeaks: resultTab, value: sortedTabOfPeaks[i].0)
                {
                    resultTab.append(sortedTabOfPeaks[i].0)
                    N -= 1
                }

            }
            else
            {
                resultTab.append(sortedTabOfPeaks[i].0)
                N -= 1
            }
                
            i -= 1
        }
        
        resultTab.sort()
        return resultTab
    }
    
    func checkIfTooClose(tabOfPeaks: [Int], value: Int) -> Bool
    {
        for x in tabOfPeaks
        {
            if x - self.windowSizePeak < value && value < x + self.windowSizePeak
            {
                return true
            }
        }

        return false
    }
    
    func saveTabOfPeaksToSensorData(tabOfIndPeaks: [Int], sensorData: [SensorData])
    {
        for ind in 0..<tabOfIndPeaks.count
        {
            let startWindow = (tabOfIndPeaks[ind] - self.windowSizePeak) >= 0 ? (tabOfIndPeaks[ind] - self.windowSizePeak) : 0
            let stopWindow = (tabOfIndPeaks[ind] + self.windowSizePeak) < sensorData.count ? (tabOfIndPeaks[ind] + self.windowSizePeak) : (sensorData.count - 1)
            let clickedBtn = self.clickedNumTab[ind]
            
            for i in startWindow...stopWindow
            {
                sensorData[i].label = clickedBtn
            }
        }
    }
    
}

