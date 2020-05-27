//
//  EnojiArtViewController.swift
//  EmojiArt
//
//  Created by kerollos nabil on 4/25/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import UIKit


extension EmojiArt.emojiDetails{
    init?(label: UILabel) {
        if let string = label.attributedText?.string, let font = label.attributedText?.font{
            x = Double(label.center.x)
            y = Double(label.center.y)
            size = Double(font.pointSize)
            emoji = string
        }else {
            return nil
        }
        
    }
}

class EnojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIDocumentBrowserViewControllerDelegate, EmojiArtDelegate {
    func viewHasChanged() {
        save()
    }
    
    
    
    // MARK: model
    
    private var emojiArt: EmojiArt?{
        get{
            if let url = emojiArtBackgeound.url {
                let emojies = emojiAetView.subviews.compactMap {$0 as? UILabel}.compactMap{EmojiArt.emojiDetails(label: $0)}
                return EmojiArt(url: url, emojies: emojies)
            }
            return nil
        }set{
            emojiArtBackgeound = (nil,nil)
            emojiAetView.subviews.forEach({
                $0.removeFromSuperview()
            })
            if let url = newValue?.url{
                imageFeacher = ImageFetcher(fetch: url, handler: {(imgUrl, image) in
                    DispatchQueue.main.async {
                        self.emojiArtBackgeound = (imgUrl, image)
                        newValue?.emijies.forEach({
                            self.emojiAetView.addLabel(with: $0.emoji.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size)), centeredAt: CGPoint(x: $0.x, y: $0.y))
                        })
                        
                    }
                })
            }
        }
    }
    
    
    
// MARK: vatiables
    var document:Document?
    private var takingInput = false
    private var imageFeacher:ImageFetcher!
    private var _imageUrl: URL?
    private var emojies = "😀😁👶👧🧒👦👩👯‍♂️🕴🚶‍♀️🚶‍♂️🐨🐯🦁🐮🐷⚽️🏀🏈⚾️🥎🍏🍎🍐🍊🍋🍌🥐🥯🍞🥖🥨🧀🚗🚙🚕🚌🚎⌚️📱💻⌨️🖥🖨🏳️🏴🏁🚩🏳️‍🌈🏴‍☠️🇦🇫🇦🇽🇦🇱".map {return String($0)} // future this needs to be a model
    
    lazy private var emojiAetView:EmojiArtView = {
        var viw = EmojiArtView()
        viw.delegate = self
        return viw
    }()
    private var font :UIFont{
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(80))
    }
    private var emojiArtBackgeound: (url:URL?, image:UIImage?) {
        get{
            return (_imageUrl, emojiAetView.backGround)
        }set{
            _imageUrl = newValue.url
            imageScrollView.zoomScale = 1.0
            emojiAetView.backGround = newValue.image
            let size = newValue.image?.size ?? CGSize.zero
            emojiAetView.frame = CGRect(origin: CGPoint.zero, size: size)
            imageScrollView.contentSize = size
            widthOfScrollView.constant = size.width
            hightOfScrollView.constant = size.height
            if size.width > 0, size.height > 0{
                imageScrollView.zoomScale = max(drobZone.bounds.width/size.width, drobZone.bounds.height/size.height)
            }
        }
    }
    // MARK: outlets
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
            emojisCollectionView.dragInteractionEnabled = true
        }
    }
    @IBOutlet weak var widthOfScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var hightOfScrollView: NSLayoutConstraint!
    
    
    // MARK: actions
    
    
    func save() {
        document?.emojiArt = emojiArt
        if document?.emojiArt != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        if document?.emojiArt != nil {
            document?.thumbnail = emojiAetView.snapshot
        }
        dismiss(animated: true, completion: {
            self.document?.close()
        })
        
    }
    
    @IBAction func addEmoji(_ sender: Any) {
        takingInput = true
        emojisCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    @IBAction func saveImage(_ sender: UIBarButtonItem) {
        
        guard let image = emojiAetView.snapshot else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let imageView = UIImageView(image: image)
            imageView.frame = emojiAetView.frame
            emojiAetView.addSubview(imageView)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.6,
                delay: 0.0,
                options: [],
                animations: {
                    imageView.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
            }) { (posstion) in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.8,
                    delay: 0.0,
                    options: [],
                    animations: {
                        imageView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                        imageView.alpha = 0
                }) { (posstion) in
                    imageView.removeFromSuperview()
                }
            }
        }
    }
    
    //MAEK: life sicles
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > 0, size.height > 0{
            imageScrollView.zoomScale = max(drobZone.bounds.width/size.width, drobZone.bounds.height/size.height)
        }
//        emojiAetView.setNeedsLayout()
//        emojiAetView.setNeedsDisplay()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        document?.open(completionHandler: { (success) in
            if success{
                self.title = self.document?.localizedName
                self.emojiArt = self.document?.emojiArt
            }
        })
    }
    
    // MARK: scrollview methods
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        widthOfScrollView.constant = scrollView.contentSize.width
        hightOfScrollView.constant = scrollView.contentSize.height
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiAetView
    }
    // MARK: dropzone methosd
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFeacher = ImageFetcher(){(url, image) in
            DispatchQueue.main.async {
                self.emojiArtBackgeound = (url, image)
                self.viewHasChanged()
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
    
    
    
    
    // MARK: collection view delegate
    
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
            print(cell.frame)
            if let inputCell = cell as? InputCollectionViewCell{
                inputCell.InputField.sizeToFit()
                inputCell.InputField.frame = cell.frame
                inputCell.resignationHandeler = {[weak self, unowned inputCell] in
                    if let text = inputCell.InputField.text {
                        self?.emojies = (text.map({String($0)}) + self!.emojies).uniquified
                         
                    }
                    self?.takingInput = false
                    self?.emojisCollectionView.reloadData()
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
            return CGSize(width: 400, height: 110)
        }else{
            return CGSize(width: 110, height: 110)
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
        if !takingInput, let attrStr = (emojisCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojiLabel.attributedText{
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
