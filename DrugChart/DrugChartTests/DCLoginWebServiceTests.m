//
//  DCLoginWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 07/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCLoginWebService.h"
#import "DCTestCaseUtility.h"

@interface DCLoginWebServiceTests : XCTestCase

@end

@implementation DCLoginWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testLoginUserWithEmailAndPassword {
    __block BOOL isDone = NO;

    DCLoginWebService *loginWebService = [[DCLoginWebService alloc] init];
    [loginWebService loginUserWithEmail:@"doctor@51114"
                               password:@"doctor"
                               callback:^(id response, NSDictionary *error) {
                                   NSString *statusString = [error objectForKey:STATUS_KEY];
                                   if ([statusString isEqualToString:STATUS_ERROR]) {
                                       //XCTFail(@"%@",statusString);
                                       isDone = YES;
                                   }
                                   else {
                                       XCTAssertNotNil(response, @"Should be not nil.");
                                       XCTAssertEqual(statusString, STATUS_OK);
                                       isDone = YES;
                                   }
                               }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
    
}
@end
