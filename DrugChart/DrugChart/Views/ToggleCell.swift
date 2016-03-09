//
//  ToggleCell.swift
//  DrugChart
//
//  Created by Noureen on 22/02/2016.
//
//

import UIKit

class ToggleCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var toggleValue: UISwitch!
    var delegate:CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
        toggleValue.addTarget(self, action: "valueChanged:", forControlEvents: .ValueChanged )
    }
    
    func valueChanged(uiSwitch: AnyObject)
    {
        delegate?.cellValueChanged(tag ,object: uiSwitch)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(cellTitle :String)
    {
        title.text = cellTitle
    }
    
    func setCellBackgroundColor(color:UIColor)
    {
        self.backgroundView = nil
        self.backgroundColor = color
        self.contentView.backgroundColor = color
        self.selectedBackgroundView = nil
    }
}
