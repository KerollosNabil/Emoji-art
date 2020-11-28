//
//  EmojiCollection.swift
//  Emoji Art
//
//  Created by MAC on 6/1/20.
//  Copyright © 2020 MAC. All rights reserved.
//

import UIKit

class EmojiCollection: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.dataSource = self
        self.delegate = self
        self.dragDelegate = self
        self.dropDelegate = self
        self.dragInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
        self.dragDelegate = self
        self.dropDelegate = self
        self.dragInteractionEnabled = true
    }
    
    
//    @IBOutlet weak var addButton: UIButton!{
//        didSet{
//            addButton.titleLabel?.font = font
//        }
//    }
//    
    @IBAction func addEmoji(_ sender: Any) {
        takingInput = true
        self.reloadSections(IndexSet(integer: 0))
    }
    
    var viewDelegate:EmojiArtDelegate?
    private var takingInput = false
    var font :UIFont{
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(self.frame.height*0.7))
    }
    var emojies = "😀😁👶👧🧒👦👩👯‍♂️🕴🚶‍♀️🚶‍♂️🐨🐯🦁🐮🐷⚽️🏀🏈⚾️🥎🍏🍎🍐🍊🍋🍌🥐🥯🍞🥖🥨🧀🚗🚙🚕🚌🚎⌚️📱💻⌨️🖥🖨🏳️🏴🏁🚩🏳️‍🌈🏴‍☠️🇦🇫🇦🇽🇦🇱".map {return String($0)}
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return emojies.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            if let emojiCell = cell as? EmojiCollectionViewCell {
                emojiCell.emojiLabel.attributedText = NSAttributedString(string: emojies[indexPath.row], attributes: [.font:font])
                return emojiCell
            }
            
            return cell
        }else if takingInput {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputCell", for: indexPath)
            if let inputCell = cell as? InputCollectionViewCell{
                inputCell.InputField.sizeToFit()
                inputCell.InputField.frame = cell.frame
                inputCell.resignationHandeler = {[weak self, unowned inputCell] in
                    self?.viewDelegate?.viewWillChange()
                    if let text = inputCell.InputField.text {
                        self?.emojies = (text.map({String($0)}) + self!.emojies).uniquified
                         
                    }
                    self?.takingInput = false
                    self?.reloadData()
                    self?.viewDelegate?.viewHasChanged()
                }
            
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmohiButtonCell", for: indexPath)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0, takingInput {
            return CGSize(width: self.frame.width/2, height: self.frame.height)
        }else{
            return CGSize(width: self.frame.height, height: self.frame.height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let inputCell = cell as? InputCollectionViewCell{
            inputCell.InputField.becomeFirstResponder()
        }
    }
    
    
    // MARK: drag interaction methods
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    private func dragItems(at indexPath:IndexPath) -> [UIDragItem]{
        if !takingInput, let attrStr = (self.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojiLabel.attributedText{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attrStr))
            dragItem.localObject = attrStr
            return [dragItem]
        }else{
            return []
        }
    }
    // MARK: drop interaction
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath?.section == 1 {
            return UICollectionViewDropProposal(operation: ((session.localDragSession?.localContext as? UICollectionView) == collectionView) ? .move : .copy, intent: .insertAtDestinationIndexPath)
        }else{
            return  UICollectionViewDropProposal(operation: .cancel)
        }
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destenationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in  coordinator.items {
            viewDelegate?.viewWillChange()
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
        viewDelegate?.viewHasChanged()
    }

}
