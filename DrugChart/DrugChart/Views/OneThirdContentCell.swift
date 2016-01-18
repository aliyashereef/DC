//
//  OneThirdContentCell.swift
//  DrugChart
//
//  Created by Noureen on 14/01/2016.
//
//

import UIKit

class OneThirdContentCell: UITableViewCell {

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        title.layer.borderWidth = Constant.BORDER_WIDTH
        title.layer.borderColor = Constant.CELL_BORDER_COLOR
        title.layer.cornerRadius = Constant.CORNER_RADIUS
       
        content.layer.borderWidth = Constant.BORDER_WIDTH
        content.layer.borderColor = Constant.CELL_BORDER_COLOR
        content.layer.cornerRadius = Constant.CORNER_RADIUS
        
        title.font = UIFont.systemFontOfSize(15)
        title.backgroundColor = Constant.SELECTION_CELL_BACKGROUND_COLOR
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell()
    {
    }
}
