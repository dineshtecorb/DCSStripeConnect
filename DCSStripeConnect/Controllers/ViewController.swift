//
//  ViewController.swift
//  DCSStripeConnect
//
//  Created by Dinesh Saini on 17/03/23.
//

import UIKit
import Stripe
import SVProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var accountHolderNameTextField:UITextField!
    @IBOutlet weak var accountNumberTextField:BKCardNumberField!
    @IBOutlet weak var cardExpiryTextField:BKCardExpiryField!
    @IBOutlet weak var cvvTextField:UITextField!


    var cardNumber = ""
    var expMonth = 0
    var expYear = 0
    var cardHolderName = ""
    var cvv = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.cardExpiryTextField.delegate = self
//        self.accountNumberTextField.delegate = self
//        self.accountHolderNameTextField.delegate = self
//        self.cvvTextField.delegate = self
//        self.accountNumberTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
//        self.cardExpiryTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
//        self.accountHolderNameTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
//        self.cvvTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)

    }
    
    func validateCardParams(_ cardNumber:String,cardHolderName:String,expMonth: UInt,expYear:UInt,CVV:String) -> Bool {
        let cardParams = STPCardParams()
        cardParams.number = cardNumber
        if cardHolderName.count != 0{
            cardParams.name = cardHolderName
        }
        cardParams.expMonth = expMonth
        cardParams.expYear = expYear
        cardParams.cvc = CVV
        let validationState = STPCardValidator.validationState(forCard: cardParams)
        return (validationState != .invalid)
    }
//
    func validteCardInputs(_ cardNumber:String,cardHolderName:String,expMonth: Int?,expYear:Int?,CVV:String) -> (success:Bool,message:String) {

        if cardNumber.count == 0{
            return(false,"Please enter a valid card number")
        }

        if cardNumber.count < 14{
            return(false,"Please enter a valid card number")
        }

        if let expMon = expMonth{
            if let expY = expYear {
                if expY == Calendar.current.component(.year, from: Date()) {
                    if (expMon < Calendar.current.component(.month, from: Date())) && ((expMon < 1) || (expMon > 12)){
                        return(false,"Please enter a valid exp. month")
                    }
                } else {
                    if (expMon < 1) || (expMon > 12){
                        return(false,"Please enter a valid exp. year")
                    }
                }
            }
        }else{
            return(false,"Please enter the exp. month")
        }

        if let expY = expYear{
            if (expY < Calendar.current.component(.year, from: Date())){
                return(false,"Please enter a valid exp. year")
            }
        }else{
            return(false,"Please enter the exp. year")
        }
        if (CVV.count == 0){
            return(false,"Please enter the CVV")
        }
        if (CVV.count < 3) || (CVV.count > 4){
            return(false,"Please enter a valid CVV")
        }

        if cardHolderName.count == 0{//Please enter the card holder's name
            return(false,"Please enter the card holder's name")
        }
        return(true,"")

    }
//
    @IBAction func onClickAddCardButton(_ sender: UIButton) {
        self.view.endEditing(true)

        let cardnumber = self.accountNumberTextField.text!
            cardNumber = cardnumber

        
        guard let cardNumberFormatter = self.accountNumberTextField.cardNumberFormatter else{
            self.showAlertWithView(title: "Important Message", message: "The card was declined. Please reenter the payment details")
            return
        }
        
        guard let cardPattern = cardNumberFormatter.cardPatternInfo else {
            self.showAlertWithView(title: "Important Message", message: "Please enter a valid card number")
            return
        }
        
        guard cardPattern.companyName != nil else {
            self.showAlertWithView(title: "Important Message", message: "The card was declined. Please reenter the payment details")
            return
        }

        
        let exipry = self.cardExpiryTextField.text!
           
        
        guard let expMonth = self.cardExpiryTextField.dateComponents.month else {
            self.showAlertWithView(title: "Important Message", message: "Please enter the exp. month")
            return
        }
        self.expMonth = expMonth
        guard let expYear = self.cardExpiryTextField.dateComponents.year else {
            self.showAlertWithView(title: "Important Message", message: "Please enter a valid exp. year")
            return
        }
        self.expYear = expYear
    
        let cv = self.cvvTextField.text!
            cvv = cv
        
        let carholderName = self.accountHolderNameTextField.text!
        self.cardHolderName = carholderName

        let inputValidation = self.validteCardInputs(cardNumber, cardHolderName: cardHolderName, expMonth: expMonth, expYear: expYear, CVV: cvv)
        if !inputValidation.success{
            self.showAlertWithView(title: "Important Message", message: inputValidation.message)

            return
        }

       // self.createTokenWith(cardNumber, cardHolderName: cardHolderName, expMonth: UInt(expMonth), expYear: UInt(expYear), CVV: cvv)

    }
    
    func createTokenWith(_ cardNumber:String,cardHolderName:String,expMonth: UInt,expYear:UInt,CVV:String) {
        let cardParams = STPCardParams()
        cardParams.number = cardNumber
        if cardHolderName != "" {
            cardParams.name = cardHolderName
        }
        cardParams.expYear = expYear
        cardParams.expMonth = expMonth
        cardParams.cvc = CVV
        self.showLoader(withStatus: "Adding...")
        STPAPIClient.shared.createToken(withCard: cardParams) { [self] token, error in
            self.hideLoader()
            if error != nil {
                self.showAlertWithView(title: "Stripe Connect", message: error!.localizedDescription)
                return
            } else {
                guard let stripeToken = token else {
                    self.showAlertWithView(title: "Stripe Connect", message: "The card was declined. Please reenter the payment details")
                    return
                }
                self.showAlertWithView(title: "Stripe Connect", message: "Card successfully veriffied!")

        // TODO  Write your code here of add or paymment with this card with the  help of " Stripe Token "
                // write your request like add card and payment with this token in your app
                // Payment with this card and save for future use that , and store in server data
            }
        }
    }




}


extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
                if textField == self.accountNumberTextField {
                    cardNumber = textField.text!
                }else if textField == self.accountHolderNameTextField{
                    self.cardHolderName = textField.text!
                }else if textField == self.cvvTextField {
                    cvv = textField.text!
                }else if textField == self.cardExpiryTextField {
                    cvv = textField.text!
                }
            }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.accountNumberTextField {
            cardNumber = textField.text!
        }
        
        guard let cardNumberFormatter = self.accountNumberTextField.cardNumberFormatter else{
            self.showAlertWithView(title: "Important Message", message: "The card was declined. Please reenter the payment details")
            return
        }
        
        guard let cardPattern = cardNumberFormatter.cardPatternInfo else {
            self.showAlertWithView(title: "Important Message", message: "Please enter a valid card number")
            return
        }
        
        guard cardPattern.companyName != nil else {
            self.showAlertWithView(title: "Important Message", message: "The card was declined. Please reenter the payment details")
            return
        }

        
        if textField == self.cardExpiryTextField {
            _ = textField.text!
        }
        
        guard let expMonth = self.cardExpiryTextField.dateComponents.month else {
            self.showAlertWithView(title: "Important Message", message: "Please enter the exp. month")
            return
        }
        self.expMonth = expMonth
        guard let expYear = self.cardExpiryTextField.dateComponents.year else {
            self.showAlertWithView(title: "Important Message", message: "Please enter a valid exp. year")
            return
        }
        self.expYear = expYear
        
        if textField == self.cvvTextField {
            cvv = textField.text!
        }
        
        if textField == self.accountHolderNameTextField {
            cardHolderName = textField.text!
        }

        
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

                

    @objc func textChanged(_ textField: UITextField) {
        if textField == self.accountNumberTextField {
            cardNumber = textField.text!
        }else if textField == self.accountHolderNameTextField{
            self.cardHolderName = textField.text!
        }else if textField == self.cvvTextField {
            cvv = textField.text!
        }else if textField == self.cardExpiryTextField {
            cvv = textField.text!
        }
    }
}



extension ViewController{
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
