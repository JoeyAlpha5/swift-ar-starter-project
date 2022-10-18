//
//  Model.swift
//  ModelPicker
//
//  Created by Jalome Chirwa on 2022/10/18.
//

import UIKit
import RealityKit
import Combine

class Model{
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName:String){
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        
        let fileName = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: fileName)
            .sink(receiveCompletion: { loadCompletion in
            // handle error
            print("DEBUG: unable to load object \(self.modelName)")
        }, receiveValue: {successfullyLoadedModelEntity in
            //
            print("DEBUG: object loaded \(self.modelName)")
            self.modelEntity = successfullyLoadedModelEntity
        })
    }
}
