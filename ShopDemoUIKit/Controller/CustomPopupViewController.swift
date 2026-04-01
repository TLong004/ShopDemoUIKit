//
//  CustomPopupViewController.swift
//  ShopDemoUIKit
//
//  Created by gem on 1/4/26.
//

import UIKit

class CustomPopupViewController: UIViewController {

    var onSelectSource: ((UIImagePickerController.SourceType) -> Void)?
    
    @IBAction func libraryBtn(_ sender: Any) {
        dismiss(animated: true) {
            self.onSelectSource?(.photoLibrary)
        }
    }
    
    @IBAction func cameraBtn(_ sender: Any) {
        dismiss(animated: true) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.onSelectSource?(.camera)
            }
        }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true)
    }
}
