//
//  ContentCollectionViewCell.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 09/01/2015.
//  Copyright (c) 2015 brightec. All rights reserved.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell()
    {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        let tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    func doubleTapped() {
                let alert = UIAlertView()
                alert.title = "my title"
                alert.message = "things are working slowly"
                alert.addButtonWithTitle("Ok")
                alert.delegate = self
                alert.show()
    }


}
