//
//  DocumentInfoViewController.swift
//  Emoji Art
//
//  Created by MAC on 6/16/20.
//  Copyright © 2020 MAC. All rights reserved.
//

import UIKit

class DocumentInfoViewController: UIViewController {

    var document:Document?{
        didSet{
            updateUi()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUi()
        // Do any additional setup after loading the view.
    }
    private let shortDateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    private func updateUi(){
        if sizeLabel != nil, dateLabel != nil, let url = document?.fileURL, let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
            sizeLabel.text = "\(attributes[.size] ?? 0) bytes"
            if let createdDate = attributes[.creationDate] as? Date {
                dateLabel.text = shortDateFormatter.string(from: createdDate)
            }
                
        }
        if thumbNailImage != nil, let image = document?.thumbnail {
            thumbNailImage.image = image
        }
        if presentationController is UIPopoverPresentationController {
            thumbNailImage?.isHidden = true
            rettrnButton?.isHidden = true
            self.view.backgroundColor = .clear
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fitSize = topLevelStack.sizeThatFits(UIView.layoutFittingCompressedSize)
        preferredContentSize = CGSize(width: fitSize.width + 30, height: fitSize.height+30)
        
    }
    @IBOutlet weak var topLevelStack: UIStackView!
    @IBAction func done() {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBOutlet weak var rettrnButton: UIButton!
    @IBOutlet weak var imageAspect: NSLayoutConstraint!
    @IBOutlet weak var thumbNailImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var sizeLabel: UILabel!
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
