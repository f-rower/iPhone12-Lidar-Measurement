//
//  ViewController.swift
//  Lidar_Measurement_App
//
//  Created by F-Rower on 25/02/2021.
//

import UIKit
import ARKit
import RealityKit

class ViewController: UIViewController, ARSessionDelegate, UITextFieldDelegate{
    var session: ARSession!
    var configuration = ARWorldTrackingConfiguration()
    var flag = 0 //A flag to mark whether to start or stop writing measurements to file
    var timer: Timer! //Needed to write measurements to file every x seconds (a while loop doesn't work because the button remains pressed forever)
    let timeinterval : Double = 1.0 //frequency at which we write lidar measurements to the file
    var filestring : String = ""; //The filename that we write on the text input field
    var filename : URL = URL(string:"a")! //The full path of the file. Initialise to some random value
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var arview: ARView! //For some reason this is the only thing i can use to be able to see the camera feed
    
    @IBAction func startButton(_ sender: UIButton) {
        flag = 1
        filestring = filenameInput.text!
        if filestring == "" {
            //Add here a warning message that the textfield is empty
            print("empty text field")
            flag = 0
            return
        }
        print(filestring)
        recordingLabel.isHidden = false
        filename = createnewfile() //Creates a new file to which we will write using the textfield as name
        //run the code that writes to the file at a frequency of timeinterval
        timer = Timer.scheduledTimer(timeInterval: timeinterval, target: self, selector: #selector(writetofile), userInfo: nil, repeats: true)
    }
    @IBAction func stopButton(_ sender: UIButton) {
        flag = 0 //Stops the file writing process
        recordingLabel.isHidden = true
        print("\(flag)")
    }
    @IBOutlet weak var filenameInput: UITextField!
    
    @IBOutlet weak var recordingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = ARSession()
        session.delegate = self
        filenameInput.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configuration.frameSemantics = .sceneDepth
        // enable the scene depth frame-semantic.
        filenameInput.resignFirstResponder()
        // Run the view's session
        session.run(configuration)
        
        // The screen shouldn't dim during AR experiences.
        UIApplication.shared.isIdleTimerDisabled = true
        //Instruct the keyboard to hide when return is pressed
        textFieldShouldReturn(filenameInput)
    }
    
    //IMPORTANT FUNCTION: Takes Lidar depth reading (in m) for center pixel on the screen and writes it to a file.
    @objc func writetofile (){
        if flag == 1 {
            //get current Frame
            guard let currentFrame = session.currentFrame else {
                print("empty1")
                return
            }
            //get Frame's sceneDepth data
            guard let sceneDepth = currentFrame.sceneDepth else {
                print("empty2")
                return
            }
            //This code extracts the depth data in meters from sceneDepth
                var pixelBuffer: CVPixelBuffer!
                pixelBuffer = sceneDepth.depthMap
                //code for printing the pixelBuffer on console
               CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
                let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
                //let p = CVPixelBufferGetPixelFormatType(pixelBuffer) I get code fdep, which is correct.
                let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
                let buffer = baseAddress!.assumingMemoryBound(to: Float.self) //BUT the CVPixelBuffer is not UInt8

                //print(CVPixelBufferGetWidth(pixelBuffer))
                //print(CVPixelBufferGetHeight(pixelBuffer))
                //print(CVPixelBufferGetBytesPerRow(pixelBuffer))
                print("----")
                //let index = 101 + 100*bytesPerRow
                print("\(buffer[24832])" + " " + "\(buffer[24833])" + " " + "\(buffer[24834])")
                let depthreading = "\(buffer[24832])" + " " + "\(buffer[24833])"
            do {
                try depthreading.appendLineToURL(fileURL: filename)
                try String(contentsOf: filename, encoding: String.Encoding.utf8)
            }
            catch {
                print("Could not write to file")
            }
            
            //256 columns, 192 rows, 4 bytes per pixel. Centre pixel of screen = position 192/2 * 256*4. I then display each of the bytes corresponding to that pixel
            // I NEED TO FIGURE OUT WHAT THE CENTER PIXEL ACTUALLY IS
            //must unlock the base address
                CVPixelBufferUnlockBaseAddress(pixelBuffer,CVPixelBufferLockFlags(rawValue: 0))
        }
            
}
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    //function for creating file from input
    func createnewfile() -> URL {
        //Have default value in filename. make this a variable
        //while the text on the text input = variable, print that you need to set a filename
        let filename = getDocumentsDirectory().appendingPathComponent(filestring)
        return filename
    }
    //Find the app's documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
//These two extensions are used to append strings to a file
extension String {
    func appendLineToURL(fileURL: URL) throws {
         try (self + "\n").appendToURL(fileURL: fileURL)
     }

     func appendToURL(fileURL: URL) throws {
         let data = self.data(using: String.Encoding.utf8)!
         try data.append(fileURL: fileURL)
     }
 }

 extension Data {
     func append(fileURL: URL) throws {
         if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
             defer {
                 fileHandle.closeFile()
             }
             fileHandle.seekToEndOfFile()
             fileHandle.write(self)
         }
         else {
             try write(to: fileURL, options: .atomic)
         }
     }
 }
