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
        calibration(sensorData: sensorData)
        lowPassPreprocessor(sensorData: sensorData)
        medianPreprocessor(sensorData: sensorData)
    }
    
    //MARK: Calibration
    private func calibration(sensorData: [SensorData])
    {
        let meanAccX = sensorData.map({$0.userAccData.x}).reduce(0, +) / Double(sensorData.count)
        let meanAccY = sensorData.map({$0.userAccData.y}).reduce(0, +) / Double(sensorData.count)
        let meanAccZ = sensorData.map({$0.userAccData.z}).reduce(0, +) / Double(sensorData.count)

        for data in sensorData
        {
            data.userAccData.x = data.userAccData.x - meanAccX
            data.userAccData.y = data.userAccData.y - meanAccY
            data.userAccData.z = data.userAccData.z - meanAccZ
        }
    }
    
    
    //MARK: Median filter
    //MedianFilter helper value
    private let windowSize = 5
    
    private func medianPreprocessor(sensorData: [SensorData])
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
    private let filterFactor: Double = 0.85
    private var helperValues: Cordinates?
    
    private func lowPassPreprocessor(sensorData: [SensorData])
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
    
    private func lowPassFilter(data: Cordinates)
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
    var indexOfPeaks: [Int] = [] //For AI
    let startPosition = 35 //Ignored first 35 samples
    let stopPosition = 35 //Ignored last 35 samples
    
    let windowSizePeak = 30
    let stopWindowCorrector = 0
    let startWindowCorrector = 1 //Beacuse there is window with size 70 not 71
    
    func LetsSegmentation(clickedNumTab: String, sensorData: [SensorData])
    {
        self.clickedNumTab = clickedNumTab.strToIntTab()
        
        self.indexOfPeaks = getSegmentInd(sensorData: sensorData)
        
        saveTabOfPeaksToSensorData(tabOfIndPeaks: self.indexOfPeaks, sensorData: sensorData)
    }
    
    private func getSegmentInd(sensorData: [SensorData]) -> [Int]
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
    
    private func getTabOfPeaks(PtAPRtab: [Double]) -> [Int]
    {
        var actualValue = 0.0, prevValue = 0.0, nextValue = 0.0
        var tabOfPeaks: [(Int, Double)] = []
        
        //for ind in 1..<PtAPRtab.count-1
        for ind in self.startPosition..<PtAPRtab.count-self.stopPosition
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
    
    private func checkIfTooClose(tabOfPeaks: [Int], value: Int) -> Bool
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
    
    private func saveTabOfPeaksToSensorData(tabOfIndPeaks: [Int], sensorData: [SensorData])
    {
        
        for ind in 0..<tabOfIndPeaks.count
        {
            let startWindow = (tabOfIndPeaks[ind] - self.windowSizePeak + self.startWindowCorrector) >= 0 ? (tabOfIndPeaks[ind] - self.windowSizePeak + self.startWindowCorrector) : 0
            let stopWindow = (tabOfIndPeaks[ind] + self.windowSizePeak + self.stopWindowCorrector) < sensorData.count ?
                (tabOfIndPeaks[ind] + self.windowSizePeak + self.stopWindowCorrector) : (sensorData.count - 1)
            let clickedBtn = self.clickedNumTab[ind]
            
            for i in startWindow...stopWindow
            {
                sensorData[i].label = clickedBtn
            }
        }
    }
    
    func prapareDataForAI(iphoneData: [SensorData], watchData: [SensorData], bothDevice: Bool, onlyPhone: Bool) -> [[Double]]
    {
        var resultTab: [[Double]] = []
        var iphoneDataCp = iphoneData
        
        
        //CAPACITY CUT
        let count = iphoneData.count < watchData.count ? iphoneData.count : watchData.count
        
        //Find shift offset
        var offset = 0
        for off in 0...count-1
        {
            if iphoneData[off].timeStamp >= watchData[0].timeStamp
            {
                offset = off
                break;
            }
        }
        iphoneDataCp.removeSubrange(0..<offset) //iphone sensor data with offset
        
        
        for indOfPeak in self.indexOfPeaks
        {
            let startPosition = indOfPeak - self.windowSizePeak + self.startWindowCorrector
            let stopPosition = indOfPeak + self.windowSizePeak + self.stopWindowCorrector
            var iphoneTabAccX: [Double] = []
            var iphoneTabAccY: [Double] = []
            var iphoneTabAccZ: [Double] = []
            var iphoneTabRotX: [Double] = []
            var iphoneTabRotY: [Double] = []
            var iphoneTabRotZ: [Double] = []
            var watchTabAccX: [Double] = []
            var watchTabAccY: [Double] = []
            var watchTabAccZ: [Double] = []
            var watchTabRotX: [Double] = []
            var watchTabRotY: [Double] = []
            var watchTabRotZ: [Double] = []
            
            for ind in startPosition...stopPosition
            {
                iphoneTabAccX.append(iphoneDataCp[ind].userAccData.x)
                iphoneTabAccY.append(iphoneDataCp[ind].userAccData.y)
                iphoneTabAccZ.append(iphoneDataCp[ind].userAccData.z)
                iphoneTabRotX.append(iphoneDataCp[ind].rotRateData.x)
                iphoneTabRotY.append(iphoneDataCp[ind].rotRateData.y)
                iphoneTabRotZ.append(iphoneDataCp[ind].rotRateData.z)
                
                watchTabAccX.append(watchData[ind].userAccData.x)
                watchTabAccY.append(watchData[ind].userAccData.y)
                watchTabAccZ.append(watchData[ind].userAccData.z)
                watchTabRotX.append(watchData[ind].rotRateData.x)
                watchTabRotY.append(watchData[ind].rotRateData.y)
                watchTabRotZ.append(watchData[ind].rotRateData.z)
            }
            if bothDevice
            {
                var mergedTables: [Double] = []
                mergedTables += iphoneTabAccX; mergedTables += iphoneTabAccY; mergedTables += iphoneTabAccZ;
                mergedTables += iphoneTabRotX; mergedTables += iphoneTabRotY; mergedTables += iphoneTabRotZ;
                
                mergedTables += watchTabAccX; mergedTables += watchTabAccY; mergedTables += watchTabAccZ;
                mergedTables += watchTabRotX; mergedTables += watchTabRotY; mergedTables += watchTabRotZ;
                resultTab.append(mergedTables)
            }
            else
            {
                var mergedTables: [Double] = []
                if onlyPhone
                {
                    mergedTables += iphoneTabAccX; mergedTables += iphoneTabAccY; mergedTables += iphoneTabAccZ;
                    mergedTables += iphoneTabRotX; mergedTables += iphoneTabRotY; mergedTables += iphoneTabRotZ;
                    resultTab.append(mergedTables)
                }
                else
                {
                    mergedTables += watchTabAccX; mergedTables += watchTabAccY; mergedTables += watchTabAccZ;
                    mergedTables += watchTabRotX; mergedTables += watchTabRotY; mergedTables += watchTabRotZ;
                    resultTab.append(mergedTables)
                }
            }
        }
        return resultTab
    }
        
}

