//
//  ARViewController.swift
//  USC Visual Supply
//
//  Created by benny dalby on 12/4/21.
//

import UIKit
import RealityKit
import ARKit

class ARViewController: UIViewController {
    @IBOutlet weak var arView: ARView!
    
    public weak var delegate : imageDelegate?
    
    
    @IBOutlet weak var snapButton: UIButton!
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
    
        arView.automaticallyConfigureSession = true
      
       
            let configuration = self.buildConfigure()
            self.arView.session.run(configuration)
            
        snapButton.layer.cornerRadius = snapButton.frame.width/2
        snapButton.setTitle("", for: .normal)
        
        
    }
    
    func buildConfigure() -> ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()

        configuration.environmentTexturing = .automatic
        if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
           configuration.frameSemantics = .sceneDepth
        }

        return configuration
    }
    

    @IBAction func takePhoto(_ sender: Any) {
        
        
       // self.arView.session.delegate = self
        
        arView.snapshot(saveToHDR: true) { [weak self] image in
            
            self?.navigationController?.popViewController(animated: true)
            
            
            guard let frame = self?.arView.session.currentFrame  else {
            
                return
            }
            
            guard let depthData =  frame.sceneDepth else {
                
                return
            }
            

            guard let img = image else {
                
                return
            }
            
    
            
            let capturedImage = frame.capturedImage
            
            self?.delegate?.recieveImage(img,capturedImage,depthData.depthMap)
            
            self?.dismiss(animated: true, completion: nil)
            
        }
        
        
        
    }
    
}



extension Data {
    public static func from(pixelBuffer: CVPixelBuffer) -> Self {
        CVPixelBufferLockBaseAddress(pixelBuffer, [.readOnly])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, [.readOnly]) }

        // Calculate sum of planes' size
        var totalSize = 0
        for plane in 0 ..< CVPixelBufferGetPlaneCount(pixelBuffer) {
            let height      = CVPixelBufferGetHeightOfPlane(pixelBuffer, plane)
            let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, plane)
            let planeSize   = height * bytesPerRow
            totalSize += planeSize
        }

        guard let rawFrame = malloc(totalSize) else { fatalError() }
        var dest = rawFrame

        for plane in 0 ..< CVPixelBufferGetPlaneCount(pixelBuffer) {
            let source      = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, plane)
            let height      = CVPixelBufferGetHeightOfPlane(pixelBuffer, plane)
            let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, plane)
            let planeSize   = height * bytesPerRow

            memcpy(dest, source, planeSize)
            dest += planeSize
        }

        return Data(bytesNoCopy: rawFrame, count: totalSize, deallocator: .free)
    }
}
