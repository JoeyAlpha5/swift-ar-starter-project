//
//  ContentView.swift
//  ModelPicker
//
//  Created by Jalome Chirwa on 2022/10/17.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: String?
    @State private var modelConfirmedFormPlacement: String?
    
    var modelsImagesArray: [String] = ["AirForce","PegasusTrail","teapot","toy_biplane"]
    
    var body: some View {
        return ZStack(alignment: .bottom){
            ARViewContainer(modelConfirmedFormPlacement:self.$modelConfirmedFormPlacement)
                
            if self.isPlacementEnabled{
                // placement compnent
                PlacementUIComponent(isPlacementEnabled: self.$isPlacementEnabled,selectedModel:self.$selectedModel,modelConfirmedFormPlacement:self.$modelConfirmedFormPlacement)
            }
            else{
                // object picker component
                ObjectPickerComponent(isPlacementEnabled: self.$isPlacementEnabled,selectedModel:self.$selectedModel,modelImages: self.modelsImagesArray)
            }


        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
    }
}



//placement UI component
struct PlacementUIComponent: View{
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    @Binding var modelConfirmedFormPlacement: String?
    var body: some View{
        HStack{
            // cancel button
            Button(action: {
                print("DEBUG: Cancel button")
                resetIsplacementEnabledState()
            }, label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(30)
                    .padding(20)
            })
            
            // confirm button
            Button(action: {
                // set the selected model
                self.modelConfirmedFormPlacement = self.selectedModel
                resetIsplacementEnabledState()
            }, label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(30)
                    .padding(20)
            })
        }
    }
    
    
    func resetIsplacementEnabledState() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}



// object picker at the bottom of the screen
struct ObjectPickerComponent: View{
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    var modelImages: [String]
    
    var body: some View{
        ScrollView(.horizontal,showsIndicators: false){
            HStack{
                    
                ForEach(0 ..< self.modelImages.count){ index in
                    
                    Button(action: {
                        isPlacementEnabled = true
                        selectedModel = self.modelImages[index]
                    }, label: {
                        Image("\(self.modelImages[index])")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .background(Color.white)
                            .cornerRadius(5)
                    })
                    
                }

            }
        }
        .padding(10)
        .background(Color.black.opacity(0.8))
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedFormPlacement: String?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // create AR tracking config
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // check if we have a model confirmed for placement, if so
        // assign it to a variable
        if let modelName = self.modelConfirmedFormPlacement{
            print("adding model to scene \(modelName)")
            
            // get the object
            let fileName = modelName + ".usdz"
            let modelEntity = try! ModelEntity.loadModel(named: fileName)
            
            let anchorEntity = AnchorEntity(plane:.any)
            anchorEntity.addChild(modelEntity)
            
            uiView.scene.addAnchor(anchorEntity)
            
            // reset the model confirmed for placement value
            // without the dispatch queue xcode will return an error
            // because you're changing a value while you're still processing it
            DispatchQueue.main.async{
                self.modelConfirmedFormPlacement = nil
            }
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
