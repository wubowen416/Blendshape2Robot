//
//  TestSolverConfig.swift
//  Blendshape2Robot
//
//  Created by Bowen Wu on 2024/01/21.
//

import SwiftUI

struct TestSolverView: View {
    @EnvironmentObject var arViewModel: ArViewModel
    let rateValues: [Float] = [0.1, 0.01, 0.001]
    
    var body: some View {
        Grid(alignment: .center) {
            GridRow {
                Spacer(minLength: 110)
            }

            GridRow {
                Text("TEST SOLVER")
                    .padding()
                    .onLongPressGesture {
                        
                    }
                Toggle(isOn: $arViewModel.safeRigSolverTester) {
                    Text("Safe Rig")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Text("").padding()
            }
            GridRow {
                VStack(alignment: .leading) {
                    Text("Solver IP: ")
                        .foregroundColor(.secondary)
                    TextField("172.27.183.117", text: $arViewModel.solverHost)
                        .keyboardType(.decimalPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.solverHost, perform: { value in
                            arViewModel.solver_host_changed(to: value)
                        })
                }.padding()
                VStack(alignment: .leading) {
                    Text("Port: ")
                        .foregroundColor(.secondary)
                    TextField("65432", value: $arViewModel.solverPort, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.solverPort, perform: { value in
                            arViewModel.solver_port_changed(to: value)
                        })
                }.padding()
                Image(systemName: arViewModel.solverConnected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(arViewModel.solverConnected ? .teal : .orange)
                    .onTapGesture {
                        arViewModel.solverConnected ? arViewModel.request_disconnect_from_solver() : arViewModel.request_connect_to_solver()
                    }
                    .padding()
            }
            Divider().gridCellUnsizedAxes(.horizontal)
            GridRow {
                VStack(alignment: .leading) {
                    Text("Rig Maximum:")
                        .foregroundColor(.secondary)
                    TextField("", value: $arViewModel.rigMaximumSolverTester, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.numSamplesSolverTester, perform: { value in
                            arViewModel.rig_maximum_solver_tester_changed(to: value)
                        })
                }.padding()
                VStack(alignment: .leading) {
                    Text("Num Samples:")
                        .foregroundColor(.secondary)
                    TextField("", value: $arViewModel.numSamplesSolverTester, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.numSamplesSolverTester, perform: { value in
                            arViewModel.num_samples_solver_tester_changed(to: value)
                        })
                }.padding()
                ZStack {
                    Image(systemName: "play.circle")
                        .font(.system(size: 40))
                        .onTapGesture {
                            arViewModel.start_solver_test()
                        }
                        .scaleEffect((arViewModel.solverTesterModel?.isTesting ?? true) ? 0 : 1)
                        .opacity((arViewModel.solverTesterModel?.isTesting ?? true) ? 0 : 1)
                        .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: (arViewModel.solverTesterModel?.isTesting ?? true))
                    Image(systemName: "stop.circle")
                        .font(.system(size: 40))
                        .onTapGesture {
                            arViewModel.stop_solver_test()
                        }
                        .scaleEffect((arViewModel.solverTesterModel?.isTesting ?? true) ? 1 : 0)
                        .opacity((arViewModel.solverTesterModel?.isTesting ?? true) ? 1 : 0)
                        .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: !(arViewModel.solverTesterModel?.isTesting ?? true))
                }
            }
            Divider().gridCellUnsizedAxes(.horizontal)
            VStack () {
                HStack() {
                    Text("Rate:")
                        .foregroundColor(.secondary)
                    Picker("Select Rate", selection: $arViewModel.solverRate) {
                        ForEach(rateValues, id: \.self) { rate in
                            Text(String(format: "%.5f", rate)).tag(rate)
                        }
                    }
                    .accentColor(.accentColor)
                    .pickerStyle(MenuPickerStyle()) // Use the style you prefer
                    .onChange(of: arViewModel.solverRate) { value in
                        arViewModel.solver_rate_changed(to: value)
                    }
                }.padding()
                HStack() {
                    Text("Num Iterations:")
                        .foregroundColor(.secondary)
                    TextField("", value: $arViewModel.solverNIterations, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.solverNIterations, perform: {
                            value in
                            arViewModel.solver_n_iteration_changed(to: value)
                        })
                }.padding()
            }
            
            Divider().gridCellUnsizedAxes(.horizontal)
            Button(action: {
                arViewModel.map_current_blendshape()
            }) {
                Text("Map Current Blendshape")
            }
            .padding()
            .accentColor(Color.white)
            .background(Color.blue)
            .cornerRadius(10)
            
            Divider().gridCellUnsizedAxes(.horizontal)
            GridRow {
                MessageView()
                    .gridCellColumns(2)
                    .padding()
            }
        }
    }
}

struct TestSolverView_Previews: PreviewProvider {
    static var previews: some View {
        TestSolverView()
            .environmentObject(ArViewModel())
    }
}
