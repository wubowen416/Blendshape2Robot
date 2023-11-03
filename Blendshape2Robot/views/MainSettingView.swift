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
                    Text("Remote IP: ")
                        .foregroundColor(.secondary)
                    TextField("172.27.174.6", text: $arViewModel.remoteHost)
                        .keyboardType(.decimalPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.remoteHost, perform: { value in
                            arViewModel.remote_host_changed(to: value)
                        })
                }.padding()
                VStack(alignment: .leading) {
                    Text("Port: ")
                        .foregroundColor(.secondary)
                    TextField("12002", value: $arViewModel.remotePort, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.remotePort, perform: { value in
                            arViewModel.remote_port_changed(to: value)
                        })
                }.padding()
                Image(systemName: arViewModel.connected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(arViewModel.connected ? .teal : .orange)
                    .onTapGesture {
                        arViewModel.connected ? arViewModel.request_disconnect() : arViewModel.request_connect()
                    }
                    .padding()
            }
            
            Divider().gridCellUnsizedAxes(.horizontal)
            GridRow {
                Text("SAMPLE FACES")
                HStack {
                    Text("Num samples:")
                        .foregroundColor(.secondary)
                    TextField("5", value: $arViewModel.numSamples, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.numSamples, perform: { value in
                            arViewModel.num_samples_changed(to: value)
                        })
                }
            }
            GridRow {
                Button(action: arViewModel.start_sampling) {
                    Text("START")
                        .foregroundStyle(.white)
                        .padding()
                }
                .background(Rectangle()
                    .fill(Color.blue).cornerRadius(30))
                Button(action: arViewModel.stop_sampling) {
                    Text("STOP")
                        .foregroundStyle(.white)
                        .padding()
                }
                .background(Rectangle()
                    .fill(Color.blue).cornerRadius(30))
                Image(systemName: "record.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor((arViewModel.sampleModel?.isSampling ?? true) ? .teal : .orange)
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
