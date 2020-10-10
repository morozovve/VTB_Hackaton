//
//  ViewController.swift
//  CarScanner
//
//  Created by Helga on 09.10.2020.
//  Copyright © 2020 Olga Mikhnenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {
    @IBOutlet weak var OnToPersonalButton: UIButton!
    @IBAction func OnToPersonalButton(_ sender: Any) {
        performSegue(withIdentifier: "OnboardingToPersonal", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

