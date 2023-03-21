//
//  AccountHeader.swift
//  DCSStripeConnect
//
//  Created by Dinesh Saini on 17/03/23.
//

import UIKit

class AccountHeader: UIView {
    
    @IBOutlet weak var headerView:UIView!
    @IBOutlet weak var headerTextLabel:UILabel!
    
    
    class func instanceFromNib() -> AccountHeader {
        return UINib(nibName: "AccountHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AccountHeader
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
