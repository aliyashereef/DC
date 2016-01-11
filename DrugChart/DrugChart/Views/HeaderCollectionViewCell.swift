//
//  DateCollectionViewCell.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 09/01/2015.
//  Copyright (c) 2015 brightec. All rights reserved.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var indicatorLabel: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(date:NSDate)
    {
        dateLabel.layer.borderWidth = 0
        timeLabel.layer.borderWidth = 0
        dateLabel.text = date.getFormattedDayoftheWeek() + " " + date.getFormattedDay()
        timeLabel.text = date.getFormattedTime()
        indicatorLabel.frame = CGRectMake(96, 4, 25, 25)
        indicatorLabel.font = UIFont.systemFontOfSize(17)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.text = date.getFormattedDay()
        
        if(date.isToday())
        {
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.backgroundColor = UIColor(forHexString: "#007aff")
        indicatorLabel.layer.cornerRadius = 12.5
        indicatorLabel.layer.masksToBounds = true
        }
        else
        {
            indicatorLabel.backgroundColor = UIColor.whiteColor()
        }
        self.addSubview(indicatorLabel)
        
    }
}
