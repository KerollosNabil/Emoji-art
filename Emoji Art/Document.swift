//
//  Document.swift
//  Emoji Art
//
//  Created by MAC on 5/23/20.
//  Copyright © 2020 MAC. All rights reserved.
//

import UIKit

class Document: UIDocument {
    var emojiArt : EmojiArt?
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return emojiArt?.jason ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        if let json = contents as? Data {
            emojiArt = EmojiArt.init(json: json)
        }
    }
}

