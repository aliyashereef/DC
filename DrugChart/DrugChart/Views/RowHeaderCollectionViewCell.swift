//
//  RowHeaderCollectionViewCell.swift
//  DrugChart
//
//  Created by Noureen on 24/11/2015.
//
//

import UIKit

class RowHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell()
    {
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
}
