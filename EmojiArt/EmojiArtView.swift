//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by kerollos nabil on 4/25/20.
//  Copyright © 2020 kerollos nabil. All rights reserved.
//

import UIKit

class EmojiArtView: UIView, UIDropInteractionDelegate {
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
                self.addLabel(with: attrStr, coordinateAt: dropLocation)
            }
        }
    }
    func addLabel(with attrStr: NSAttributedString,coordinateAt point :CGPoint ) {
        let label = UILabel()
        label.attributedText = attrStr
        label.backgroundColor = .clear
        label.center = point
        label.sizeToFit()
        addSubview(label)
    }
    
    var backGround:UIImage?{ didSet{setNeedsDisplay()}}
    override func draw(_ rect: CGRect) {
        // Drawing code
        backGround?.draw(in: bounds)
    }
    

}
