//
//  PhoneCallerCell.swift
//  CallKitty
//
//  Created by Steve Baker on 7/22/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit

class PhoneCallerCell: UITableViewCell {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneCallerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
