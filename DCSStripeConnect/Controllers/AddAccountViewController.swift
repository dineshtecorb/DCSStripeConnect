//
//  AddAccountViewController.swift
//  DCSStripeConnect
//
//  Created by Dinesh Saini on 17/03/23.
//

import UIKit
import Stripe
import SVProgressHUD

let rountingNumberDigit = 9
let accountNumberDigit = 12
let ssnDigit = 9
let loaderSize = CGSize(width: 120, height: 120)


enum AccountType:String{
    case individual
    case business
}

class AddAccountViewController: UIViewController{
    
    
    let headerTitles = ["Personal Details","Address","Upload Document"]
    
    enum keys : String, CodingKey {
        case address = "address_line1"
        case city = "address_city"
        case zipcode = "address_postal_code"
        case state = "address_state"
        case day = "dob_day"
        case month = "dob_month"
        case year = "dob_year"
        case fistName = "first_name"
        case lastName = "last_name"
        case ssnLast4 = "ssn_last_4"
        case ssn = "personal_id_number"
        case businessName = "business_name"
        case taxId = "business_tax_id"
        case document = "verification_document"
        case accountType = "account_type"
        
    }
    
    let dataPlaceHolder = [
        "Personal Details":[
            "Account holder name",
            "Routing Number",
            "Account Number",
            "Date of birth",
            "SSN"
        ],
        "Address":[
            "Address",
            "Zipcode",
            "City",
            "State"
        ],
        "Upload Document":[
            ""
        ]
    ]
    
    var data = [
        "Personal Details":[
            "",
            "",
            "",
            "",
            ""
        ],
        "Address":[
            "",
            "",
            "",
            ""
        ],
        "Upload Document":[
            ""
        ]
    ]

    
    @IBOutlet weak var accountTableView:UITableView!
    var accountHeader = AccountHeader()
    var accountType: AccountType = AccountType.individual

    
    var picker: UIPickerView!
    var imagePickerController : UIImagePickerController!
    var documentImage : UIImage?
    
    var datePicker : UIDatePicker!
    var selectedDate: Date!
    var doneBar: UIToolbar!
    
    override func viewWillLayoutSubviews() {
        self.accountTableView.tableHeaderView =  UIView(frame: CGRect.zero)
        self.accountHeader = AccountHeader.instanceFromNib()
        self.accountHeader.frame = CGRect(x: 0, y:0, width: accountTableView.frame.size.width, height:50)
        self.accountTableView.tableHeaderView?.frame.size = CGSize(width: accountTableView.frame.size.width, height: CGFloat(50))
        self.accountTableView.tableHeaderView = self.accountHeader
        self.accountHeader.headerView.layer.backgroundColor = UIColor.white.cgColor
        self.sizeHeaderToFit()
        self.accountTableView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountTableView.dataSource  = self
        self.accountTableView.delegate = self
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
        
        self.selectedDate = Date.today()
        self.initializeDatePicker()
        self.initializeToolBar()
        registerCell()
        self.accountTableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    
    func initializeDatePicker(){
        self.datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        self.datePicker.set18YearValidation()
        self.datePicker.locale = Locale.current
        self.datePicker.timeZone = TimeZone.current
        datePicker.setDate(self.selectedDate, animated: false)
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
    }
    
    
    func initializeToolBar(){
        func setUpDatePicker() {
            self.doneBar = UIToolbar(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height:44))
            doneBar.barStyle = .default
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onClickDone(_:)))
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(onClickCancel(_:)))
            doneButton.tintColor = .black
            cancelButton.tintColor = .black
            doneBar.setItems([cancelButton,spacer,doneButton], animated: false)
            doneBar.backgroundColor = UIColor.white
            doneBar.tintColor = UIColor.white
        }
    }
    
    
    @IBAction func onClickDone(_ sender: UIBarButtonItem){
        self.selectedDate = self.datePicker.date
        self.view.endEditing(true)
        self.accountTableView.reloadData()
    }
    
    @IBAction func onClickCancel(_ sender: UIBarButtonItem){
        self.view.endEditing(true)
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker){
        self.selectedDate = sender.date
        
        let indexPath = IndexPath(row: 3, section: 0)
        let key = headerTitles[indexPath.section]
        if var dataArray = data[key]{
            dataArray[indexPath.row] = self.formattedDateFromDate(self.selectedDate)
            self.data.updateValue(dataArray, forKey: key)
        }
        if let cell = accountTableView.cellForRow(at: indexPath) as? AccountFieldTableViewCell{
            cell.detailTextField.text = self.formattedDateFromDate(self.selectedDate)
        }
    }
    
    func formattedDateFromDate(_ date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.defaultDate = date
        dateFormatter.dateFormat = "dd MMM YYYY"
        let da = dateFormatter.string(from: date)
        return da
    }
    
    func dateParams(_ date:Date) -> (day:String,month:String,year:String){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.defaultDate = date
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "YYYY"
        let year = dateFormatter.string(from: date)
        return (day,month,year)
    }
    
    func nameParams(from name:String) -> (firstName:String,lastName:String){
        var firstName = ""
        var lastName = ""
        
        let fullName = name.components(separatedBy: " ")
        if let fname = fullName.first{
            firstName = fname
        }
        
        if fullName.count > 1{
            var lName = ""
            for i in 1..<fullName.count{
                if lName == ""{
                    lName = fullName[i]
                }else{
                    lName = lName + " " + fullName[i]
                }
            }
            lastName = (lName.count == 0) ? "_" : lName
        }
        
        lastName = (lastName.count == 0) ? "_" : lastName
        
        return(firstName,lastName)
    }


    
    
    func sizeHeaderToFit() {
        let headerView = accountTableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        var frame = headerView.frame
        frame.size.height = 50
        headerView.frame = frame
        accountTableView.tableHeaderView = headerView
    }
    
    func registerCell(){
        let detailNib = UINib(nibName: "AccountFieldTableViewCell", bundle: nil)
        self.accountTableView.register(detailNib, forCellReuseIdentifier: "AccountFieldTableViewCell")
        let documentNib = UINib(nibName: "UploadDocumentTableViewCell", bundle: nil)
        self.accountTableView.register(documentNib, forCellReuseIdentifier: "UploadDocumentTableViewCell")
    }

    
    
    @IBAction func onClickAddAccount(_ button:UIButton){
        let userInputs = self.getParamsFromData()
        if !userInputs.result{
            return
        }
        
        guard let verificationParams = userInputs.params as Dictionary<String,String>? else{
            return
        }
        
        guard let accountParams = userInputs.accountParams else{
            return
        }
        guard let docImage = self.documentImage else{
            self.showAlertWithView(title: "Stripe Connect", message: "Please upload a verification document")
            return
        }
        
        self.showLoader(withStatus: "Creating token..")
        STPAPIClient.shared.createToken(withBankAccount: accountParams) { (resToken, error) in
            if error != nil{
                self.hideLoader()
                self.showAlertWithView(title: "Stripe Connect", message: error?.localizedDescription ?? "Stripe error")
                return
            }else{
                guard let token = resToken else{
                    self.hideLoader()
                    self.showAlertWithView(title: "Stripe Connect", message: error?.localizedDescription ?? "Stripe error")
                    return
                }
                self.updateLoader(withStatus: "Requesting..")
                self.addAccountWith(token: token.tokenId, verificationParams: verificationParams, documentImage: docImage)
            }
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onClickBackBarButton(_ sender:UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}





extension AddAccountViewController{
    
    func addAccountWith(token:String,verificationParams:Dictionary<String,String>,documentImage: UIImage){
        PaymentService.sharedInstance.addBankAccountWith(token, verificationParams: verificationParams, document: documentImage) { (success, resBankAccount, message) in
            self.hideLoader()
            if success{
                if let account = resBankAccount{
                    self.navigationController?.popViewController(animated: true)
                    self.showAlertWithView(title: "Stripe Connect", message: "Account Added successfully!")
                }else{
                    self.showAlertWithView(title: "Stripe Connect", message: message)
                }
            }else{
                self.showAlertWithView(title: "Stripe Connect", message: message)
            }
        }
        
    }
}


extension AddAccountViewController:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.accountType == .individual) ? 3 : self.headerTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataArray = self.dataPlaceHolder[self.headerTitles[section]]
        return dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ((indexPath.section == 2) && (indexPath.row == 0)) ? 100 : UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            self.showAlertToChooseAttachmentOption()
        }else{
            return
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountFieldTableViewCell", for: indexPath) as! AccountFieldTableViewCell
            cell.detailTextField.delegate = self
            cell.detailTextField.addTarget(self, action: #selector(textdidChange(_:)), for: .editingChanged)
            if let phArray = self.dataPlaceHolder[self.headerTitles[indexPath.section]]{
                cell.fieldTitle.text = phArray[indexPath.row]
            }
            if let dataArray = self.data[self.headerTitles[indexPath.section]]{
                cell.detailTextField.text = dataArray[indexPath.row]
            }
            cell.detailTextField.keyboardType = .asciiCapable
            cell.detailTextField.autocorrectionType = .default
            cell.detailTextField.autocapitalizationType = .words
            return cell
        }else if indexPath.section == 2 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadDocumentTableViewCell", for: indexPath) as! UploadDocumentTableViewCell
            cell.documentImage.image = self.documentImage
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountFieldTableViewCell", for: indexPath) as! AccountFieldTableViewCell
            self.configureKeyboard(cell, indexPath: indexPath)
            
            cell.detailTextField.delegate = self
            cell.detailTextField.addTarget(self, action: #selector(textdidChange(_:)), for: .editingChanged)
            
            if let phArray = self.dataPlaceHolder[self.headerTitles[indexPath.section]]{
                cell.fieldTitle.text = phArray[indexPath.row]
            }
            if let dataArray = self.data[self.headerTitles[indexPath.section]]{
                cell.detailTextField.text = dataArray[indexPath.row]
            }
            return cell
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let indexPath = textField.tableViewIndexPath(self.accountTableView) as IndexPath?{
            if let cell = self.accountTableView.cellForRow(at: indexPath) as? AccountFieldTableViewCell{
                self.configureKeyboard(cell, indexPath: indexPath)
            }
        }
        return true
    }
    
    func configureKeyboard(_ cell:AccountFieldTableViewCell, indexPath :IndexPath){
        let textField: UITextField = cell.detailTextField
        if indexPath.section == 0{
            switch indexPath.row{
            case 0://account holder name
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .default
                textField.autocapitalizationType = .words
            case 1,2://routing number
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .numberPad
                textField.autocorrectionType = .no
            case 3://Dob
                textField.keyboardType = .default
                textField.autocorrectionType = .no
                textField.inputView = self.datePicker
                textField.inputAccessoryView = self.doneBar
                break;
            case 4:
                textField.keyboardType = .phonePad
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.autocorrectionType = .no
            default:
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .default
                textField.autocapitalizationType = .words
            }
        }else if indexPath.section == 1{
            switch indexPath.row{
            case 1:
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .numberPad
                textField.autocorrectionType = .no
            case 2,3:
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .default
                textField.autocapitalizationType = .words
            default:
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .default
                textField.autocapitalizationType = .words
            }
        }else if indexPath.section == 3{//Business details
            switch indexPath.row{
            case 1://business name
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .default
                textField.autocapitalizationType = .words
            case 2://tax id
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
            default:
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .default
                textField.autocapitalizationType = .words
            }
        }else{
            textField.inputView = nil
            textField.inputAccessoryView = nil
            textField.keyboardType = .asciiCapable
            textField.autocorrectionType = .default
            textField.autocapitalizationType = .words
        }
    }
}


extension AddAccountViewController: UITextFieldDelegate,UITextViewDelegate{
    //MARK:- UITextFieldDelegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let indexPath = textField.tableViewIndexPath(self.accountTableView) as IndexPath?{
            let key = headerTitles[indexPath.section]
            if var darray = data[key]{
                darray[indexPath.row] = textField.text ?? ""
                self.data.updateValue(darray, forKey: key)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let indexPath = textField.tableViewIndexPath(self.accountTableView) as IndexPath?{
            if indexPath.section == 0 && indexPath.row == 1{//rounting number validation
                return self.validateMaxLength(textField, maxLength: rountingNumberDigit, range: range, replacementString: string)
            }/*else if indexPath.section == 0 && indexPath.row == 2{//account number validation
                return CommonClass.validateMaxLength(textField, maxLength: accountNumberDigit, range: range, replacementString: string)
            }*/else if indexPath.section == 0 && indexPath.row == 4{//ssn validation
                return self.validateMaxLength(textField, maxLength: ssnDigit, range: range, replacementString: string)
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let indexPath = textField.tableViewIndexPath(self.accountTableView) as IndexPath?{
            let key = headerTitles[indexPath.section]
            if var darray = data[key]{
                darray[indexPath.row] = textField.text ?? ""
                self.data.updateValue(darray, forKey: key)
            }
        }
        self.accountTableView.reloadData()
    }
    
    @IBAction func textdidChange(_ textField: UITextField){
        if let indexPath = textField.tableViewIndexPath(self.accountTableView) as IndexPath?{
            let key = headerTitles[indexPath.section]
            if var darray = data[key]{
                darray[indexPath.row] = textField.text ?? ""
                self.data.updateValue(darray, forKey: key)
            }
        }
    }
    
    //MARK:- UITextViewDelegate Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let indexPath = textView.tableViewIndexPath(self.accountTableView) as IndexPath?{
            let key = headerTitles[indexPath.section]
            if var darray = data[key]{
                darray[indexPath.row] = textView.text
                self.data.updateValue(darray, forKey: key)
            }
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if let indexPath = textView.tableViewIndexPath(self.accountTableView) as IndexPath?{
            let key = headerTitles[indexPath.section]
            if var darray = data[key]{
                darray[indexPath.row] = textView.text
                self.data.updateValue(darray, forKey: key)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let indexPath = textView.tableViewIndexPath(self.accountTableView) as IndexPath?{
            let key = headerTitles[indexPath.section]
            if var darray = data[key]{
                darray[indexPath.row] = textView.text
                self.data.updateValue(darray, forKey: key)
            }
        }
        self.accountTableView.reloadData()
    }
    
    func showAlertWithView(title: String, message: String,completionBlock :(() -> Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in
            guard let handler = completionBlock else{
                alert.dismiss(animated: false, completion: nil)
                return
            }
            handler()
            alert.dismiss(animated: false, completion: nil)
        }
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }

    
}


extension AddAccountViewController{
        func getParamsFromData() -> (params:Dictionary<String,String>, accountParams : STPBankAccountParams?,result:Bool){
            
            guard let personalDetails = self.data[headerTitles[0]]else{
                return ([:],nil,false)
            }
            var params = Dictionary<String,String>()
            let accountParams = STPBankAccountParams()
            accountParams.accountHolderType = (self.accountType == .business) ? .company : .individual
            
            let accountHolderName = personalDetails[0].trimmingCharacters(in: .whitespaces)
            let routingNumber = personalDetails[1].trimmingCharacters(in: .whitespaces)
            let accountNumber = personalDetails[2].trimmingCharacters(in: .whitespaces)
            let dob = personalDetails[3].trimmingCharacters(in: .whitespaces)
            let ssn = personalDetails[4].trimmingCharacters(in: .whitespaces)
            
            let personalDetailsVerification = self.verifyPersonalDetails(accountHodlerName: accountHolderName, routingNumber: routingNumber, accountNumber: accountNumber, dob: dob, ssn: ssn)
            
            if !personalDetailsVerification.result{
                self.showAlertWithView(title: "Stripe Connect", message: personalDetailsVerification.message)
                return ([:],nil,false)
            }else{
                accountParams.accountHolderName = accountHolderName
                accountParams.accountNumber = accountNumber
                accountParams.routingNumber = routingNumber
                accountParams.currency = "usd"
                accountParams.country = "US"
                
                let nameParams = self.nameParams(from: accountHolderName)
                params.updateValue(nameParams.firstName, forKey: keys.fistName.stringValue)
                
                params.updateValue(nameParams.lastName, forKey: keys.lastName.stringValue)
                params.updateValue((self.accountType == .individual) ? "individual" : "company", forKey: keys.accountType.stringValue)
                
                let dob = self.dateParams(self.selectedDate)
                params.updateValue(dob.day, forKey: keys.day.stringValue)
                params.updateValue(dob.month, forKey: keys.month.stringValue)
                params.updateValue(dob.year, forKey: keys.year.stringValue)
                params.updateValue(String(ssn.suffix(4)), forKey: keys.ssnLast4.stringValue)
                params.updateValue(ssn, forKey: keys.ssn.stringValue)
                
            }
            
            guard let addressDetails = self.data[headerTitles[1]]else{
                return ([:],nil,false)
            }
            
            let line1 = addressDetails[0].trimmingCharacters(in: .whitespaces)
            let zipcode = addressDetails[1].trimmingCharacters(in: .whitespaces)
            let city = addressDetails[2].trimmingCharacters(in: .whitespaces)
            let state = addressDetails[3].trimmingCharacters(in: .whitespaces)
            let addressVerification = self.verifyAddress(address: line1, zipcode: zipcode, city: city, state: state)
            if !addressVerification.result{
                self.showAlertWithView(title: "Stripe Connect", message: addressVerification.message)
                return ([:],nil,false)
            }else{
                params.updateValue(line1, forKey: keys.address.stringValue)
                params.updateValue(zipcode, forKey: keys.zipcode.stringValue)
                params.updateValue(city, forKey: keys.city.stringValue)
                params.updateValue(state, forKey: keys.state.stringValue)
            }
            
            return (params,accountParams,true)
        }
        
        func verifyPersonalDetails(accountHodlerName:String, routingNumber:String, accountNumber:String, dob:String, ssn:String) -> (result:Bool,message:String){
            if accountHodlerName.isEmpty{
                return (false,"Please enter account holder name")
            }
            if routingNumber.isEmpty{
                return (false,"Please enter routing number")
            }
            if routingNumber.count != rountingNumberDigit{
                return (false,"Rounting number should be of \(rountingNumberDigit) characters")
            }
            if accountNumber.isEmpty{
                return (false,"Please enter Account number")
            }
//            if accountNumber.count != accountNumberDigit{
//                return (false,"Account number should be of \(accountNumberDigit) characters")
//            }
            if dob.isEmpty{
                return (false,"Please enter date of birth")
            }
            
            if ssn.isEmpty{
                return (false,"Please enter SSN")
            }
            if ssn.count != ssnDigit{
               return (false,"ssn number should be of \(ssnDigit) characters")
            }
            return (true,"")
        }
        
        func verifyAddress(address:String,zipcode:String,city:String,state:String)-> (result:Bool,message:String){
            if address.isEmpty{
                return (false,"Please enter address")
            }
            
            if zipcode.isEmpty{
                return (false,"Please enter zipcode")
            }
            
            if city.isEmpty{
                return (false,"Please enter city")
            }
            
            if state.isEmpty{
                return (false,"Please enter state")
            }
            
            return(true,"")
        }
        
    }

extension AddAccountViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func showAlertToChooseAttachmentOption(){
        
        let actionSheet = UIAlertController(title: "Select Option", message: "To take a picture of legal document", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(cancelAction)
        let openGalleryAction: UIAlertAction = UIAlertAction(title: "Choose from Gallery", style: .default)
        { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                self.imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary;
                self.imagePickerController.allowsEditing = false
                self.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.currentContext
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(openGalleryAction)
        
        let openCameraAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default)
        { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                self.imagePickerController.sourceType = UIImagePickerController.SourceType.camera;
                self.imagePickerController.allowsEditing = false
                self.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.currentContext
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(openCameraAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey :Any]){
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let tempImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage{
            self.documentImage = tempImage
        }else if let tempImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage{
            self.documentImage = tempImage
        }
        self.accountTableView.reloadData()
        picker.dismiss(animated: true) {}
    }
    
    
}





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


extension UIDatePicker {
    func set18YearValidation() {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone.current//TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -13
        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -13
        //  let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        // self.minimumDate = minDate
        self.maximumDate = maxDate
    }
}

extension AddAccountViewController{
    func validateMaxLength(_ textField: UITextField, maxLength: Int, range: NSRange, replacementString string: String) -> Bool{
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
    
    func hideLoader()
    {
        SVProgressHUD.dismiss()
    }
    
     func showLoader(withStatus status: String)
    {
       
        SVProgressHUD.setMinimumSize(loaderSize)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.show(withStatus: status)
    }
     func updateLoader(withStatus status: String)
    {
        SVProgressHUD.setStatus(status)
        SVProgressHUD.setMinimumSize(loaderSize)

    }
}


extension UIView {
    //MARK: - method for UITableView

    func tableViewCell() -> UITableViewCell? {
        var tableViewcell : UIView? = self
        while(tableViewcell != nil)
        {
            if tableViewcell! is UITableViewCell {
                break
            }
            tableViewcell = tableViewcell!.superview
        }
        return tableViewcell as? UITableViewCell
    }

    
    func tableViewIndexPath(_ tableView: UITableView) -> IndexPath? {

        if let cell = self.tableViewCell() {

            return tableView.indexPath(for: cell) as IndexPath?
        }else {
            return nil
        }
    }

}

