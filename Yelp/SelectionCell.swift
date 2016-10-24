//
//  SelectionCell.swift
//  ChowHunt
//
//  Created by Jon O'Keefe on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SelectionCellDelegate {
    @objc optional func selectionCell(selected selectionCell: SelectionCell)
}

class SelectionCell: UITableViewCell {

    @IBOutlet weak var selectionTitle: UILabel!
    
    weak var delegate: SelectionCellDelegate?
    
    var content: [String: String?]! {
        didSet {
            self.selectionTitle.text = content["name"]!
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            delegate?.selectionCell?(selected: self)
        }
    }

}
