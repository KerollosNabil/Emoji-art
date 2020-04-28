//
//  EnojiArtViewController.swift
//  EmojiArt
//
//  Created by kerollos nabil on 4/25/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import UIKit

class EnojiArtViewController: UIViewController, UIDropInteractionDelegate {

    @IBOutlet weak var drobZone: UIView!{
        didSet{
            drobZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    @IBOutlet weak var emojiAetView: EmojiArtView!
    var imageFeacher:ImageFetcher!
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFeacher = ImageFetcher(){(url, image) in
            DispatchQueue.main.async {
                self.emojiAetView.backGround = image
            }
            
        }
        session.loadObjects(ofClass: NSURL.self, completion: { nsurls in
            if let url = nsurls.first as? URL{
                self.imageFeacher.fetch(url)
            }
        })
        session.loadObjects(ofClass: UIImage.self, completion: { images in
            if let image = images.first as? UIImage{
                self.imageFeacher.backup = image
            }
        })
    }
    
}
