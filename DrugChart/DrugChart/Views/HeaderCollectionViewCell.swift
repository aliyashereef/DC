//
//  DateCollectionViewCell.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 09/01/2015.
//  Copyright (c) 2015 brightec. All rights reserved.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell()
    {
       // self.backgroundColor = UIColor.whiteColor()
      //  self.dateLabel.font = UIFont.systemFontOfSize(13)
      //  self.dateLabel.textColor = UIColor.blackColor()
        self.layer.borderWidth = 0.75
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
}
