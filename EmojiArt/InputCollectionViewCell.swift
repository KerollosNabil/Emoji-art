//
//  InputCollectionViewCell.swift
//  EmojiArt
//
//  Created by MAC on 5/20/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import UIKit

class InputCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    
    @IBOutlet weak var InputField: UITextField!{
        didSet{
            InputField.delegate = self
            
        }
    }
    var resignationHandeler : (()->Void)?
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        resignationHandeler?()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
