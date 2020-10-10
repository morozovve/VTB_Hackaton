//
//  ViewController.swift
//  CarScanner
//
//  Created by Helga on 09.10.2020.
//  Copyright © 2020 Olga Mikhnenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var slides:[Slide] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        slides = createSlides()
        setupSlideScrollView(slides: slides)

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        scrollView.delegate = self
        view.bringSubviewToFront(pageControl)
    }

    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = false
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    func createSlides() -> [Slide] {
       
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.OnboardingIcon.image = UIImage(named: "icons8-camera-96 (1)")
        slide1.Description.text = "Сфотографируйте автомобиль"
        slide1.FinishButton.isHidden = true

        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.OnboardingIcon.image = UIImage(named: "icons8-offer-hot-price-96")
        slide2.Description.text = "Узнайте, как получить оптимальное кредитное предложение"
        slide2.FinishButton.isHidden = false

        return [slide1, slide2]
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
            pageControl.currentPage = Int(pageIndex)
        }
}

