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

class EnojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UIDocumentBrowserViewControllerDelegate, EmojiArtDelegate {
    
    // MARK: view Delegate
    
    func viewWillChange() {
        emojiArtPrev = emojiArt
    }
    
    func viewHasChanged() {
        if emojiArt != emojiArtPrev{
            emojiViewDidChange(from: emojiArtPrev)
        }
        save()
    }
    
    
    
    // MARK: model
    private var emojiArtPrev: EmojiArt?
    private var emojiArt: EmojiArt?{
        get{
            let url = emojiArtBackgeound.url
            let emojies = emojiAetView.subviews.compactMap {$0 as? UILabel}.compactMap{EmojiArt.emojiDetails(label: $0)}
            return EmojiArt(url: url, emojies: emojies, choises: self.emojisCollectionView.emojies)
            
        }set{
            if let currentEmojis = newValue?.emojiChoises{
                self.emojisCollectionView.emojies = currentEmojis
            }
            self.emojisCollectionView.reloadData()
            emojiAetView.subviews.forEach({
                $0.removeFromSuperview()
            })
            if self.emojiArtBackgeound.image == nil{
                
            
                emojiArtBackgeound = (nil,nil)
                emojiAetView.subviews.forEach({
                    $0.removeFromSuperview()
                })
                if let url = newValue?.url{
                    imageFeacher = ImageFetcher(fetch: url, handler: {(imgUrl, image) in
                        DispatchQueue.main.async {
                            self.emojiArtBackgeound = (imgUrl, image)
                            newValue?.emijies?.forEach({
                                self.emojiAetView.addLabel(with: $0.emoji.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size)), centeredAt: CGPoint(x: $0.x, y: $0.y))
                            })
                            
                        }
                    })
                }
            }else {
                
                newValue?.emijies?.forEach({
                    self.emojiAetView.addLabel(with: $0.emoji.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size)), centeredAt: CGPoint(x: $0.x, y: $0.y))
                })
            }
        }
    }
    
    
    
// MARK: vatiables
    var document:Document?
    private var imageFeacher:ImageFetcher!
    private var _imageUrl: URL?
     // future this needs to be a model
    
    lazy private var emojiAetView:EmojiArtView = {
        var viw = EmojiArtView()
        viw.delegate = self
        return viw
    }()
    
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
            emojiAetView.subviews.compactMap {$0 as? UILabel}.forEach{$0.removeFromSuperview()}
        }
    }
    // MARK: outlets
    @IBOutlet weak var deleteButton: UIButton!{
        didSet{
            deleteButton.addInteraction(UIDropInteraction(delegate: self))
        }
    }
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
    @IBOutlet weak var emojisCollectionView: EmojiCollection!{
        didSet{
            emojisCollectionView.viewDelegate = self
        }
    }
    @IBOutlet weak var widthOfScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var hightOfScrollView: NSLayoutConstraint!
    @IBOutlet weak var undoButton: UIBarButtonItem!{
        didSet{
            undoButton.isEnabled = document?.undoManager.canUndo ?? false
        }
    }
    
    @IBOutlet weak var redoButton: UIBarButtonItem!{
        didSet{
            redoButton.isEnabled = document?.undoManager.canRedo ?? false
        }
    }
    
    // MARK: actions
    
    @IBAction func redo(_ sender: UIBarButtonItem) {
        
            document?.undoManager.redo()
        
    }
    
    @IBAction func undo(_ sender: UIBarButtonItem) {
//        if emojiArt != emojiArtPrev{
            document?.undoManager.undo()
//        }
    }
    
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
    
    
    
    @IBAction func saveImage(_ sender: UIBarButtonItem) {
        
        guard let image = emojiAetView.snapshot else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @IBAction func deleteEmoji(_ sender: UIButton) {
        let labels = emojiAetView.subviews.compactMap {$0 as? UILabel}
        for label in labels{
            if label.layer.borderWidth == 1 {
                viewWillChange()
                label.removeFromSuperview()
                viewHasChanged()
            }
        }
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
    
    //MARK: life sicles
    
    
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        resignFirstResponder()
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    // MARK: redo/undo
    
    private func emojiViewDidChange(from fromEmojiArt: EmojiArt?) {
        
        document?.undoManager.registerUndo(withTarget: self) { target in
            if let currentStateOfEmojiArt = self.emojiArt {
                self.emojiArt = fromEmojiArt
                if currentStateOfEmojiArt != fromEmojiArt{
                    self.emojiViewDidChange(from: currentStateOfEmojiArt)
                    
                }
                self.viewHasChanged()
            }
        }
        if let undoo = document?.undoManager.canUndo {
            self.undoButton.isEnabled = undoo
        }
        if let redoo = document?.undoManager.canRedo {
            self.redoButton.isEnabled = redoo
        }
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
        return (session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)) || session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        return UIDropProposal(operation:((session.localDragSession?.localContext as? UICollectionView) == emojisCollectionView) ? .move : .copy)
        
//        return UIDropProposal(operation: .copy)
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
        session.loadObjects(ofClass: NSAttributedString.self, completion: { strings in
            for string in strings as? [NSAttributedString] ?? []{
                self.viewWillChange()
                if let index = self.emojisCollectionView.emojies.firstIndex(of: string.string){
                    self.emojisCollectionView.performBatchUpdates({
                        self.emojisCollectionView.emojies.remove(at: index)
                        self.emojisCollectionView.deleteItems(at: [IndexPath(item: index, section: 1)])
                    })
                }
                self.viewHasChanged()
            }
        })
    }
  
}
