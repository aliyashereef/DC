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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(date:NSDate)
    {
        dateLabel.layer.borderWidth = 0
        timeLabel.layer.borderWidth = 0
        dateLabel.text = date.getFormattedDayoftheWeek() + "  .."
        timeLabel.text = date.getFormattedTime()
        let indicatorLabel: UILabel = UILabel()
        indicatorLabel.frame = CGRectMake(91, 4, 25, 25)
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
    func removeTimeLabel()
    {
        if(timeLabel != nil)
        {
            timeLabel.removeFromSuperview()
        }
        dateLabel.backgroundColor = UIColor.whiteColor()
        dateLabel.font = UIFont.boldSystemFontOfSize(17)
        //dateLabel.frame = CGRectMake(0, 30, dateLabel.frame.width, dateLabel.frame.height)
        
    }
}
