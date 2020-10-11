//
//  OfferingsViewController.swift
//  CarScanner
//
//  Created by Виктор Морозов on 10.10.2020.
//  Copyright © 2020 Olga Mikhnenko. All rights reserved.
//

import UIKit

struct CarOffer {
    var brand: String = ""
    var model: String = ""
    var photo: String = ""
    var minPrice: Int = 0
    var ownTitle: String = "" // additional info aka "III Restyling"
}

class OfferingsViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    var clientInfo: ClientInfo!
    var carName: String! = "<Model>"
    var mp: Float! = 0.0
    @IBOutlet weak var carOffers: UILabel!
    
    var marketplaceJSON: [String: Any] = [:]
    
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carPrice: UILabel!
    @IBOutlet weak var firstPayment: UILabel!
    @IBOutlet weak var firstPaymentSlider: UISlider!
    @IBOutlet weak var loanDuration: UILabel!
    @IBOutlet weak var loanDuraionSlider: UISlider!
    @IBOutlet weak var monthlyPayment: UILabel!
    @IBOutlet weak var interestRate: UILabel!
    @IBAction func firstPaymentSliderChanged(_ sender: Any) {
        self.updateLabels()
    }
    @IBAction func loadDurationSliderChanged(_ sender: Any) {
        self.updateLabels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.titleLabel.text! + self.carName
        // Do any additional setup after loading the view.
        self.loadMarketplace()
    }
    
    func loadMarketplace() {
        let headers = [
          "x-ibm-client-id": "145bbeeb2ced2458ac29ee529cc22452",
          "accept": "application/json"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://gw.hackathon.vtb.ru/vtb/hackathon/marketplace")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error!)
          } else {
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse!)
            self.marketplaceJSON = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]
            self.searchMarketplace()
          }
        })
        dataTask.resume()
    }
    
    func searchMarketplace()
    {
//        self.carName = "Mazda 6 sedan"
        var model = self.carName.components(separatedBy: " ").first
        if model == "Land" {
            model = "Land Rover"
        }
        var subtype: String = ""
        switch model {
        case "Land Rover":
            subtype = "RANGE ROVER VELAR"
        case "BMW":
            subtype = "\(self.carName.components(separatedBy: " ")[1]) серии"
        default:
            subtype = self.carName.components(separatedBy: " ")[1]
        }
        let isSedan: Bool! = self.carName.contains("sedan")

        print("model: \(model!), subtype: \(subtype)")
        var candidates: [CarOffer] = []

        let available_cars = self.marketplaceJSON["list"] as! [[String: Any]]
        for brand in available_cars {
            print("New brand: \(brand["title"])")
            if (brand["title"] as! String) == model {
                print("Brand matching!")
                for car in (brand["models"] as! [[String: Any]] ){
                    print("New model: \(car["title"])")
                    if car["title"] as! String == subtype {
                        print("Model matching!")
                        if isSedan && (car["bodies"] as! [[String: Any]])[0]["type"] as! String != "sedan" {
                            print("[E] Expected sedan, got \((car["bodies"] as! [[String: Any]])[0]["type"])")
                            continue
                        }
                        candidates.append(CarOffer(brand: model!, model: subtype, photo: car["photo"] as! String, minPrice: car["minPrice"] as! Int, ownTitle: car["ownTitle"] as! String))
                    }
                }
            }
        }
        print("Found \(candidates.count) candidates...")
        for cand in candidates {
            print("Candidate: [\(model) \(subtype) \(cand.ownTitle): \(String(cand.minPrice))]")
        }
        DispatchQueue.main.async {
            if candidates.count >= 1 {
                self.drawOffers(candidates: candidates)
            } else {
                self.carOffers.text = "Не удалось найти \(self.carName!)"
                self.carPrice.isHidden = true
                self.loanDuration.isHidden = true
                self.firstPaymentSlider.isHidden = true
                self.loanDuraionSlider.isHidden = true
                self.firstPayment.isHidden = true
                self.monthlyPayment.isHidden = true
                self.carImage.isHidden = true
                self.interestRate.isHidden = true
            }
        }
        
    }
    
    func drawOffers(candidates: [CarOffer]){
        
        let cand = candidates[0]
        self.carOffers.text = "\(cand.brand) \(cand.model) \(cand.ownTitle)"
        self.carPrice.text = self.carPrice.text! + "\(cand.minPrice) р."
        let mp = Float(cand.minPrice)
        self.mp = mp
        self.firstPaymentSlider.minimumValue = mp / 10.0
        self.firstPaymentSlider.maximumValue = mp / 1.2
        self.firstPaymentSlider.value = mp / 3
        self.firstPayment.text = "Первоначальный взнос: \(Int(mp / 3)) р."
        self.monthlyPayment.text = self.monthlyPayment.text! + "\(Int(mp - (mp/3)) / 12) р."
        
        // Load Image:
        self.carImage.load(url: URL(string: cand.photo)!)
    }
    
    func updateLabels()
    {
        let dur :Float = self.loanDuraionSlider.value
        let fpay :Float = self.firstPaymentSlider.value
        
        self.loanDuration.text = "Срок кредита: \(Int(dur)) мес."
        self.firstPayment.text = "Первоначальный взнос: \(Int(fpay)) р."
        self.monthlyPayment.text = "Ежемесячный платеж: \(Int((self.mp - fpay) / dur.rounded(.towardZero))) р."
    }
        // Do any additional setup after loading the view.
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
