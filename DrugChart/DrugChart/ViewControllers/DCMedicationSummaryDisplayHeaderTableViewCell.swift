//
//  DCMedicationSummaryDisplayHeaderTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 08/03/16.
//
//

import UIKit

class DCMedicationSummaryDisplayHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var medicineCategoryLabel: UILabel!
    @IBOutlet weak var dosageRouteAndInstructionLabel: UILabel!
    @IBOutlet weak var doseValueLabel: UILabel!
    @IBOutlet weak var pharmacistFirstStatusImageView: UIImageView!
    @IBOutlet weak var pharmacistSecondStatusImageView: UIImageView!
    @IBOutlet weak var pharmacistThirdStatusImageView: UIImageView!
    
    var medication : DCMedicationDetails?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureMedicationDetails(medicationDetails : DCMedicationScheduleDetails) {
        medicineNameLabel.text = medicationDetails.name
        if (medicationDetails.route != nil) {
            populateRouteAndInstructionLabelsWithDetails(medicationDetails)
        }
        self.medicineCategoryLabel.text = DCCalendarHelper.typeDescriptionForMedication(medicationDetails)
        self.doseValueLabel.text = medicationDetails.dosage
        medication = medicationDetails
        updatePharmacistStatusInCell()
    }
    
    func populateRouteAndInstructionLabelsWithDetails(medicationDetails : DCMedicationScheduleDetails) {
        
        //fill in route and instructions in required font
        let route : String = medicationDetails.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string:route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails.instruction != EMPTY_STRING && medicationDetails.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails.instruction)!)
        } else {
            instructionString = EMPTY_STRING
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        self.dosageRouteAndInstructionLabel.attributedText = attributedRouteString as NSAttributedString
    }
    
    func updatePharmacistStatusInCell() {
        
        if let pharmacistAction = medication?.pharmacistAction {
            //display logic
            if pharmacistAction.clinicalCheck == false {
                //display clinical check icon since pharamcist has not verified medication yet
                updateStatusIconsForClinicallyRemovedMedicationsWithPharmacistAction(pharmacistAction)
            } else {
                //clinical verified
                if let intervention = medication?.pharmacistAction?.intervention {
                    updateStatusIconsForClinicallyVerifiedMedicationsWithIntervention(intervention)
                }
            }
        }
    }
    
    func updateStatusIconsForClinicallyRemovedMedicationsWithPharmacistAction(pharmacistAction : DCPharmacistAction) {
        
        //firstimageview will display cli
        self.pharmacistFirstStatusImageView.image = UIImage(named: CLINICAL_CHECK_IPAD_IMAGE)
        if let intervention = pharmacistAction.intervention {
            if (intervention.toResolve == true) {
                //first image is intervention image
                self.pharmacistSecondStatusImageView.image = UIImage(named: INTERVENTION_IPAD_IMAGE)
                if let podStatus = pharmacistAction.podStatus {
                    self.pharmacistThirdStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                } else {
                    self.pharmacistThirdStatusImageView.image = nil
                }
            } else {
                //pod status
                if let podStatus = pharmacistAction.podStatus {
                    self.pharmacistSecondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
                } else {
                    self.pharmacistSecondStatusImageView.image = nil
                }
                self.pharmacistThirdStatusImageView.image = nil
            }
        } else {
            // display pod status
            if let podStatus = pharmacistAction.podStatus {
                self.pharmacistSecondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
            } else {
                self.pharmacistSecondStatusImageView.image = nil
            }
            self.pharmacistThirdStatusImageView.image = nil
        }
    }
    
    func updateStatusIconsForClinicallyVerifiedMedicationsWithIntervention(intervention : DCIntervention) {
        
        //if intervention is added, first imageview should display intervention icon. if pod status is updated,
        // second image view will show corresponding status image
        if (intervention.toResolve == true) {
            //first image is intervention image
            self.pharmacistFirstStatusImageView.image = UIImage(named: INTERVENTION_IPAD_IMAGE)
            if let podStatus = medication?.pharmacistAction?.podStatus {
                self.pharmacistSecondStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
            } else {
                self.pharmacistSecondStatusImageView.image = nil
            }
            self.pharmacistThirdStatusImageView.image = nil
        } else {
            if let podStatus = medication?.pharmacistAction?.podStatus {
                self.pharmacistFirstStatusImageView.image = DCPODStatus.statusImageForPodStatus(podStatus.podStatusType)
            } else {
                self.pharmacistFirstStatusImageView.image = nil
            }
            self.pharmacistSecondStatusImageView.image = nil
            self.pharmacistThirdStatusImageView.image = nil
        }
    }
}
