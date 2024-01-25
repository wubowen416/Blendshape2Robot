//
//  MainSettingView.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/15.
//

import SwiftUI

struct MainSettingView: View {
    @EnvironmentObject var arViewModel: ArViewModel
    
    var body: some View {
        Grid(alignment: .center) {
            GridRow {
                Spacer(minLength: 110)
            }
            GridRow {
                Toggle(isOn: $arViewModel.showStatistics) {
                    Text("Show Statistics")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Toggle(isOn: $arViewModel.showFaceMesh) {
                    Text("Show Face Mesh")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
            }
            GridRow {
                VStack(alignment: .leading) {
                    Text("Nikola IP: ")
                        .foregroundColor(.secondary)
                    TextField("172.27.183.246", text: $arViewModel.nikolaHost)
                        .keyboardType(.decimalPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.nikolaHost, perform: { value in
                            arViewModel.nikola_host_changed(to: value)
                        })
                }.padding()
                VStack(alignment: .leading) {
                    Text("Port: ")
                        .foregroundColor(.secondary)
                    TextField("12000", value: $arViewModel.nikolaPort, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.nikolaPort, perform: { value in
                            arViewModel.nikola_port_changed(to: value)
                        })
                }.padding()
                Image(systemName: arViewModel.connected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(arViewModel.connected ? .teal : .orange)
                    .onTapGesture {
                        arViewModel.connected ? arViewModel.request_disconnect_from_nikola() : arViewModel.request_connect_to_nikola()
                    }
                    .padding()
            }
            Divider().gridCellUnsizedAxes(.horizontal)
            GridRow {
                MessageView()
                    .gridCellColumns(2)
                    .padding()
            }
        }
    }
}

struct MainSettingView_Previews: PreviewProvider {
    static var previews: some View {
        MainSettingView()
            .environmentObject(ArViewModel())
    }
}
