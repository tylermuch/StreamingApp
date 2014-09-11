//
//  AudioManagerTests.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AudioManagerTests.h"
#import "AudioManager.h"

@interface StreamingAppTests : XCTestCase

@end

@implementation AudioManagerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAudioManagerSingleton {
    AudioManager *obj1;
    AudioManager *obj2;
    
    obj1 = [AudioManager sharedInstance];
    obj2 = [AudioManager sharedInstance];
    XCTAssertEqualObjects(obj1, obj2);
}

@end
