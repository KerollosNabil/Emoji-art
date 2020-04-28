//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by kerollos nabil on 4/25/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {

    var backGround:UIImage?{
        didSet{
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
        backGround?.draw(in: bounds)
    }
    

}
