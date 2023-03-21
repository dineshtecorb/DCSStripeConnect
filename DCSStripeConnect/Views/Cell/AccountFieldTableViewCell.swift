//
//  AccountFieldTableViewCell.swift
//  DCSStripeConnect
//
//  Created by Dinesh Saini on 17/03/23.
//

import UIKit

class AccountFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fieldTitle:UILabel!
    @IBOutlet weak var detailTextField:UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
