//
//  AddAccountViewController.swift
//  DCSStripeConnect
//
//  Created by Dinesh Saini on 17/03/23.
//

import UIKit

class AddAccountViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet weak var tableview:UITableView!
    
    var accountDetail = ["Account Holder Name","Accoun Number","Routing Number","Mobile Number","Address"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.register(UINib(nibName: "AccountFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountFieldTableViewCell")
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.reloadData()
        // Do any additional setup after loading the view.
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountFieldTableViewCell", for: indexPath) as! AccountFieldTableViewCell
        cell.selectionStyle = .none
        cell.fieldTitle.text = self.accountDetail[indexPath.row]
        return cell
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
