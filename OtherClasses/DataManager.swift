//
//  DataManager.swift
//  DataCollector
//
//  Created by Krystian Rodzaj on 13/03/2021.
//

import Foundation

class DataManager
{
    
    static func connectSensorDataAndSave(fileName: String, iphoneData: [SensorData], watchData: [SensorData])
    {
        var csvString = """
            id,Itimestamp,IgravityX,IgravityY,IgravityZ,IaccelerationX,IaccelerationY,IaccelerationZ,IattitudeRoll,IattitudePitch,IattitudeYaw,IrotationX,IrotationY,IrotationZ,Wtimestamp,WgravityX,WgravityY,WgravityZ,WaccelerationX,WaccelerationY,WaccelerationZ,WattitudeRoll,WattitudePitch,WattitudeYaw,WrotationX,WrotationY,WrotationZ\n
            """
        
        //CAPACITY CUT
        let count = iphoneData.count < watchData.count ? iphoneData.count : watchData.count
        
        var id = 0
        for ind  in 0...count-1
        {
            csvString.append("\(id),\(iphoneData[ind].timeStamp),\(iphoneData[ind].gravData.x),\(iphoneData[ind].gravData.y),\(iphoneData[ind].gravData.z),\(iphoneData[ind].userAccData.x),\(iphoneData[ind].userAccData.y),\(iphoneData[ind].userAccData.z),\(iphoneData[ind].attData.roll),\(iphoneData[ind].attData.pitch),\(iphoneData[ind].attData.yaw),\(iphoneData[ind].rotRateData.x),\(iphoneData[ind].rotRateData.y),\(iphoneData[ind].rotRateData.z),\(watchData[ind].timeStamp),\(watchData[ind].gravData.x),\(watchData[ind].gravData.y),\(watchData[ind].gravData.z),\(watchData[ind].userAccData.x),\(watchData[ind].userAccData.y),\(watchData[ind].userAccData.z),\(watchData[ind].attData.roll),\(watchData[ind].attData.pitch),\(watchData[ind].attData.yaw),\(watchData[ind].rotRateData.x),\(watchData[ind].rotRateData.y),\(watchData[ind].rotRateData.z)\n")
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

}
