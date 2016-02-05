//
//  DCAlertsWebServiceTestCases.m
//  DrugChart
//
//  Created by aliya on 07/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCAlertsWebService.h"
#import "DCTestCaseUtility.h"

@interface DCAlertsWebServiceTestCases : XCTestCase

@end

@implementation DCAlertsWebServiceTestCases

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testGetPatientAlert {
    __block BOOL isDone = NO;

    DCAlertsWebService *webService = [[DCAlertsWebService alloc] init];
    [webService patientAlertsForId:@"6a6f8a8e-0405-412f-aa57-8e01c84602a9" withCallBackHandler:^(NSArray *alertsArray, NSError *error) {
        if (!error) {
            XCTAssertNotNil(alertsArray, @"Should be not nil.");
            XCTAssert([alertsArray isKindOfClass:[NSArray class]], @"Should be NSArray, not a %@",[alertsArray class]);
            isDone = YES;

        } else {
            XCTFail(@"%@",[error localizedDescription]);
            isDone = YES;
        }

        }];
        XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
}

@end
