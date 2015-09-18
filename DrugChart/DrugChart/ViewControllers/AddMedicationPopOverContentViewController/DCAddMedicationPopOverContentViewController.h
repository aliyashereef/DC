//
//  DCAddMedicationPopOverContentViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 4/17/15.
//
//

#import <UIKit/UIKit.h>


typedef void (^NewDosageRecieved)(NSString *dosage);
typedef void(^EntrySelected)(NSDictionary *contentDictionary);

@interface DCAddMedicationPopOverContentViewController : UITableViewController

@property (nonatomic) AddMedicationPopOverContentType contentType;
@property (nonatomic, strong) NewDosageRecieved newDosageRecieved;
@property (nonatomic, strong) EntrySelected entrySelected;
@property (nonatomic, strong) NSArray *dosageArray;
@property (nonatomic, strong) NSString *selectedDosage;

@end
