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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HomeVC: BindableType {
    func bindViewModel() {
        
    }
}
