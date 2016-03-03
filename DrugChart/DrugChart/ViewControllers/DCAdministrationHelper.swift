//
//  DCAdministrationHelper.swift
//  DrugChart
//
//  Created by aliya on 23/02/16.
//
//

import Foundation

class DCAdministrationHelper : NSObject {
    
    static func addBNFView () -> DCBNFViewController {
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        let bnfViewController : DCBNFViewController? = administerStoryboard!.instantiateViewControllerWithIdentifier(BNF_STORYBOARD_ID) as? DCBNFViewController
        return bnfViewController!
    }
    
    static func administratedStatusPopOverAtIndexPathWithStatus (indexPath : NSIndexPath, status : NSString) -> DCAdministrationStatusTableViewController{
        
        let statusViewController : DCAdministrationStatusTableViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(STATUS_LIST_VIEW_SB_ID) as? DCAdministrationStatusTableViewController
        statusViewController?.status = status as String
        statusViewController?.title = NSLocalizedString("STATUS", comment: "")
        return statusViewController!
    }
    
    static func administratedReasonPopOverAtIndexPathWithStatus (status : NSString) -> DCAdministrationReasonViewController{
        
        let statusViewController : DCAdministrationReasonViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier("StatusReasonCellViewController") as? DCAdministrationReasonViewController
        statusViewController?.administrationStatus = status as String
        statusViewController?.title = NSLocalizedString("REASON", comment: "")
        return statusViewController!
    }
    
    static func fetchAdministersAndPrescribersList ()-> NSMutableArray? {
        
        //fetch administers and prescribers list
        let userListArray : NSMutableArray = []
        var selfAdministratedUser : DCUser? = nil
        let usersListWebService : DCUsersListWebService = DCUsersListWebService.init()
        usersListWebService.getUsersListWithCallback { (users, error) -> Void in
            if (error == nil) {
                for userDictionary in users {
                    let displayName = userDictionary[DISPLAY_NAME_KEY] as! String?
                    let identifier = userDictionary[IDENTIFIER_KEY] as! String?
                    let user : DCUser = DCUser.init()
                    user.displayName = displayName
                    user.userIdentifier = identifier
                    userListArray.addObject(user)
                }
                let selfAdministratedPatientName = SELF_ADMINISTERED_TITLE
                let selfAdministratedPatientIdentifier = EMPTY_STRING
                selfAdministratedUser = DCUser.init()
                selfAdministratedUser!.displayName = selfAdministratedPatientName
                selfAdministratedUser!.userIdentifier = selfAdministratedPatientIdentifier
                userListArray.insertObject(selfAdministratedUser!, atIndex: 0)
            }
        }
        return userListArray
    }
    
    //MARK: API Integration
    static func medicationAdministrationDictionaryForMedicationSlot(medicationSlot : DCMedicationSlot, medicationDetails : DCMedicationScheduleDetails) -> NSDictionary {
        
        let administerDictionary : NSMutableDictionary = [:]
        let scheduledDateString : NSString
        if (medicationSlot.medicationAdministration?.scheduledDateTime != nil) {
            scheduledDateString = DCDateUtility.dateStringFromDate(medicationSlot.medicationAdministration?.scheduledDateTime, inFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        } else {
            scheduledDateString = DCDateUtility.dateStringFromDate(NSDate(), inFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        }
        administerDictionary.setValue(scheduledDateString, forKey:SCHEDULED_ADMINISTRATION_TIME)
        let dateFormatter : NSDateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = EMIS_DATE_FORMAT
        dateFormatter.timeZone = NSTimeZone.init(name:"UTC")
        if (medicationSlot.medicationAdministration?.actualAdministrationTime != nil) {
            let administeredDateString : NSString = dateFormatter.stringFromDate((medicationSlot
                .medicationAdministration?.actualAdministrationTime)!)
            administerDictionary.setValue(administeredDateString, forKey:ACTUAL_ADMINISTRATION_TIME)
        } else {
            medicationSlot.medicationAdministration?.actualAdministrationTime = DCDateUtility.dateInCurrentTimeZone(NSDate())
            let administeredDateString : NSString = dateFormatter.stringFromDate((medicationSlot.medicationAdministration.actualAdministrationTime))
            administerDictionary.setValue(administeredDateString, forKey:ACTUAL_ADMINISTRATION_TIME)
        }
        // To Do : for the sake of display of infusions , untill the API gets updated, this value need to be changed dynamic.
        var adminStatus = medicationSlot.medicationAdministration?.status
        if (adminStatus == STARTED || adminStatus == IN_PROGRESS) {
            medicationSlot.medicationAdministration?.status = IN_PROGRESS
            adminStatus = ADMINISTERED
        } else if (adminStatus == NOT_ADMINISTRATED) {
            adminStatus = REFUSED
        }
        administerDictionary.setValue(adminStatus, forKey: ADMINISTRATION_STATUS)
        if adminStatus == REFUSED {
            administerDictionary.setValue(true, forKey: IS_SELF_ADMINISTERED)
        } else {
            if let administratingStatus : Bool = medicationSlot.medicationAdministration?.isSelfAdministered.boolValue {
                if administratingStatus == false {
                    administerDictionary.setValue(medicationSlot.medicationAdministration?.administratingUser!.userIdentifier, forKey:"AdministratingUserIdentifier")
                }
                administerDictionary.setValue(true, forKey: IS_SELF_ADMINISTERED)
            }
        }
        
        //TO DO : Configure the dosage and batch number from the form.
        if let dosage = medicationDetails.dosage {
            administerDictionary.setValue(dosage, forKey: ADMINISTRATING_DOSAGE)
        }
        if let batch = medicationSlot.medicationAdministration?.batch {
            administerDictionary.setValue(batch, forKey: ADMINISTRATING_BATCH)
        }

        let notes : NSString  = administrationNotesBasedOnMedicationStatus (medicationSlot)
        administerDictionary.setValue(notes, forKey:ADMINISTRATING_NOTES)
        
        //TODO: currently hardcoded as ther is no expiry field in UI
        // administerDictionary.setValue("2015-10-23T19:40:00.000Z", forKey: EXPIRY_DATE)
        return administerDictionary
    }
    
    static func displayAlertWithTitle(title : NSString, message : NSString ) -> UIAlertController {
        //display alert view for view controllers
        let alertController : UIAlertController = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.Alert)
        let action : UIAlertAction = UIAlertAction(title: OK_BUTTON_TITLE, style: UIAlertActionStyle.Default, handler: { action in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(action)
        return alertController
    }
    
    // Return the note string based on the administrating status
    static func administrationNotesBasedOnMedicationStatus (medicationSlot : DCMedicationSlot) -> NSString{
        var noteString : NSString = EMPTY_STRING
        let status = medicationSlot.medicationAdministration.status
        if (status == ADMINISTERED || status == SELF_ADMINISTERED || status == STARTED || status == IN_PROGRESS)  {
            if let administeredNotes = medicationSlot.medicationAdministration?.administeredNotes {
                noteString = administeredNotes
            }
        } else if status == REFUSED || status == NOT_ADMINISTRATED {
            if let refusedNotes = medicationSlot.medicationAdministration?.refusedNotes {
                noteString =  refusedNotes
            }
        } else {
            if let omittedNotes = medicationSlot.medicationAdministration?.omittedNotes {
                noteString = omittedNotes
            }
        }
        return noteString
    }
    
    static func isMedicationDurationBasedInfusion (medication : DCMedicationScheduleDetails) -> Bool {
        // T0 Do : This is a temporary method to implement the status display for the duration based infusion , when the API gets updated - modifications needed.
        if (medication.route == "Subcutaneous" || medication.route == "Intravenous"){
            return true
        } else {
            return false
        }
    }

    
    static func entriesAreValidInMedication(medicationSlot : DCMedicationSlot) -> (Bool) {
        
        // check if the values entered are valid
        var isValid : Bool = true
        let medicationStatus = medicationSlot.medicationAdministration.status
        //notes will be mandatory always for omitted ones , it will be mandatory for administered/refused for early administration, currently checked for all cases
        if (medicationStatus == OMITTED) {
            //omitted medication status
            let omittedNotes = medicationSlot.medicationAdministration.omittedNotes
            if (omittedNotes == EMPTY_STRING || omittedNotes == nil) {
                isValid = false
            }
        } else if (medicationStatus == nil) {
            isValid = false
        }
        
        if (medicationSlot.medicationAdministration?.isEarlyAdministration == true) {
            
            //early administration condition
            if (medicationStatus == ADMINISTERED || medicationStatus == STARTED) {
                //administered medication status
                let notes : String? = medicationSlot.medicationAdministration?.administeredNotes
                if (notes == EMPTY_STRING || notes == nil) {
                    isValid = false
                }
            } else if (medicationStatus == REFUSED) {
                //refused medication status
                let refusedNotes = medicationSlot.medicationAdministration.refusedNotes
                if (refusedNotes == EMPTY_STRING || refusedNotes == nil) {
                    isValid = false
                }
            }
        }
        return isValid
    }
}