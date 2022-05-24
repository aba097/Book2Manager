//
//  CollectionViewCell.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/05/04.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var TitleTextView: UITextView!

    @IBOutlet weak var AuthorTextView: UITextView!
    
    @IBOutlet weak var PublisherTextView: UITextView!
    
    @IBOutlet weak var CommentTextView: UITextView!

    @IBOutlet weak var DeleteButton: UIButton!
    
    weak var vc: DeleteViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DeleteButton.addTarget(self, action: #selector(self.buttonEvent(_:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func buttonEvent(_ sender: UIButton) {
        vc.deleteAction(sender)
    }
    
}
