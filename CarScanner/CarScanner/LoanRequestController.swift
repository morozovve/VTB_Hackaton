//
//  LoanRequestController.swift
//  CarScanner
//
//  Created by Виктор Морозов on 11.10.2020.
//  Copyright © 2020 Olga Mikhnenko. All rights reserved.
//

import UIKit

class LoanRequestController: UIViewController {
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    var status: Int! = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateStatus()
        // Do any additional setup after loading the view.
    }
    func updateStatus() {
        switch self.status {
        case 1:
            self.statusImg.image = UIImage(systemName: "checkmark.seal.fill")
            self.statusLabel.text = "Поздравляем! Заявка на кредит одобрена"
        case -1:
            self.statusLabel.text = "К сожалению, заявка не была одобрена."
            self.statusImg.image = UIImage(systemName: "clear.fill")
        default:
            break
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
