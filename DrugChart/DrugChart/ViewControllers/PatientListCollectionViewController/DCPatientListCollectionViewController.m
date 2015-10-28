//
//  DCPatientListCollectionViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/19/15.
//
//

#import "DCPatientListCollectionViewController.h"
#import "DCWardsPatientsListingViewController.h"
#import "DCBedWebService.h"
#import "DCBed.h"
#import "DCPatientsCollectionViewCell.h"
#import "DCPatientListHeaderView.h"
#import "DCPatientMedicationHomeViewController.h"
#import "DCMedicationSchedulesWebService.h"

typedef enum : NSUInteger {
    eOverDue,
    eImmediate,
    eNotImmediate
} SectionCount;

@interface DCPatientListCollectionViewController () {
    
    NSMutableArray *patientsListArray;
    NSMutableArray *bedsArray;
    NSMutableArray *overDueArray;
    NSMutableArray *immediateArray;
    NSMutableArray *nonImmediateArray;
    NSMutableArray *nextMedicationSortedPatientList;
    NSInteger selectedIndex;
}

@property (weak, nonatomic) IBOutlet UICollectionView *patientListCollectionView;

@end

@implementation DCPatientListCollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self fetchBedsInWardsToGetPatientList];
    } else {
        DCWardsPatientsListingViewController *wardsPatientsListingViewController  = (DCWardsPatientsListingViewController *)self.parentViewController;
        [wardsPatientsListingViewController recievedPatientListingResponse];
    }
    patientsListArray = [[NSMutableArray alloc] init];
    bedsArray = [[NSMutableArray alloc] init];
    nextMedicationSortedPatientList = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIViewController *destinationViewController = [segue destinationViewController];
    if ([destinationViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
        DCPatientMedicationHomeViewController *patientMedicationHomeViewController =
        (DCPatientMedicationHomeViewController *)destinationViewController;
        DCPatient *patient = [patientsListArray objectAtIndex:selectedIndex];
        patientMedicationHomeViewController.patient = patient;
    }
}

#pragma mark - Private Methods

- (void)fetchBedsInWardsToGetPatientList {
    
    NSString *wardID = self.selectedWard.wardId;
    DCBedWebService *bedWebService = [[DCBedWebService alloc] init];
    [bedWebService getBedDetailsInWard:wardID
                   withCallBackHandler:^(NSArray *bedArray, NSError *error) {
                       DCWardsPatientsListingViewController *wardsPatientsListingViewController  = (DCWardsPatientsListingViewController *)self.parentViewController;
                       [wardsPatientsListingViewController recievedPatientListingResponse];
                       
                       if (!error) {
                           [patientsListArray removeAllObjects];
                           for (NSDictionary *bedDetailDictionary in bedArray) {
                               DCBed *bed = [[DCBed alloc] initWithDictionary:bedDetailDictionary];
                               DCPatient *patient = bed.patient;
                               if (patient) {
                                   [patientsListArray addObject:patient];
                               }
                               [bedsArray addObject:bed];
                           }
                           [self setBedsArrayToWardsGraphicalViewController];
                           if ([patientsListArray count] > 0) {
                               // we need not have to fetch the medication list here, instead we
                               // now call it on selecting a particular patient.
                               [self sortPatientListArrayWithNextMedicationDate];
                               [self categorizePatientListBasedOnEmergency];
                              // [self performSelector:@selector(updateTableViewContentOffset) withObject:nil afterDelay:0.0];
                               [_patientListCollectionView reloadData];
                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                           }
                           else {
                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                               [self displayAlertWithTitle:NSLocalizedString(@"WARNING", @"") message:NSLocalizedString(@"NO_PATIENTS", @"No patients")];
                           }
                       } else {
                           [self handleErrorResponseForPatientList:error];
                       }
                      // [refreshControl endRefreshing];
                      // [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                   }];
}

// once the bedArray is populated its set to the graphical view of the wards.
// the bed details are used to draw the wards graphical display.
- (void)setBedsArrayToWardsGraphicalViewController {
    
    DCWardsPatientsListingViewController *wardsPatientsListingViewController  = (DCWardsPatientsListingViewController *)self.parentViewController;
    wardsPatientsListingViewController.bedsArray = bedsArray;
}

- (void)sortPatientListArrayWithNextMedicationDate {
    
    NSArray *sortedArray = [DCUtility sortArray:patientsListArray
                                     basedOnKey:NEXT_MEDICATION_DATE_KEY
                                      ascending:YES];
    NSMutableArray *noMedicationDateArray = [[NSMutableArray alloc] init];
    // the sorted patients with nextMedicationDate has to be shown on top
    // and patients without nextMedicationDate to be shown below it.
    for (DCPatient *patient in sortedArray) {
        if (patient.nextMedicationDate) {
            [nextMedicationSortedPatientList addObject:patient];
        }
        else {
            [noMedicationDateArray addObject:patient];
        }
    }
    if ([noMedicationDateArray count] > 0) {
        [nextMedicationSortedPatientList addObjectsFromArray:noMedicationDateArray];
    }
}

- (void)categorizePatientListBasedOnEmergency {
    
    //categorize patient list
    
    overDueArray = [[NSMutableArray alloc] init];
    immediateArray = [[NSMutableArray alloc] init];
    nonImmediateArray = [[NSMutableArray alloc] init];
    NSMutableArray *patientsArray = [[NSMutableArray alloc] init];
    NSArray *sortedArray = [DCUtility sortArray:patientsListArray
                                     basedOnKey:NEXT_MEDICATION_DATE_KEY
                                      ascending:YES];
    for (DCPatient *patient in sortedArray) {
        //split sorted array in to specific categories
        if (patient.emergencyStatus == kMedicationDue) {
            [overDueArray addObject:patient];
        } else if (patient.emergencyStatus == kMedicationInHalfHour || patient.emergencyStatus == kMedicationInOneHour) {
            [immediateArray addObject:patient];
        } else {
            [nonImmediateArray addObject:patient];
        }
    }
    [patientsArray addObject:@{OVERDUE_KEY : overDueArray}];
    [patientsArray addObject:@{IMMEDIATE_KEY : immediateArray}];
    [patientsArray addObject:@{NOT_IMMEDIATE_KEY : nonImmediateArray}];
}

- (void)handleErrorResponseForPatientList:(NSError *)error {
    
    if (error.code == NETWORK_NOT_REACHABLE) {
        
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
    } else if (error.code == WEBSERVICE_UNAVAILABLE) {
        
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
        
    } else {
        
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"NO_PATIENTS", @"No patients")];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (NSInteger )getSectionCountForPatientListView {
    
    NSInteger sectionCount = 0;
    if (overDueArray.count > 0) {
        sectionCount ++ ;
    }
    if (immediateArray.count > 0) {
        sectionCount ++;
    }
    if (nonImmediateArray.count > 0) {
        sectionCount ++;
    }
    return sectionCount;
}

- (NSInteger )getRowCountForSection:(NSInteger)section {
    
    if (section == eOverDue) {
        if (overDueArray.count > 0) {
            return overDueArray.count;
        } else {
            if (immediateArray.count > 0) {
                return immediateArray.count;
            } else {
                return nonImmediateArray.count;
            }
        }
    } else if (section == eImmediate) {
        if (immediateArray.count > 0) {
            return immediateArray.count;
        } else {
            return nonImmediateArray.count;
        }
    } else {
        return nonImmediateArray.count;
    }
    return 0;
}

- (DCPatientListHeaderView *)getHeaderViewAtIndexPath:(NSIndexPath *)indexPath {
    
    DCPatientListHeaderView *header = [_patientListCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PATIENT_LIST_HEADER_IDENTIFIER forIndexPath:indexPath];
    switch (indexPath.section) {
        case eOverDue:
            if (overDueArray.count > 0) {
                header.titleLabel.text = OVERDUE_KEY;
            } else {
                if (immediateArray.count > 0) {
                    header.titleLabel.text = IMMEDIATE_KEY;
                } else {
                    header.titleLabel.text = NOT_IMMEDIATE_KEY;
                }
            }
            break;
        case eImmediate:
            if (immediateArray.count > 0) {
                header.titleLabel.text = IMMEDIATE_KEY;
            } else {
                header.titleLabel.text = NOT_IMMEDIATE_KEY;
            }
            break;
        case eNotImmediate:
            header.titleLabel.text = NOT_IMMEDIATE_KEY;
            break;
        default:
            break;
    }
    return header;
}

- (void)fetchMedicationListForPatientId:(NSString *)patientId
                  withCompletionHandler:(void(^)(NSArray *result, NSError *error))completionHandler {
    
    DCMedicationSchedulesWebService *medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
    NSMutableArray *medicationListArray = [[NSMutableArray alloc] init];
    [medicationSchedulesWebService getMedicationSchedulesForPatientId:patientId withCallBackHandler:^(NSArray *medicationsList, NSError *error) {
        
        NSMutableArray *medicationArray = [NSMutableArray arrayWithArray:medicationsList];
        for (NSDictionary *medicationDetails in medicationArray) {
            DCDebugLog(@"the medication details dictionary:\n %@",medicationDetails);
//            @autoreleasepool {
//                DCMedicationScheduleDetails *medicationScheduleDetails = [[DCMedicationScheduleDetails alloc] initWithMedicationScheduleDictionary:medicationDetails];
//                if (medicationScheduleDetails) {
//                    [medicationListArray addObject:medicationScheduleDetails];
//                }
//            }
        }
        completionHandler(medicationListArray, nil);
    }];
}

#pragma mark - UICollectionView Datasource Methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    NSInteger rowCount = [self getRowCountForSection:section];
    return rowCount;
   // return [patientsListArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    NSInteger sectionCount = [self getSectionCountForPatientListView];
    return sectionCount;
   // return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DCPatientsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PATIENT_COLLECTION_IDENTIFIER forIndexPath:indexPath];
    DCPatient *patient = [patientsListArray objectAtIndex:indexPath.row];
    [cell populatePatientCellWithPatientDetails:patient];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    DCPatientListHeaderView *header = [self getHeaderViewAtIndexPath:indexPath];
    return header;
}

#pragma mark - Collection View delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = indexPath.row;
    DCPatient *patient = (DCPatient *)[patientsListArray objectAtIndex:indexPath.row];
    [self fetchMedicationListForPatientId:patient.patientId withCompletionHandler:^(NSArray *result, NSError *error) {
        
        patient.medicationListArray = result;
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self performSegueWithIdentifier:SHOW_PATIENT_MEDICATION_HOME sender:self];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:EMPTY_STRING
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

@end
