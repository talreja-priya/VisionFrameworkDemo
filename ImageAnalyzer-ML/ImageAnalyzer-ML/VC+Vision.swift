//
//  VC+Vision.swift
//  ImageAnalyzer-ML
//
//  Created by Priya Talreja on 26/07/19.
//  Copyright © 2019 Priya Talreja. All rights reserved.
//

import UIKit
import Vision

enum DetectionTypes {
    case Rectangle
    case Face
    case Barcode
    case Text
}
extension ViewController
{
    func createVisionRequest(image: UIImage)
    {
        guard let cgImage = image.cgImage else {
            return
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
        let vnRequests = [vnDetectionRequest,vnFaceDetectionRequest,vnBarCodeDetectionRequest,vnTextDetectionRequest]
        DispatchQueue.global(qos: .background).async {
            do{
                try requestHandler.perform(vnRequests)
            }catch let error as NSError {
                print("Error in performing Image request: \(error)")
            }
        }
        
    }
    
    var vnDetectionRequest : VNDetectRectanglesRequest{
        let request = VNDetectRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Rectangle)
            }
        }
        request.maximumObservations = 0
        return request
    }
    
    var vnFaceDetectionRequest : VNDetectFaceRectanglesRequest{
        let request = VNDetectFaceRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Face)
            }
        }
        return request
    }
    
    var vnBarCodeDetectionRequest : VNDetectBarcodesRequest{
        let request = VNDetectBarcodesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Barcode)
            }
        }
        
        return request
    }
    
    var vnTextDetectionRequest : VNDetectTextRectanglesRequest{
        let request = VNDetectTextRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Text)
            }
        }
        
        return request
    }
    
    func visualizeObservations(observations : [VNDetectedObjectObservation],type: DetectionTypes){
        DispatchQueue.main.async {
            guard let image = self.imageView.image
                else{
                    print("Failure in retriving image")
                    return
            }
            let imageSize = image.size
            var imageTransform = CGAffineTransform.identity.scaledBy(x: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)
            imageTransform = imageTransform.scaledBy(x: imageSize.width, y: imageSize.height)
            UIGraphicsBeginImageContextWithOptions(imageSize, true, 0)
            let graphicsContext = UIGraphicsGetCurrentContext()
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            
            graphicsContext?.saveGState()
            graphicsContext?.setLineJoin(.round)
            graphicsContext?.setLineWidth(8.0)
            
            switch type
            {
            case .Face:
                graphicsContext?.setFillColor(red: 1, green: 0, blue: 0, alpha: 0.3)
                graphicsContext?.setStrokeColor(UIColor.red.cgColor)
            case .Barcode,.Text:
                graphicsContext?.setFillColor(red: 0, green: 1, blue: 0, alpha: 0.3)
                graphicsContext?.setStrokeColor(UIColor.green.cgColor)
            case .Rectangle:
                graphicsContext?.setFillColor(red: 0, green: 0, blue: 1, alpha: 0.3)
                graphicsContext?.setStrokeColor(UIColor.blue.cgColor)
            
            }
            
            
            observations.forEach { (observation) in
                let observationBounds = observation.boundingBox.applying(imageTransform)
                graphicsContext?.addRect(observationBounds)
            }
            graphicsContext?.drawPath(using: CGPathDrawingMode.fillStroke)
            graphicsContext?.restoreGState()
            
            let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageView.image = drawnImage
            
        }
    }
}
