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
    @State private var selectedModel: Model?
    @State private var modelConfirmedFormPlacement: Model?
    
    var modelsImagesArray: [Model] = [
        Model(modelName: "AirForce"),
        Model(modelName: "PegasusTrail"),
        Model(modelName: "teapot"),
        Model(modelName: "toy_biplane")
//        "AirForce","PegasusTrail","teapot","toy_biplane"
    ]
    
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
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedFormPlacement: Model?
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
    @Binding var selectedModel: Model?
    var modelImages: [Model]
    
    var body: some View{
        ScrollView(.horizontal,showsIndicators: false){
            HStack{
                    
                ForEach(0 ..< self.modelImages.count){ index in
                    
                    Button(action: {
                        isPlacementEnabled = true
                        selectedModel = self.modelImages[index]
                    }, label: {
                        Image(uiImage: self.modelImages[index].image)
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
    @Binding var modelConfirmedFormPlacement: Model?
    
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
        // assign it to a variable named model
        if let model = self.modelConfirmedFormPlacement{
            
            // check if the model has a model entity assigned
            // if so render the model
            if let modelEntity = model.modelEntity{
                print("DEBUG: adding model to scene \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane:.any)
                // enable model clone to add the same model more than once
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            }
            else{
                // if model entity is not available
                print("DEBUG: unable to load model entity for \(model.modelName)")
            }
            
            
            
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
