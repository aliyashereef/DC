//
//  DCMedicationSearchWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 08/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCMedicationSearchWebService.h"
#import "DCTestCaseUtility.h"
#import "DCMedication.h"

@interface DCMedicationSearchWebServiceTests : XCTestCase

@end

@implementation DCMedicationSearchWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testGetCompleteMedicationList {
    __block BOOL isDone = NO;
    
    DCMedicationSearchWebService *medicationWebService = [[DCMedicationSearchWebService alloc] init];
    medicationWebService.searchString = @"amo";
    [medicationWebService getCompleteMedicationListWithCallBackHandler:^(id response, NSDictionary *errorDict) {
        
        if (!errorDict) {
            
            isDone = YES;
            XCTAssertNotNil(response, @"response should not be nil ");
            XCTAssert([response isKindOfClass:[NSArray class]], @"Should be NSArray, not a %@",[response class]);
            if ([response count] > 0) {
                
                DCMedication *responseDict = [response objectAtIndex:1];
                XCTAssertNotNil(responseDict, @"Should be not nil.");
                XCTAssert([responseDict isKindOfClass:[DCMedication class]], @"Should be DCMedication, not a %@",[responseDict class]);

                
            }
        } else {
            
            isDone = YES;
            NSString *errorResponse = [errorDict valueForKey:@"message"];
            XCTFail(@"%@",errorResponse);
        }
    }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");

}

@end
