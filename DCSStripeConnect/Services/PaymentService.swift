//
//  PaymentService.swift
//  DCSStripeConnect
//
//  Created by Dinesh Saini on 17/03/23.
//

import UIKit
import Alamofire
import SwiftyJSON

class PaymentService {
    static let sharedInstance = PaymentService()
    fileprivate init() {}
        
    func addBankAccountWith(_ sourcetoken : String, verificationParams:Dictionary<String,String>?, document:UIImage?, completionBlock:@escaping (_ success:Bool,_ resData:Dictionary<String,AnyObject>?,_ message:String) -> Void){
        let head = self.prepareHeader(withAuth: true)
        let url = "\("YOUR_SERVER_URL_FOR_ADD_BANK_ACCOUNT")"
        var params = Dictionary<String,String>()
        if let kycParams = verificationParams{
            for (key, value) in kycParams{
                params.updateValue(value, forKey: key)
            }
        }
        params.updateValue(sourcetoken, forKey: "source_token")
        
        AF.upload(multipartFormData: { multipartFormData in
           if let pimage = document{
               if let data = pimage.jpegData(compressionQuality: 1.0) as Data?{
                   multipartFormData.append(data, withName: "\("document_key_name")", fileName: "\("document_key_name")",mimeType: "image/jpg")
               }
            }
            
            for (key, value) in params {
                multipartFormData.append((value).data(using: .utf8)!, withName: key)
            }

        }, to: url,method: .post,headers: head).response{ response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    print("Add Account in json is:\n\(json)")
                    if let code =  json["result"]["code"].intValue as Int?{
                        if code == 200{
                            completionBlock(true, json.dictionaryObject as Dictionary<String, AnyObject>?,json["result"]["message"].stringValue)

                        }else{
                            completionBlock(false,nil,response.error?.localizedDescription ?? "Some thing went wrong")
                        }
                    }else{
                        completionBlock(false,nil,response.error?.localizedDescription ?? "Some thing went wrong")
                    }
                }else{
                    completionBlock(false,nil,response.error?.localizedDescription ?? "Some thing went wrong")
                }
            case .failure(let error):
                completionBlock(false,nil,error.localizedDescription)
            }
        }
    }
    
    
    func prepareHeader(withAuth:Bool) -> HTTPHeaders{
        var header = HTTPHeaders()
         let accept = "application/json"
        let currentVersion = UIApplication.appVersion()+"."+UIApplication.appBuild()
         if withAuth{
             header.add(HTTPHeader(name: "\("TOKEN_KEY")", value: "\("YOUR_ACCESS_TOKEN")"))
         }
        header.add(HTTPHeader(name: "currentVersion", value: currentVersion))
        header.add(HTTPHeader(name: "currentDevice", value: "ios"))
        header.add(HTTPHeader(name: "Accept", value: accept))
        header.add(HTTPHeader(name: "timezone", value: TimeZone.current.identifier))
         return header
     }
}


extension UIApplication {
    
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    //
    
}
