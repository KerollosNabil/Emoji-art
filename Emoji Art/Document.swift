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
    var thumbnail: UIImage?
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
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var attribute = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attribute[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attribute
    }
}

