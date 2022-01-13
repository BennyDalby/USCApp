//
//  ImageCollectionViewCell.swift
//  USC Visual Supply
//
//  Created by benny dalby on 11/27/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    var checkMark = UIImageView()
    
    var isInEditingMode: Bool = false {
        didSet {
            checkMark.isHidden = !isInEditingMode
        }
    }
    
    
    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                
                checkMark.isHidden = !isInEditingMode
            }
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       
        imageView.frame = self.bounds
        checkMark.image = UIImage(named: "checkmark")
        
        checkMark.frame = CGRect(x: 5, y: self.frame.height - 5, width: 70, height: 70)
        
        self.addSubview(imageView)
        self.addSubview(checkMark)
    
    }

}
