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
    func configureFullTabularCell(date:NSDate)
    {
        removeIndicator()
        dateLabel.layer.borderWidth = 0
        timeLabel.layer.borderWidth = 0
        dayLabel.text = date.getFormattedDayoftheWeek()
        timeLabel.text = date.getFormattedTime()
        dateLabel.text = "  " + date.getFormattedDay()
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
        dateLabel.textColor  = UIColor(forHexString: "#007aff")
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
    
    
    func configureOneThirdTabularCell(date:NSDate)
    {
        removeIndicator()
        dateLabel.layer.borderWidth = 0
        timeLabel.layer.borderWidth = 0
        dayLabel.text = date.getFormattedDayoftheWeek()
        timeLabel.text = date.getFormattedTime()
        dateLabel.text = "  " + date.getFormattedDay()
        changeBackgroundColor(Constant.SELECTION_CELL_BACKGROUND_COLOR)
        if(date.isToday())
        {
            dateLabel.textColor  = UIColor(forHexString: "#007aff")
        }
        else
        {
            dateLabel.textColor = UIColor.blackColor()
        }
    }
    func setSelectionIndicators(date:NSDate)
    {
        indicatorLabel = UILabel()
        indicatorLabel.frame = CGRectMake(5, 4, 25, 25)
        indicatorLabel.font = UIFont.systemFontOfSize(17)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.text = date.getFormattedDay()
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.layer.cornerRadius = 12.5
        indicatorLabel.layer.masksToBounds = true
        
        if(date.isToday())
        {
            indicatorLabel.backgroundColor = UIColor(forHexString: "#007aff")
            dateLabel.textColor  = UIColor.blueColor()
        }
        else
        {
            indicatorLabel.backgroundColor = UIColor.blackColor()
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
        dateLabel.textColor = UIColor.blackColor()
        if(indicatorLabel != nil)
        {
            indicatorLabel.removeFromSuperview()
        }
    }
}
