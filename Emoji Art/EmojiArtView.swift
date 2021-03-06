//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by kerollos nabil on 4/25/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
// dummy

import UIKit

protocol EmojiArtDelegate:class {
    func viewHasChanged()
    func viewWillChange()
}

class EmojiArtView: UIView, UIDropInteractionDelegate {
    
    var delegate:EmojiArtDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setub()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setub()
    }
    private func setub() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { (provider) in
            let dropLocation = session.location(in: self)
            for attrStr in provider as? [NSAttributedString] ?? []{
                self.delegate?.viewWillChange()
                self.addLabel(with: attrStr, centeredAt: dropLocation)
                self.delegate?.viewHasChanged()
            }
        }
    }
    func addLabel(with attrStr: NSAttributedString,centeredAt point :CGPoint ) {
        let label = UILabel()
        label.attributedText = attrStr
        label.backgroundColor = .clear
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)
    }
    
    var backGround:UIImage?{ didSet{setNeedsDisplay()}}
    override func draw(_ rect: CGRect) {
        // Drawing code
        backGround?.draw(in: bounds)
    }
    

}
