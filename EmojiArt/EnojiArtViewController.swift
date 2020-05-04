//
//  EnojiArtViewController.swift
//  EmojiArt
//
//  Created by kerollos nabil on 4/25/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import UIKit

class EnojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate {

    var emojiAetView = EmojiArtView()
    var imageFeacher:ImageFetcher!
    
    @IBOutlet weak var drobZone: UIView!{
        didSet{
            drobZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    @IBOutlet weak var imageScrollView: UIScrollView!{
        didSet{
            imageScrollView.maximumZoomScale = 5.0
            imageScrollView.minimumZoomScale = 0.1
            imageScrollView.delegate = self
            imageScrollView.addSubview(emojiAetView)

        }
    }
    @IBOutlet weak var widthOfScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var hightOfScrollView: NSLayoutConstraint!
    
    
    var emojiArtBackgeound: UIImage? {
        get{
            return emojiAetView.backGround
        }set{
            imageScrollView.zoomScale = 1.0
            emojiAetView.backGround = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiAetView.frame = CGRect(origin: CGPoint.zero, size: size)
            imageScrollView.contentSize = size
            widthOfScrollView.constant = size.width
            hightOfScrollView.constant = size.height
            if size.width > 0, size.height > 0{
                imageScrollView.zoomScale = max(drobZone.bounds.width/size.width, drobZone.bounds.height/size.height)
            }
        }
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        widthOfScrollView.constant = scrollView.contentSize.width
        hightOfScrollView.constant = scrollView.contentSize.height
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiAetView
    }
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFeacher = ImageFetcher(){(url, image) in
            DispatchQueue.main.async {
                self.emojiArtBackgeound = image
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
