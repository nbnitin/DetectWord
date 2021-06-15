//
//  VC2.swift
//  Detect word
//
//  Created by Nitin Bhatia on 5/3/21.
//

import UIKit
import VisionKit
import Vision

class VC2: UIViewController,VNDocumentCameraViewControllerDelegate {
    var documentCamera: VNDocumentCameraViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        showDocumentScanner()
        
    }
    
    
    func showDocumentScanner() {
        guard VNDocumentCameraViewController.isSupported else { print("Document scanning not supported"); return }
        documentCamera = VNDocumentCameraViewController()
        documentCamera?.delegate = self
        present(documentCamera!, animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        documentCamera?.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("Document Scanner did fail with Error")
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        documentCamera?.dismiss(animated: true, completion: nil)
        documentCamera = nil
        print("Finished scanning document \"\(String(describing: title))\"")
        print("Found \(scan.pageCount)")
        let firstImage = scan.imageOfPage(at: 0)
        detectText(in: firstImage)
    }
    
    func detectText(in image: UIImage) {
        guard let image = image.cgImage else {
            print("Invalid image")
            return
        }
        
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error detecting text: \(error)")
            } else {
                self.handleDetectionResults(results: request.results)
            }
        }
        
        request.recognitionLanguages = ["en_US"]
        request.recognitionLevel = .accurate
        
        performDetection(request: request, image: image)
    }
    
    func performDetection(request: VNRecognizeTextRequest, image: CGImage) {
        let requests = [request]
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform(requests)
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    func handleDetectionResults(results: [Any]?) {
        guard let results = results, results.count > 0 else {
            print("No text found")
            return
        }
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    
                    for items in text.string.components(separatedBy: .whitespaces) {
                        if items.hasPrefix("MW") {
                            print(items)
                            break
                        }
                    }
                    
                    // print(text.confidence)
                    //print(observation.boundingBox)
                    //print("\n")
                }
            }
        }
    }
    
}
