//
//  onestongTests.m
//  onestongTests
//
//  Created by 王亮 on 14-4-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EventsService.h"

@interface onestongTests : XCTestCase{
    EventsService * eventService;
}
@end

@implementation onestongTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
     eventService = [[EventsService alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testfindSomedayOwnSignEvents
{
    [eventService findSomedayOwnSignEvents:@"2014-4-22"];
}

@end
