//
//  EnojiArtViewController.swift
//  EmojiArt
//
//  Created by kerollos nabil on 4/25/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import UIKit

class EnojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    
    
    
    
    
//vatiables
    private var emojiAetView = EmojiArtView()
    private var imageFeacher:ImageFetcher!
    private var emojies = "😀😁👶👧🧒👦👩👯‍♂️🕴🚶‍♀️🚶‍♂️🐨🐯🦁🐮🐷⚽️🏀🏈⚾️🥎🍏🍎🍐🍊🍋🍌🥐🥯🍞🥖🥨🧀🚗🚙🚕🚌🚎⌚️📱💻⌨️🖥🖨🏳️🏴🏁🚩🏳️‍🌈🏴‍☠️🇦🇫🇦🇽🇦🇱".map {return String($0)} // future this needs to be a model
    
    private var font :UIFont{
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(100))
    }
    private var emojiArtBackgeound: UIImage? {
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
    //outlets
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
    @IBOutlet weak var emojisCollectionView: UICollectionView!{
        didSet{
            emojisCollectionView.dataSource = self
            emojisCollectionView.delegate = self
            emojisCollectionView.dragDelegate = self
            emojisCollectionView.dropDelegate = self
        }
    }
    @IBOutlet weak var widthOfScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var hightOfScrollView: NSLayoutConstraint!
    
    
    
    
    //scrollview methods
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        widthOfScrollView.constant = scrollView.contentSize.width
        hightOfScrollView.constant = scrollView.contentSize.height
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiAetView
    }
    //dropzone methosd
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
    
    
    
    
    //collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            emojiCell.emojiLabel.attributedText = NSAttributedString(string: emojies[indexPath.row], attributes: [.font:font])
            return emojiCell
        }
        
        return cell
    }
    
    
    
//    drag interaction methods
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    private func dragItems(at indexPath:IndexPath) -> [UIDragItem]{
        if let attrStr = (emojisCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojiLabel.attributedText{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attrStr))
            dragItem.localObject = attrStr
            return [dragItem]
        }else{
            return []
        }
    }
    //drop interaction
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: ((session.localDragSession?.localContext as? UICollectionView) == collectionView) ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destenationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in  coordinator.items {
            if let sourceIndexPath =  item.sourceIndexPath {
                if let attrStr = item.dragItem.localObject as? NSAttributedString{
                    collectionView.performBatchUpdates({
                        emojies.remove(at: sourceIndexPath.item)
                        emojies.insert(attrStr.string , at: destenationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destenationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destenationIndexPath)
                }
                
            }else {
                let contextPlaceHolde = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destenationIndexPath, reuseIdentifier: "EmojiPlaceHolder"))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, erroe) in
                    DispatchQueue.main.async {
                        if let attrStr = provider as? NSAttributedString{
                            contextPlaceHolde.commitInsertion { (placeHolderIndexPath) in
                                self.emojies.insert(attrStr.string, at: placeHolderIndexPath.item)
                            }
                        }else{
                            contextPlaceHolde.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
}
