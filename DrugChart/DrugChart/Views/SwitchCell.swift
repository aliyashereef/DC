//
//  SwitchCell.swift
//  DrugChart
//
//  Created by Noureen on 22/02/2016.
//
//

import UIKit

class SwitchCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var segmentedValue: UISegmentedControl!
    var delegate:CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        segmentedValue.addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged )
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func valueChanged()
    {
        delegate?.cellValueChanged(tag)
    }
    
    func configureCell(cellTitle:String , values:[String])
    {
        title.text = cellTitle
        var index = 0
        for segmentTitle in values
        {
            if (index > segmentedValue.numberOfSegments)
            {
                segmentedValue.insertSegmentWithTitle(segmentTitle, atIndex: index, animated: false)
            }
            else
            {
                segmentedValue.setTitle(segmentTitle, forSegmentAtIndex: index)
            }
            
            index++
        }
    }
    
}