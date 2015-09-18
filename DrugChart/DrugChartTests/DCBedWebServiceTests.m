//
//  DCBedWebServiceTests.m
//  DrugChart
//
//  Created by aliya on 08/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCBedWebService.h"
#import "DCTestCaseUtility.h"

@interface DCBedWebServiceTests : XCTestCase

@end

@implementation DCBedWebServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testGetBedDetailsInWard {
    __block BOOL isDone = NO;
    
    DCBedWebService *bedWebService = [[DCBedWebService alloc] init];
    [bedWebService getBedDetailsInWard:@"3d85593a-7c45-42bd-8a5a-266f3197be77"
                   withCallBackHandler:^(NSArray *bedArray, NSError *error) {
                       
                       if (!error) {
                           
                           isDone = YES;
                           XCTAssertNotNil(bedArray, @"Should be not nil.");
                           XCTAssert([bedArray isKindOfClass:[NSArray class]], @"Should be NSArray, not a %@",[bedArray class]);
                           if ([bedArray count] > 1) {
                               
                               NSDictionary *bedDetailDictionary = [bedArray objectAtIndex:1];
                               XCTAssertNotNil(bedDetailDictionary, @"Should be not nil.");
                               XCTAssert([bedDetailDictionary isKindOfClass:[NSDictionary class]], @"Should be NSDictionary, not a %@",[bedDetailDictionary class]);
                               XCTAssertNotNil([bedDetailDictionary valueForKey:@"bedStatus"], @"Should be not nil.");
                               XCTAssertNotNil([bedDetailDictionary valueForKey:@"identifier"], @"Should be not nil.");
                               XCTAssertNotNil([bedDetailDictionary valueForKey:@"bedDisplayNumber"], @"Should be not nil.");
                           }
                       } else {
                           isDone = YES;
                           XCTFail(@"%@",[error localizedDescription]);
                           
                       }
                   }];
    XCTAssertTrue([DCTestCaseUtility waitFor:&isDone timeout:10],@"Timed out waiting for response asynch method completion");
}

@end
