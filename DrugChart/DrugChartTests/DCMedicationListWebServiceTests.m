//
//  DCMedicationListWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 08/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCMedicationListWebService.h"
#import "DCTestCaseUtility.h"

@interface DCMedicationListWebServiceTests : XCTestCase

@end

@implementation DCMedicationListWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetMedicationListForPatient {
    // To - Do : To implement after the API becomes active.
    DCMedicationListWebService *medicationListWebService = [[DCMedicationListWebService alloc] init];
    [medicationListWebService getMedicationListForPatientDemo:@"7048" withCallBackHandler:^(NSArray *medicationList, NSDictionary *error) {
        if (!error) {
            
        } else {
            
        }
    }];

}

@end
