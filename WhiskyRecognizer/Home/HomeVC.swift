//
//  HomeVC.swift
//  WhiskyRecognizer
//
//  Created by Akshay Bharath on 4/23/18.
//  Copyright © 2018 Akshay Bharath. All rights reserved.
//

import Action
import RxCocoa
import RxSwift
import SnapKit
import UIKit

class HomeVC: UIViewController {
    
    var viewModel: HomeVM?
    
    private let disposeBag = DisposeBag()
    
    private let watsonAPIKey = "72e8118cce72fac81547522406fe2528a2cc1839"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGray
    }
}

extension HomeVC: BindableType {
    func bindViewModel() {
        
    }
}
