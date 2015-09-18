//
//  DCWardWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 08/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCWardWebService.h"
#import "DCTestCaseUtility.h"

@interface DCWardWebServiceTests : XCTestCase

@end

@implementation DCWardWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetAllWardsForUser {
    __block BOOL isDone = NO;
    
    DCWardWebService *wardsWebService = [[DCWardWebService alloc] init];
    [wardsWebService getAllWardsForUser:nil withCallBackHandler:^(id response, NSError *error) {
        if (!error) {
            
            isDone = YES;
            XCTAssertNotNil(response, @"response should not be nil ");
            XCTAssert([response isKindOfClass:[NSArray class]], @"Should be NSArray, not a %@",[response class]);
            if ([response count] > 1) {
                
                NSDictionary *wardsDictionary = [response objectAtIndex:1];
                XCTAssertNotNil(wardsDictionary, @"Should be not nil.");
                XCTAssert([wardsDictionary isKindOfClass:[NSDictionary class]], @"Should be NSDictionary, not a %@",[wardsDictionary class]);
                XCTAssertNotNil([wardsDictionary valueForKey:@"displayNumber"]);
                XCTAssertNotNil([wardsDictionary valueForKey:@"displayName"]);
                XCTAssertNotNil([wardsDictionary valueForKey:@"identifier"]);
            }
            
        } else {
            
            isDone = YES;
            XCTFail(@"%@",[error localizedDescription]);
        }
    }];
    
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
}

@end
