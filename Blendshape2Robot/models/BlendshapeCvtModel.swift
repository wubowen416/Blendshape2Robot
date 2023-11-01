//
//  BsPassingModel.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/08.
//

import Foundation

class BlendshapeCvtModel {
    var setting = AppSetting(
        showStatics: false,
        showFaceMesh: true,
        remotePort: 12002,
        remoteHost: "172.27.174.6"
    )
    private var previousSetting = AppSetting(
        showStatics: false,
        showFaceMesh: true,
        remotePort: 12002,
        remoteHost: "172.27.174.6"
    )
    internal lazy var motionClient = MotionTcpClient()
    internal var csvFile = CsvFile()
    
    init() {
        load_config()
    }
    
    func load_config() {
        ConfigFile.load(setting: self.setting) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let setting):
                self.setting = setting
                self.previousSetting = setting
                self.update_members_setting()
            }
        }
    }
    
    func update_members_setting() {
        motionClient.host = setting.remoteHost
        motionClient.port = setting.remotePort
    }
    
    func save_config() {
        ConfigFile.save(setting: self.setting) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func change_setting() {
        if previousSetting != setting {
            update_members_setting()
            save_config()
            previousSetting = setting
        }
    }
    
    func connect_motion_server() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.motionClient.connect_host()
        }
    }
    
    func disconnect() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.motionClient.disconnect()
        }
    }
}
