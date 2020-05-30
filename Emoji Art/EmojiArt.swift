//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by MAC on 5/21/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import Foundation


struct EmojiArt : Codable, Equatable{
    static func == (lhs: EmojiArt, rhs: EmojiArt) -> Bool {
        return lhs.url == rhs.url && lhs.emijies == rhs.emijies && lhs.emojiChoises == rhs.emojiChoises
    }
    
    var url:URL?
    var emijies: [emojiDetails]?
    var emojiChoises: [String]?
    var jason: Data?{
        return try? JSONEncoder().encode(self)
    }
    
    struct emojiDetails:Codable, Equatable{
        static func == (lhs: emojiDetails, rhs: emojiDetails) -> Bool {
            return lhs.emoji == rhs.emoji && lhs.x == rhs.x && lhs.y == rhs.y && lhs.size == rhs.size
        }
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
    init(url:URL?, emojies:[emojiDetails], choises:[String]) {
        self.url = url
        self.emijies = emojies
        self.emojiChoises = choises
    }
}
