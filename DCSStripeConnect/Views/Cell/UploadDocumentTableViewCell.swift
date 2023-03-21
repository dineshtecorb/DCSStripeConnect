//
//  UploadDocumentTableViewCell.swift
//  DCSStripeConnect
//
//  Created by Dinesh Saini on 17/03/23.
//

import UIKit

class UploadDocumentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var uploadDocLabel:UILabel!
    @IBOutlet weak var infoLabel:UILabel!
    @IBOutlet weak var documentImage:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
