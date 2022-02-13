//
//  NoteCell.swift
//  Notes
//
//  Created by Admin on 30.01.2022.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet var titileLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
