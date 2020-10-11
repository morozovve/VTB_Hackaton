//
//  PersonalInfoControllerViewController.swift
//  CarScanner
//
//  Created by Виктор Морозов on 10.10.2020.
//  Copyright © 2020 Olga Mikhnenko. All rights reserved.
//

import UIKit
struct ClientInfo {
    var name: String = ""
    var income: Int = 0
    var experience: Int = 0
}

class PersonalInfoControllerViewController: UIViewController {
    @IBOutlet weak var PersonalToCameraButton: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var income: UITextField!
    @IBOutlet weak var experience: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false

            view.addGestureRecognizer(tap)
    }
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func PersonalToCameraButton(_ sender: Any) {
        
        // ToDo
        // load & validate personal info
        performSegue(withIdentifier: "PersonalToCamera", sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PersonalToCamera"){
            let VC = segue.destination as! CameraViewController
            let valueToPass: ClientInfo = ClientInfo(name: name.text!, income: Int(income.text!)!, experience: Int(experience.text!)!)
            VC.clientInfo = valueToPass
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
