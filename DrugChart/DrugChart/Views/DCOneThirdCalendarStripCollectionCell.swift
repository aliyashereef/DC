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
    var indicatorImageView : UIImageView = UIImageView()
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
        
        dateLabel.backgroundColor = UIColor(forHexString: "#007aff")
        dateLabel.textColor = UIColor.whiteColor()
        dateLabel.layer.cornerRadius = 14
        dateLabel.layer.masksToBounds = true
        self.layoutSubviews()
    }
    
    func showCurrentCalendarSelection() {
        
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
        
        dateLabel.backgroundColor = UIColor(forHexString: "#1e1e1e")
        dateLabel.textColor = UIColor.whiteColor()
        dateLabel.layer.cornerRadius = 14
        dateLabel.layer.masksToBounds = true
        self.layoutSubviews()

    }

}