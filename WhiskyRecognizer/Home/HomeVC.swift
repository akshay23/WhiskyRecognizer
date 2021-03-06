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
import VisualRecognitionV3

class HomeVC: UIViewController {
    
    var viewModel: HomeVM?
    
    private let disposeBag = DisposeBag()
    
    private let watsonAPIKey = "MI2jhoSFMejmwMd4YZRvIgeV7UG9DJNGEVwja_AygwBg"
    private let modelVersion = "2018-12-01"
    private let classifierID = "Nov2018Model_2142877123"
    private var visualRecognition: VisualRecognition!
    
    private let imageView = UIImageView()
    private var imagePickerButton = UIButton(type: .custom)
    private let resultsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGray
        visualRecognition = VisualRecognition(version: modelVersion, apiKey: watsonAPIKey)
        
        view.addSubview(imageView)
        
        resultsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        resultsLabel.textColor = .black
        resultsLabel.textAlignment = .center
        resultsLabel.numberOfLines = 0
        view.addSubview(resultsLabel)
        
        imagePickerButton.backgroundColor = .black
        imagePickerButton.layer.borderWidth = 1.0
        imagePickerButton.layer.cornerRadius = 6.0
        imagePickerButton.setTitle("Pick Image", for: .normal)
        imagePickerButton.setTitleColor(.blue, for: .highlighted)
        view.addSubview(imagePickerButton)
        
        setupConstraints()
        
        let localModels = try? visualRecognition.listLocalModels()
        if let models = localModels, models.contains(classifierID) {
            print("local model found")
        } else {
            updateModel()
        }
    }

}

private extension HomeVC {

    func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.equalToSuperview()
            make.height.equalTo(500)
        }
        
        imagePickerButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        resultsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imagePickerButton.snp.top).offset(60)
            make.width.equalToSuperview()
        }
    }

    func updateModel() {
        let failure = { error in
            print(error)
        }
        
        let success = {
            print("model updated")
        }
        
        visualRecognition.updateLocalModel(classifierID: classifierID, failure: failure, success: success)
    }
    
    func showImagePicker(withType type: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        present(pickerController, animated: true, completion: nil)
    }
    
    func classifyImage(for image: UIImage, localThreshold: Double = 0.0) {
        
        let success = { [weak self] (classifiedImages: VisualRecognitionV3.ClassifiedImages) in
            var topClassification = ""
            var resultText = "Unable to classify whisky!"
            
            if classifiedImages.images.count > 0,
                classifiedImages.images[0].classifiers.count > 0,
                classifiedImages.images[0].classifiers[0].classes.count > 0 {
                topClassification = classifiedImages.images[0].classifiers[0].classes[0].className
                print("Detected whisky is \(topClassification)")
            }
            
            if !topClassification.isEmpty {
                resultText = "Whisky classified as \(topClassification.capitalizingFirstLetter())"
            }
            
            DispatchQueue.main.async {
                self?.resultsLabel.text = resultText
            }
        }
        
        visualRecognition.classifyWithLocalModel(image: image,
                                                 classifierIDs: [classifierID],
                                                 threshold: localThreshold,
                                                 failure: nil,
                                                 success: success)
    }

}

extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = image
        classifyImage(for: image, localThreshold: 0.70)
    }
    
}

extension HomeVC: BindableType {

    func bindViewModel() {
        imagePickerButton.rx.action = CocoaAction { [weak self] in
            guard let strongSelf = self else { return .empty() }

            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                strongSelf.showImagePicker(withType: .photoLibrary)
                return .empty()
            }
            
            let photoPicker = UIAlertController()
            let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { _ in
                strongSelf.showImagePicker(withType: .camera)
            }
            
            let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { _ in
                strongSelf.showImagePicker(withType: .photoLibrary)
            }
            
            photoPicker.addAction(takePhoto)
            photoPicker.addAction(choosePhoto)
            photoPicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            strongSelf.present(photoPicker, animated: true, completion: nil)
            
            return .empty()
        }
    }

}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
