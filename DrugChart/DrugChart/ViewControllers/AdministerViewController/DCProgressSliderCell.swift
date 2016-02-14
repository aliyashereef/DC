//
//  DCProgressSliderCell.swift
//  DrugChart
//
//  Created by aliya on 12/02/16.
//
//

import Foundation

class DCProgressSliderCell: UITableViewCell {
    
    @IBOutlet var progressView: UIProgressView!
    var endDateView : DCProgressTimeView!
    var medication : DCMedicationSlot?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    func addStartDateView(){
        let startDateView : DCProgressTimeView = NSBundle.mainBundle().loadNibNamed(PROGRESSTIMEVIEW_NIB, owner: self.superview, options: nil)[0] as! DCProgressTimeView
        startDateView.frame = CGRectMake(100,10,40,22)
        startDateView.backgroundColor = UIColor.clearColor()
         let date = DCDateUtility.dateStringFromDate(medication?.medicationAdministration?.scheduledDateTime, inFormat: "dd MMM")
        let time  = DCDateUtility.dateStringFromDate(medication?.medicationAdministration?.scheduledDateTime, inFormat: "h:mm")
        startDateView.updateTimeLabelWithDateAndTime(date, time:time)
        self.addSubview(startDateView)
    }
}