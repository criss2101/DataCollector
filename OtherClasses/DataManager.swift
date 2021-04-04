//
//  DataManager.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 13/03/2021.
//

import Foundation

class DataManager
{
    
    static func connectSensorsDataAndSaveAll(fileName: String, iphoneData: [SensorData], watchData: [SensorData])
    {
        var csvString = """
            id,Itimestamp,IgravityX,IgravityY,IgravityZ,IaccelerationX,IaccelerationY,IaccelerationZ,IattitudeRoll,IattitudePitch,IattitudeYaw,IrotationX,IrotationY,IrotationZ,Wtimestamp,WgravityX,WgravityY,WgravityZ,WaccelerationX,WaccelerationY,WaccelerationZ,WattitudeRoll,WattitudePitch,WattitudeYaw,WrotationX,WrotationY,WrotationZ\n
            """
        
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
        
        var id = 0
        for ind  in 0...count-1
        {
            if ind + offset == iphoneData.count || ind == watchData.count
            {
                break;
            }
            csvString.append("\(id),\(iphoneData[ind+offset].timeStamp),\(iphoneData[ind+offset].gravData.x),\(iphoneData[ind+offset].gravData.y),\(iphoneData[ind+offset].gravData.z),\(iphoneData[ind+offset].userAccData.x),\(iphoneData[ind+offset].userAccData.y),\(iphoneData[ind+offset].userAccData.z),\(iphoneData[ind+offset].attData.roll),\(iphoneData[ind+offset].attData.pitch),\(iphoneData[ind+offset].attData.yaw),\(iphoneData[ind+offset].rotRateData.x),\(iphoneData[ind+offset].rotRateData.y),\(iphoneData[ind+offset].rotRateData.z),\(watchData[ind].timeStamp),\(watchData[ind].gravData.x),\(watchData[ind].gravData.y),\(watchData[ind].gravData.z),\(watchData[ind].userAccData.x),\(watchData[ind].userAccData.y),\(watchData[ind].userAccData.z),\(watchData[ind].attData.roll),\(watchData[ind].attData.pitch),\(watchData[ind].attData.yaw),\(watchData[ind].rotRateData.x),\(watchData[ind].rotRateData.y),\(watchData[ind].rotRateData.z)\n")
            id+=1
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        let fileUrl = path.appendingPathComponent(fileName + ".csv")
        do
        {
            try csvString.write(to: fileUrl, atomically: true, encoding: .utf8)
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    static func connectSensorsDataAndSaveGyrAcc(fileName: String, iphoneData: [SensorData], watchData: [SensorData])
    {
        var csvString = """
            Itimestamp,IaccelerationX,IaccelerationY,IaccelerationZ,IrotationX,IrotationY,IrotationZ,Wtimestamp,WaccelerationX,WaccelerationY,WaccelerationZ,WrotationX,WrotationY,WrotationZ\n
            """
        
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
        
        for ind  in 0...count-1
        {
            if ind + offset == iphoneData.count || ind == watchData.count
            {
                break;
            }
            csvString.append("\(iphoneData[ind+offset].timeStamp),\(iphoneData[ind+offset].userAccData.x),\(iphoneData[ind+offset].userAccData.y),\(iphoneData[ind+offset].userAccData.z),\(iphoneData[ind+offset].rotRateData.x),\(iphoneData[ind+offset].rotRateData.y),\(iphoneData[ind+offset].rotRateData.z),\(watchData[ind].timeStamp),\(watchData[ind].userAccData.x),\(watchData[ind].userAccData.y),\(watchData[ind].userAccData.z),\(watchData[ind].rotRateData.x),\(watchData[ind].rotRateData.y),\(watchData[ind].rotRateData.z)\n")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        let fileUrl = path.appendingPathComponent(fileName + ".csv")
        do
        {
            try csvString.write(to: fileUrl, atomically: true, encoding: .utf8)
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    static func connectSensorsDataAndSaveGyrAccOnlyPhone(fileName: String, iphoneData: [SensorData])
    {
        var csvString = """
            Itimestamp,IaccelerationX,IaccelerationY,IaccelerationZ,IrotationX,IrotationY,IrotationZ\n
            """
        
        for data in iphoneData
        {
            csvString.append("\(data.timeStamp),\(data.userAccData.x),\(data.userAccData.y),\(data.userAccData.z),\(data.rotRateData.x),\(data.rotRateData.y),\(data.rotRateData.z)\n")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        let fileUrl = path.appendingPathComponent(fileName + ".csv")
        do
        {
            try csvString.write(to: fileUrl, atomically: true, encoding: .utf8)
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    static func connectSensorsDataAndSaveGyrAccOnlyWatch(fileName: String, watchData: [SensorData])
    {
        var csvString = """
            Wtimestamp,WaccelerationX,WaccelerationY,WaccelerationZ,WrotationX,WrotationY,WrotationZ\n
            """

        for data in watchData
        {
            csvString.append("\(data.timeStamp),\(data.userAccData.x),\(data.userAccData.y),\(data.userAccData.z),\(data.rotRateData.x),\(data.rotRateData.y),\(data.rotRateData.z)\n")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        let fileUrl = path.appendingPathComponent(fileName + ".csv")
        do
        {
            try csvString.write(to: fileUrl, atomically: true, encoding: .utf8)
            
        }catch{
            print(error.localizedDescription)
        }
    }

}
