//
//  DCAddMedicationDetailsWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 16/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCAddMedicationWebService.h"
#import "DCTestCaseUtility.h"
#import "DCConstants.h"
#import "DCDateUtility.h"

#define PATIENT_ID @"6a6f8a8e-0405-412f-aa57-8e01c84602a9"


@interface DCAddMedicationDetailsWebServiceTests : XCTestCase

@end

@implementation DCAddMedicationDetailsWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddMedicationDetailsForRegularMedication {
    __block BOOL isDone = NO;

    DCAddMedicationWebService *webService = [[DCAddMedicationWebService alloc] init];
    [webService addMedicationForMedicationType:REGULAR_MEDICATION forPatientId:PATIENT_ID withParameters:[self medicationDetailsDictionaryForType:REGULAR_MEDICATION] withCallbackHandler:^(id response, NSError *error) {
        if (!error) {
            isDone = YES;
            
        } else {
            isDone = YES;
            XCTFail(@"%@",[error localizedDescription]);
        }
    }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");

}
- (void)testAddMedicationDetailsForOnceMedication {
    __block BOOL isDone = NO;
    
    DCAddMedicationWebService *webService = [[DCAddMedicationWebService alloc] init];
    [webService addMedicationForMedicationType:ONCE_MEDICATION forPatientId:PATIENT_ID withParameters:[self medicationDetailsDictionaryForType:ONCE_MEDICATION] withCallbackHandler:^(id response, NSError *error) {
        if (!error) {
            isDone = YES;
        
            
        } else {
            isDone = YES;
            XCTFail(@"%@",[error localizedDescription]);
        }
    }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
    
}

- (void)testAddMedicationDetailsForWhenRequired {
    __block BOOL isDone = NO;
    
    DCAddMedicationWebService *webService = [[DCAddMedicationWebService alloc] init];
    [webService addMedicationForMedicationType:WHEN_REQUIRED forPatientId:PATIENT_ID withParameters:[self medicationDetailsDictionaryForType:WHEN_REQUIRED] withCallbackHandler:^(id response, NSError *error) {
        if (!error) {
            isDone = YES;
            
        } else {
            isDone = YES;
            XCTFail(@"%@",[error localizedDescription]);
        }
    }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
    
}


- (NSDictionary *)medicationDetailsDictionaryForType : (NSString *)type {
    
    NSMutableDictionary *medicationDictionary = [[NSMutableDictionary alloc] init];
    
    [medicationDictionary setValue:@"86641000033119" forKey:PREPARATION_ID];
    [medicationDictionary setValue:@"10 mg" forKey:DOSAGE_VALUE];
    [medicationDictionary setValue:@"take with water" forKey:INSTRUCTIONS];
    [medicationDictionary setValue:@"916601000006112" forKey:ROUTE_CODE_ID];
    NSArray *scheduleArray = [[NSMutableArray alloc] init];
    scheduleArray = @[@"14:00:00.000",
                      @"18:00:00.000"];
    
    if ([type isEqualToString:REGULAR_MEDICATION]) {
        
        [medicationDictionary setValue:@"2015-09-24T18:00:00.000Z" forKey:START_DATE_TIME];
        [medicationDictionary setValue:scheduleArray forKey:SCHEDULE_TIMES];
        
    } else if ([type isEqualToString:ONCE_MEDICATION]) {
        
        [medicationDictionary setValue:@"2015-09-24T18:00:00.000Z" forKey:SCHEDULED_DATE_TIME];
        
    } else {
        
        [medicationDictionary setValue:@"2015-09-24T18:00:00.000Z" forKey:START_DATE_TIME];
        [medicationDictionary setValue:@"2016-07-01T22:00:00.000Z" forKey:END_DATE_TIME];
    }
    return medicationDictionary;
}


@end
