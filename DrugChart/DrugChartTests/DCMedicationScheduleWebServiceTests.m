//
//  DCMedicationScheduleWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 21/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCMedicationSchedulesWebService.h"
#import "DCTestCaseUtility.h"

@interface DCMedicationScheduleWebServiceTests : XCTestCase

@end

@implementation DCMedicationScheduleWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetMedicationSchedules {
    __block BOOL isDone = NO;
    DCMedicationSchedulesWebService *medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
    [medicationSchedulesWebService getMedicationSchedulesForPatientId:@"6a6f8a8e-0405-412f-aa57-8e01c84602a9" withCallBackHandler:^(NSArray *medicationsList, NSError *error) {
        if (!error) {
            
            isDone = YES;
            XCTAssertNotNil(medicationsList, @"response should not be nil ");
            XCTAssert([medicationsList isKindOfClass:[NSArray class]], @"Should be NSArray, not a %@",[medicationsList class]);
            if ([medicationsList count] > 1) {
                
                NSDictionary *medicationDictionary = [medicationsList objectAtIndex:1];
                XCTAssertNotNil(medicationDictionary, @"Should be not nil.");
                XCTAssert([medicationDictionary isKindOfClass:[NSDictionary class]], @"Should be NSDictionary, not a %@",[medicationDictionary class]);
            }
            
        } else {
            
            isDone = YES;
            XCTFail(@"%@",[error localizedDescription]);
        }
    }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
}

- (void)testGetMedicationSchedulesWithNoPatientId {
    __block BOOL isDone = NO;
    DCMedicationSchedulesWebService *medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
    [medicationSchedulesWebService getMedicationSchedulesForPatientId:@"" withCallBackHandler:^(NSArray *medicationsList, NSError *error) {
        if (!error) {
            
            isDone = YES;
            XCTFail(@"Should fail without a patient Id");
        } else {
            
            isDone = YES;
            XCTAssertNotNil(error, @"error should not be nil ");
            XCTAssert([error isKindOfClass:[NSError class]], @"Should be NSError, not a %@",[error class]);
        }
    }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
}
@end
