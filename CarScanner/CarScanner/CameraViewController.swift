//
//  CameraViewController.swift
//  CarScanner
//
//  Created by Виктор Морозов on 10.10.2020.
//  Copyright © 2020 Olga Mikhnenko. All rights reserved.
//

import UIKit
import Foundation

class CameraViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var chooseImage: UIButton!
    @IBOutlet weak var CameraToCarSearch: UIButton!
    var clientInfo: ClientInfo!
    var recognizedCar: String = "<No Car>"
    
    @IBAction func chooseImageTap(_ sender: Any) {
        self.showChooseSourceTypeAlertController()
    }
    @IBAction func CameraToCarSearchTap(_ sender: Any) {
        if self.recognizedCar != "<No Car>" {
            print(self.recognizedCar)
            performSegue(withIdentifier: "CameraToCarSearch", sender: self)
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "CameraToCarSearch" {
            if self.recognizedCar == "<No Car>" {
                return false
            }
        }
        return true
    }
    
    func showChooseSourceTypeAlertController() {
        let photoLibraryAction = UIAlertAction(title: "Choose a Photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(photoLibraryAction)
        //        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.carImage.image = editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.carImage.image = originalImage.withRenderingMode(.alwaysOriginal)
        }
        dismiss(animated: true, completion: nil)
        self.recognizeCar(image: self.carImage.image!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func recognizeCar(image: UIImage) {
        let data = image.jpegData(compressionQuality: 0.9)!
        let b64Encoded = data.base64EncodedData(options: Data.Base64EncodingOptions(rawValue: 0))
        let b64String = String(data: b64Encoded, encoding: String.Encoding.ascii)
        let headers = [
          "x-ibm-client-id": "145bbeeb2ced2458ac29ee529cc22452",
          "content-type": "application/json",
          "accept": "application/json"
        ]
        let parameters = ["content": b64String!] as [String : Any]

        var postData: Data = Data()
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Cant json-serialize data")
        }
        let request = NSMutableURLRequest(url: NSURL(string: "https://gw.hackathon.vtb.ru/vtb/hackathon/car-recognize")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error!)
          } else {
            let httpResponse = response as? HTTPURLResponse
            let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:[String:Any]]
            print(httpResponse!)
            var car_name: String = ""
            var max_prob: Float = 0.0
            if let dictionary = json!["probabilities"] {
                for (key, value) in dictionary {
                    print("key: \(key), value: \(value)")
                    if (value as! NSNumber).floatValue > max_prob {
                        car_name = key
                        max_prob = (value as! NSNumber).floatValue
                    }
                }
            }
            self.recognizedCar = car_name
            print("Chosen car: \(car_name)")
          }
        })
        dataTask.resume()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CameraToCarSearch"){
            let VC = segue.destination as! OfferingsViewController
            VC.clientInfo = self.clientInfo
            VC.carName = self.recognizedCar
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
