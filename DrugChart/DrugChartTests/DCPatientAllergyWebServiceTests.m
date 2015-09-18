//
//  DCPatientAllergyWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 10/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCPatientAllergyWebService.h"
#import "DCTestCaseUtility.h"

@interface DCPatientAllergyWebServiceTests : XCTestCase

@end

@implementation DCPatientAllergyWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetPatientAllergy {
    __block BOOL isDone = NO;

    DCPatientAllergyWebService *webService = [[DCPatientAllergyWebService alloc] init];
    [webService getPatientAllergiesForId:@"6a6f8a8e-0405-412f-aa57-8e01c84602a9" withCallBackHandler:^(NSArray *alergiesArray, NSError *error) {
        if (!error) {
            
            isDone = YES;
            XCTAssertNotNil(alergiesArray, @"response should not be nil ");
            XCTAssert([alergiesArray isKindOfClass:[NSArray class]], @"Should be NSArray, not a %@",[alergiesArray class]);
            if ([alergiesArray count] > 1) {
                
                NSDictionary *allergiesDictionary = [alergiesArray objectAtIndex:1];
                XCTAssertNotNil(allergiesDictionary, @"Should be not nil.");
                XCTAssert([allergiesDictionary isKindOfClass:[NSDictionary class]], @"Should be NSDictionary, not a %@",[allergiesDictionary class]);
            }
            
        } else {
            
            isDone = YES;
            XCTFail(@"%@",[error localizedDescription]);
        }
    }];
    
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
  
}

- (void)testGetPatientAllergyWithNoPatientId {
    __block BOOL isDone = NO;
    
    DCPatientAllergyWebService *webService = [[DCPatientAllergyWebService alloc] init];
    [webService getPatientAllergiesForId:@"" withCallBackHandler:^(NSArray *alergiesArray, NSError *error) {
        if (!error) {
            
            isDone = YES;
            XCTFail(@"Without patientId test should fail");
        } else {
            
            isDone = YES;
            XCTAssertNotNil(error, @"error should not be nil ");
            XCTAssert([error isKindOfClass:[NSError class]], @"Should be NSError, not a %@",[error class]);
        }
    }];
    
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
}

@end
