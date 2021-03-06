//
//  DCAdministratedByPinVerificationViewController.swift
//  DrugChart
//
//  Created by aliya on 30/09/15.
//
//

import Foundation

let dotImageName : NSString = "dotImage"
let lineImageName : NSString = "lineImage"

protocol SecurityPinMatchDelegate {
    
    func securityPinMatchedForUser (user : DCUser)
}

@objc class DCAdministratedByPinVerificationViewController: UIViewController , UIViewControllerTransitioningDelegate {
    
    @IBOutlet var firstDigit: UIButton!
    @IBOutlet var secondDigit: UIButton!
    @IBOutlet var thirdDigit: UIButton!
    @IBOutlet var fourthDigit: UIButton!
    var user : DCUser!
    var delegate : SecurityPinMatchDelegate?
    @IBOutlet weak var topView: UIView!
    var digits : NSMutableArray = []
    
    override func viewDidLoad() {
        updateDigits()
        DCUtility.roundCornersForView(topView, roundTopCorners: true)
        super.viewDidLoad()
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func keypadButtonTapped(sender: UIButton) {
        let numberTapped = sender.tag
        if(digits.count < 4) {
            digits.addObject(numberTapped)
        }
        updateDigits()
        if(digits.count == 4) {
            self.performSelector(#selector(DCAdministratedByPinVerificationViewController.verifyCode), withObject: self, afterDelay: 0.5)
        }
    }

    @IBAction func deleteNumber(sender: UIButton) {
        if(digits.count > 0) {
            digits.removeLastObject()
        }
        updateDigits()
    }
    
    func verifyCode() {
        if delegate != nil {
            delegate!.securityPinMatchedForUser(user)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //  Updating digits values
    func updateDigits() {
        let digitImage : UIImage = UIImage(named:dotImageName as String)!
        let blankImage : UIImage = UIImage(named:lineImageName as String)!

        switch (digits.count) {
            case 0:
                firstDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                secondDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                thirdDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                fourthDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                
                firstDigit.setImage(blankImage, forState: UIControlState.Normal)
                secondDigit.setImage(blankImage , forState: UIControlState.Normal)
                thirdDigit.setImage(blankImage , forState: UIControlState.Normal)
                fourthDigit.setImage(blankImage , forState: UIControlState.Normal)
                
                break;
            case 1:
                firstDigit.setTitle(digits[0] as? String, forState:UIControlState.Normal)
                secondDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                thirdDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                fourthDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                firstDigit.setImage(digitImage, forState: UIControlState.Normal)
                secondDigit.setImage(blankImage , forState: UIControlState.Normal)
                thirdDigit.setImage(blankImage , forState: UIControlState.Normal)
                fourthDigit.setImage(blankImage , forState: UIControlState.Normal)
                break;
            case 2:
                firstDigit.setTitle(digits[0] as? String, forState:UIControlState.Normal)
                secondDigit.setTitle(digits[1] as? String, forState:UIControlState.Normal)
                thirdDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                fourthDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                firstDigit.setImage(digitImage, forState: UIControlState.Normal)
                secondDigit.setImage(digitImage , forState: UIControlState.Normal)
                thirdDigit.setImage(blankImage , forState: UIControlState.Normal)
                fourthDigit.setImage(blankImage , forState: UIControlState.Normal)

                break;
            case 3:
                firstDigit.setTitle(digits[0] as? String, forState:UIControlState.Normal)
                secondDigit.setTitle(digits[1] as? String, forState:UIControlState.Normal)
                thirdDigit.setTitle(digits[2] as? String, forState:UIControlState.Normal)
                fourthDigit.setTitle(EMPTY_STRING, forState:UIControlState.Normal)
                firstDigit.setImage(digitImage, forState: UIControlState.Normal)
                secondDigit.setImage(digitImage , forState: UIControlState.Normal)
                thirdDigit.setImage(digitImage , forState: UIControlState.Normal)
                fourthDigit.setImage(blankImage , forState: UIControlState.Normal)

                break;
            case 4:
                firstDigit.setTitle(digits[0] as? String, forState:UIControlState.Normal)
                secondDigit.setTitle(digits[1] as? String, forState:UIControlState.Normal)
                thirdDigit.setTitle(digits[2] as? String, forState:UIControlState.Normal)
                fourthDigit.setTitle(digits[3] as? String, forState:UIControlState.Normal)
                firstDigit.setImage(digitImage, forState: UIControlState.Normal)
                secondDigit.setImage(digitImage , forState: UIControlState.Normal)
                thirdDigit.setImage(digitImage , forState: UIControlState.Normal)
                fourthDigit.setImage(digitImage , forState: UIControlState.Normal)
                break;
                
            default:
                break;
            }
        }
}