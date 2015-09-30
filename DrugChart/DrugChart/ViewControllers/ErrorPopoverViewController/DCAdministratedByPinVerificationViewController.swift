//
//  DCAdministratedByPinVerificationViewController.swift
//  DrugChart
//
//  Created by aliya on 30/09/15.
//
//

import Foundation

class DCAdministratedByPinVerificationViewController: UIViewController , UIViewControllerTransitioningDelegate {
    
    @IBOutlet var firstDigit: UIButton!
    @IBOutlet var secondDigit: UIButton!
    @IBOutlet var thirdDigit: UIButton!
    @IBOutlet var fourthDigit: UIButton!
    
    var digits : NSMutableArray = []
    
    override func viewDidLoad() {
        updateDigits()
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
            self.performSelector("verifyCode", withObject: self, afterDelay: 0.5)
        }
    }

    @IBAction func deleteNumber(sender: UIButton) {
        if(digits.count > 0) {
            digits.removeLastObject()
        }
        updateDigits()
    }
    
    func verifyCode() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //  Updating digits values
    func updateDigits() {
        let digitImage : UIImage = UIImage(named:"dotImage")!
        let blankImage : UIImage = UIImage(named:"lineImage")!

        switch (digits.count) {
            case 0:
                firstDigit.setTitle("", forState:UIControlState.Normal)
                secondDigit.setTitle("", forState:UIControlState.Normal)
                thirdDigit.setTitle("", forState:UIControlState.Normal)
                fourthDigit.setTitle("", forState:UIControlState.Normal)
                
                firstDigit.setImage(blankImage, forState: UIControlState.Normal)
                secondDigit.setImage(blankImage , forState: UIControlState.Normal)
                thirdDigit.setImage(blankImage , forState: UIControlState.Normal)
                fourthDigit.setImage(blankImage , forState: UIControlState.Normal)
                
                break;
            case 1:
                firstDigit.setTitle(digits[0] as? String, forState:UIControlState.Normal)
                secondDigit.setTitle("", forState:UIControlState.Normal)
                thirdDigit.setTitle("", forState:UIControlState.Normal)
                fourthDigit.setTitle("", forState:UIControlState.Normal)
                firstDigit.setImage(digitImage, forState: UIControlState.Normal)
                secondDigit.setImage(blankImage , forState: UIControlState.Normal)
                thirdDigit.setImage(blankImage , forState: UIControlState.Normal)
                fourthDigit.setImage(blankImage , forState: UIControlState.Normal)
                break;
            case 2:
                firstDigit.setTitle(digits[0] as? String, forState:UIControlState.Normal)
                secondDigit.setTitle(digits[1] as? String, forState:UIControlState.Normal)
                thirdDigit.setTitle("", forState:UIControlState.Normal)
                fourthDigit.setTitle("", forState:UIControlState.Normal)
                firstDigit.setImage(digitImage, forState: UIControlState.Normal)
                secondDigit.setImage(digitImage , forState: UIControlState.Normal)
                thirdDigit.setImage(blankImage , forState: UIControlState.Normal)
                fourthDigit.setImage(blankImage , forState: UIControlState.Normal)

                break;
            case 3:
                firstDigit.setTitle(digits[0] as? String, forState:UIControlState.Normal)
                secondDigit.setTitle(digits[1] as? String, forState:UIControlState.Normal)
                thirdDigit.setTitle(digits[2] as? String, forState:UIControlState.Normal)
                fourthDigit.setTitle("", forState:UIControlState.Normal)
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