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
        self.selectionStyle = UITableViewCellSelectionStyle.None
        segmentedValue.addTarget(self, action: "valueChanged:", forControlEvents: .ValueChanged )
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func valueChanged(segmentedValue:AnyObject)
    {
        delegate?.cellValueChanged(tag, object: segmentedValue)
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
    
    func setCellBackgroundColor(color:UIColor)
    {
        self.backgroundView = nil
        self.backgroundColor = color
        self.contentView.backgroundColor = color
        self.selectedBackgroundView = nil
    }
    
    func getValue()-> Int
    {
        return segmentedValue.selectedSegmentIndex
    }
}
