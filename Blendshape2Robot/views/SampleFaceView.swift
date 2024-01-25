//
//  SampleFaceView.swift
//  Blendshape2Robot
//
//  Created by Bowen Wu on 2024/01/21.
//

import SwiftUI

struct SampleFaceView: View {
    @EnvironmentObject var arViewModel: ArViewModel
    
    var body: some View {
        Grid(alignment: .center) {
            GridRow {
                Spacer(minLength: 110)
            }
            GridRow {
                Text("SAMPLE FACE").padding()
                Toggle(isOn: $arViewModel.safeRig) {
                    Text("Safe Rig")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Text("").padding()
            }
            GridRow {
                VStack(alignment: .leading) {
                    Text("Rig Maximum:")
                        .foregroundColor(.secondary)
                    TextField("", value: $arViewModel.rigMaximum, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.numSamples, perform: { value in
                            arViewModel.rig_maximum_changed(to: value)
                        })
                }.padding()
                VStack(alignment: .leading) {
                    Text("Num Samples:")
                        .foregroundColor(.secondary)
                    TextField("", value: $arViewModel.numSamples, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.accentColor)
                        .foregroundColor(Color(UIColor.darkGray))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: arViewModel.numSamples, perform: { value in
                            arViewModel.num_samples_changed(to: value)
                        })
                }.padding()
                ZStack {
                    Image(systemName: "play.circle")
                        .font(.system(size: 40))
                        .onTapGesture {
                            arViewModel.start_sampling()
                        }
                        .scaleEffect((arViewModel.sampleModel?.isSampling ?? true) ? 0 : 1)
                        .opacity((arViewModel.sampleModel?.isSampling ?? true) ? 0 : 1)
                        .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: (arViewModel.sampleModel?.isSampling ?? true))
                    Image(systemName: "stop.circle")
                        .font(.system(size: 40))
                        .onTapGesture {
                            arViewModel.stop_sampling()
                        }
                        .scaleEffect((arViewModel.sampleModel?.isSampling ?? true) ? 1 : 0)
                        .opacity((arViewModel.sampleModel?.isSampling ?? true) ? 1 : 0)
                        .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: !(arViewModel.sampleModel?.isSampling ?? true))
                    
                }
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

struct SampleFaceView_Previews: PreviewProvider {
    static var previews: some View {
        SampleFaceView()
            .environmentObject(ArViewModel())
    }
}
