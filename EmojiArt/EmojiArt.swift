//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by MAC on 5/21/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import Foundation


struct EmojiArt {
    var url:URL
    var emijies = [emojiDetails]()
    
    struct emojiDetails{
        let emoji:String
        let x:Double
        let y:Double
        let size:Double
        
    }
    init(url:URL, emojies:[emojiDetails]) {
        self.url = url
        self.emijies = emojies
    }
}
