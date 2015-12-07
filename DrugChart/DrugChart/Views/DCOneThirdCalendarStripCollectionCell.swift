//
//  DCOneThirdCalendarStripCollectionCell.swift
//  DrugChart
//
//  Created by aliya on 27/11/15.
//
//

import Foundation

class DCOneThirdCalendarStripCollectionCell: UICollectionViewCell {

    var indicatorLabel: UILabel = UILabel()
    var displayDate : NSDate?
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
            self.layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func addTodayIndicationForCellWithoutSelection () {
        indicatorLabel.removeFromSuperview()
        dateLabel.textColor = UIColor(forHexString: "#007aff")
    }
    
    func addTodayIndicatorForCellWithSelection() {
        
        let today : NSDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateLabel.textColor = UIColor.blackColor()
        dateFormatter.dateFormat = DAY_DATE_FORMAT as String
        let dateString = dateFormatter.stringFromDate(today)
        indicatorLabel.frame = CGRectMake(0,0, 20, 20)
        indicatorLabel.center =  dateLabel.center
        indicatorLabel.font = UIFont.systemFontOfSize(13)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.text = dateString
        indicatorLabel.backgroundColor = UIColor(forHexString: "#007aff")
        indicatorLabel.layer.cornerRadius = 10
        indicatorLabel.layer.masksToBounds = true
        self.addSubview(indicatorLabel)
        self.bringSubviewToFront(indicatorLabel)
    }
    
    func showSelection () {
        
        let today : NSDate = NSDate()
        let order = NSCalendar.currentCalendar().compareDate(displayDate! , toDate:today,
            toUnitGranularity: .Day)
        if order != NSComparisonResult.OrderedSame {
            self.showSelectionCurrentlySelectedDate()
        } else {
            self.addTodayIndicatorForCellWithSelection()
        }
    }
    
    func showSelectionCurrentlySelectedDate () {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DAY_DATE_FORMAT as String
        let dateString = dateFormatter.stringFromDate(displayDate!)
        dateLabel.textColor = UIColor.blackColor()
        indicatorLabel.frame = CGRectMake(0,0, 20, 20)
        indicatorLabel.center =  dateLabel.center
        indicatorLabel.font = UIFont.systemFontOfSize(13)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.text = dateString
        indicatorLabel.backgroundColor = UIColor(forHexString: "#1e1e1e")
        indicatorLabel.layer.cornerRadius = 10
        indicatorLabel.layer.masksToBounds = true
        self.addSubview(indicatorLabel)
        self.bringSubviewToFront(indicatorLabel)
    }

}