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
        nikolaHost: "172.27.183.245",
        nikolaPort: 12000,
        solverHost: "172.27.183.117",
        solverPort: 65432
        
    )
    private var previousSetting = AppSetting(
        showStatics: false,
        showFaceMesh: true,
        nikolaHost: "172.27.183.245",
        nikolaPort: 12002,
        solverHost: "172.27.183.117",
        solverPort: 65432
    )
    internal lazy var nikolaClient = NikolaTcpClient()
    internal lazy var solverClient = SolverTcpClient()
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
        nikolaClient.host = setting.nikolaHost
        nikolaClient.port = setting.nikolaPort
        solverClient.host = setting.solverHost
        solverClient.port = setting.solverPort  
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
    
    func connect_to_nikola() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.nikolaClient.connect_host()
        }
    }
    
    func disconnect_from_nikola() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.nikolaClient.disconnect()
        }
    }
    
    func connect_to_solver() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.solverClient.connect_host()
        }
    }
    
    func disconnect_from_solver() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.solverClient.disconnect()
        }
    }
}
