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
    var indicatorLabel: UILabel!
   
    @IBOutlet weak var dayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(date:NSDate)
    {
        removeIndicator()
        dateLabel.layer.borderWidth = 0
        timeLabel.layer.borderWidth = 0
        dayLabel.text = date.getFormattedDayoftheWeek()
        timeLabel.text = date.getFormattedTime()
        indicatorLabel = UILabel()
        indicatorLabel.frame = CGRectMake(5, 4, 25, 25)
        indicatorLabel.font = UIFont.systemFontOfSize(17)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.text = date.getFormattedDay()
        
        if(date.isToday())
        {
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.backgroundColor = UIColor(forHexString: "#007aff")
        indicatorLabel.layer.cornerRadius = 12.5
        indicatorLabel.layer.masksToBounds = true
        self.backgroundColor = Constant.SELECTION_CELL_BACKGROUND_COLOR
        dateLabel.backgroundColor = Constant.SELECTION_CELL_BACKGROUND_COLOR
        timeLabel.backgroundColor = Constant.SELECTION_CELL_BACKGROUND_COLOR
        dayLabel.backgroundColor = Constant.SELECTION_CELL_BACKGROUND_COLOR
        dateLabel.textColor  = UIColor.blueColor()
        }
        else
        {
            indicatorLabel.backgroundColor = UIColor.whiteColor()
            dateLabel.backgroundColor = UIColor.whiteColor()
            timeLabel.backgroundColor = UIColor.whiteColor()
            dayLabel.backgroundColor = UIColor.whiteColor()
            dateLabel.textColor = UIColor.blackColor()
        }
        dateLabel.addSubview(indicatorLabel)
    }
    
    func changeBackgroundColor(backgroundColor:UIColor)
    {
        self.backgroundColor = backgroundColor
        dateLabel.backgroundColor = backgroundColor
        timeLabel.backgroundColor = backgroundColor
        dayLabel.backgroundColor = backgroundColor
    }
    func removeTimeLabel()
    {
        timeLabel.text = ""
        removeIndicator()
    }
    func removeIndicator()
    {
        if(indicatorLabel != nil)
        {
            indicatorLabel.removeFromSuperview()
        }
    }
}
