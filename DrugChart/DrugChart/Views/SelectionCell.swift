//
//  SelectionCell.swift
//  vitalsigns
//
//  Created by Noureen on 10/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    var dataSource:[KeyValue]=[]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(cellTitle:String,selectedValue:KeyValue,dataSource:[KeyValue])
    {
        title.text = cellTitle
        details.text = selectedValue.value
        self.dataSource = dataSource
    }
    
}
