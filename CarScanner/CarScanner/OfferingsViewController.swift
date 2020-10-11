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
    var loanResponse: Int! = 0
    var ir: Float! = -1.0
    @IBOutlet weak var carOffers: UILabel!
    
    var marketplaceJSON: [String: Any] = [:]
    @IBOutlet weak var backBtn: UIButton!
    @IBAction func backBtnTap(_ sender: Any) {
        self.ir = -1.0
        performSegue(withIdentifier: "CarSearchToCamera", sender: self)
    }
    @IBOutlet weak var sumbitLoat: UIButton!
    @IBAction func submitLoanTap(_ sender: Any) {
        if self.loanResponse == 0 {
            self.sumbitLoat.setTitle("Уточнить статус заявки", for: .normal)
        }
        self.requestAndShowLoan()
    }
    
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
        DispatchQueue.main.async {
            self.loadMarketplace()
        }
    }
    
    func requestAndShowLoan() {
        let dur :Float = self.loanDuraionSlider.value
        let fpay :Float = self.firstPaymentSlider.value
        let headers = [
            "x-ibm-client-id": "145bbeeb2ced2458ac29ee529cc22452",
            "content-type": "application/json",
            "accept": "application/json"
        ]
        let parameters = [
            "comment": "Комментарий",
            "customer_party": [
                "email": "apetrovich@example.com",
                "income_amount": clientInfo.income,
                "person": [
                    "birth_date_time": "1981-11-01",
                    "birth_place": "г. Воронеж",
                    "family_name": "Иванов",
                    "first_name": "Иван",
                    "gender": "female",
                    "middle_name": "Иванович",
                    "nationality_country_code": "RU"
                ],
                "phone": "+99999999999"
            ],
            "datetime": "2020-10-10T08:15:47Z",
            "interest_rate": self.ir * 100 * 12,
            "requested_amount": Int(self.mp - fpay),
            "requested_term": Int(dur),
            "trade_mark": "Nissan",
            "vehicle_cost": Int(self.mp)
        ] as [String : Any]
        print("Params: \(parameters)")
        var postData: Data = Data()
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Cant json-serialize data")
        }
        let request = NSMutableURLRequest(url: NSURL(string: "https://gw.hackathon.vtb.ru/vtb/hackathon/carloan")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse)
                let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any]
//                print(httpResponse!)
                let loan_response = ((json?["application"] as! [String: Any])["decision_report"] as! [String: Any])["application_status"] as! String
                print("Response: \(loan_response)")
                switch loan_response {
                    case "prescore_approved":
                        self.loanResponse = 1
                    case "prescore_denied":
                        self.loanResponse = -1
                    default:
                        self.loanResponse = 0
                }
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CarSearchToSubmit", sender: self)
                }
            }
        })
        
        dataTask.resume()
    }
    func requestIR() {
        let headers = [
            "x-ibm-client-id": "145bbeeb2ced2458ac29ee529cc22452",
            "content-type": "application/json",
            "accept": "application/json"
        ]
        let parameters = [
            "clientTypes": ["ac43d7e4-cd8c-4f6f-b18a-5ccbc1356f75"],
            "cost": Int(self.mp),
            "initialFee": 0,
            "kaskoValue": 0,
            "language": "ru-RU",
            "residualPayment": 0,
            "settingsName": "Haval",
            "specialConditions": ["57ba0183-5988-4137-86a6-3d30a4ed8dc9", "b907b476-5a26-4b25-b9c0-8091e9d5c65f", "cbfc4ef3-af70-4182-8cf6-e73f361d1e68"],
            "term": 5
        ] as [String : Any]
        print("Params:")
        print(parameters)
        var postData: Data = Data()
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Cant json-serialize data")
        }
        let request = NSMutableURLRequest(url: NSURL(string: "https://gw.hackathon.vtb.ru/vtb/hackathon/calculate")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:[String:Any]]
//                print(httpResponse!)
                self.ir = (json?["result"]!["contractRate"] as! NSNumber).floatValue / 100.0 / 12.0
                DispatchQueue.main.async {
                    self.updateLabels()
                }
            }
            
        })
        dataTask.resume()
        print("interestRate = \(self.ir!)")
    }
    
    func calcMonthlyPayment(duration: Float, firstPayment: Float) -> Float{
        let totalSum = self.mp - firstPayment
        let k = (self.ir * pow(1 + self.ir, duration)) / (pow(1 + self.ir, duration) - 1)
        return k * totalSum
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
                if self.ir < 0 && self.mp > 0 {
                    self.requestIR()
                }
            }
        })
        dataTask.resume()
    }
    
    func searchMarketplace()
    {
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
                self.mp = Float(candidates[0].minPrice)
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
        let mp = self.mp!
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
        let mpay = self.calcMonthlyPayment(duration: dur, firstPayment: fpay)
        self.loanDuration.text = "Срок кредита: \(Int(dur)) мес."
        self.firstPayment.text = "Первоначальный взнос: \(Int(fpay)) р."
        self.monthlyPayment.text = "Ежемесячный платеж: \(Int(mpay)) р."
        self.interestRate.text = String(format: "Процентная ставка: %.2f", (self.ir * 12 * 100)) + "%"
        
        self.sumbitLoat.setTitle("Узнать возможность кредитования", for: .normal)

    }
    // Do any additional setup after loading the view.
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation */
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CarSearchToSubmit"){
            let VC = segue.destination as! LoanRequestController
            VC.status = self.loanResponse
        }
        
     }
    
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
