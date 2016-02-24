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
}