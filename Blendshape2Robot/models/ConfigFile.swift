//
//  ConfigFile.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/09.
//

import Foundation

struct AppSetting: Codable {
    var showStatistics: Bool
    var showFaceMesh: Bool
    var remotePort: Int
    var remoteHost: String
    init(showStatics: Bool, showFaceMesh: Bool, remotePort: Int, remoteHost: String) {
        self.showStatistics = showStatics
        self.showFaceMesh = showFaceMesh
        self.remotePort = remotePort
        self.remoteHost = remoteHost
    }
}

extension AppSetting: Equatable {
    static func == (lhs: AppSetting, rhs: AppSetting) -> Bool {
        return lhs.showStatistics == rhs.showStatistics &&
        lhs.remotePort == rhs.remotePort &&
        lhs.remoteHost == rhs.remoteHost
    }
}

class ConfigFile {
    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("conf.txt")
    }
    
    static func load(setting: AppSetting, completion: @escaping (Result<AppSetting, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL)
                else {
                    DispatchQueue.main.async {
                        completion(.success(setting))
                    }
                    return
                }
                let conf = try JSONDecoder().decode(AppSetting.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(conf))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(setting: AppSetting, completion: @escaping (Result<(), Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let confData = try JSONEncoder().encode(setting)
                let saveFile = try fileURL()
                try confData.write(to: saveFile)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
