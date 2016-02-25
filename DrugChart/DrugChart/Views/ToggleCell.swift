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
        toggleValue.addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged )
    }
    
    func valueChanged()
    {
        delegate?.cellValueChanged(tag)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(cellTitle :String)
    {
        title.text = cellTitle
    }
    
}
