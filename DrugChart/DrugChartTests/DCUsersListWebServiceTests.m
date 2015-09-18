//
//  DCUsersListWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 21/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCUsersListWebService.h"
#import "DCTestCaseUtility.h"

@interface DCUsersListWebServiceTests : XCTestCase

@end

@implementation DCUsersListWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetUsersList {
    __block BOOL isDone = NO;
    DCUsersListWebService *usersListWebService = [[DCUsersListWebService alloc] init];
    [usersListWebService getUsersListWithCallback:^(NSArray *usersList, NSError *error) {
        if (!error) {
            isDone = YES;
            XCTAssertNotNil(usersList, @"response should not be nil ");
            XCTAssert([usersList isKindOfClass:[NSArray class]], @"Should be NSArray, not a %@",[usersList class]);
            if ([usersList count] > 1) {
                NSDictionary *userDictionary = [usersList objectAtIndex:1];
                XCTAssertNotNil(userDictionary, @"Should be not nil.");
                XCTAssert([userDictionary isKindOfClass:[NSDictionary class]], @"Should be NSDictionary, not a %@",[userDictionary class]);
            }
        } else {
            isDone = YES;
            XCTFail(@"%@",[error localizedDescription]);
        }
     }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
}

@end
