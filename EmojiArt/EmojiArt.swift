//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by MAC on 5/21/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import Foundation


struct EmojiArt : Codable{
    var url:URL
    var emijies = [emojiDetails]()
    
    var jason: Data?{
        return try? JSONEncoder().encode(self)
    }
    
    struct emojiDetails:Codable{
        let emoji:String
        let x:Double
        let y:Double
        let size:Double
        
    }
    init?(json:Data) {
        if let data = try? JSONDecoder().decode(EmojiArt.self, from: json){
            self = data
        }else{
            return nil
        }
    }
    init(url:URL, emojies:[emojiDetails]) {
        self.url = url
        self.emijies = emojies
    }
}
