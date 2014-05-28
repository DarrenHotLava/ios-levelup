//
//  BlueprintEventHandling.m
//  SoomlaiOSBlueprint
//
//  Created by Gur Dotan on 5/25/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import "BlueprintEventHandling.h"

@implementation BlueprintEventHandling

+ (void)postScoreRecordChanged:(Score *)score {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:score forKey:DICT_ELEMENT_SCORE];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_BP_SCORE_RECORD_CHANGED object:self userInfo:userInfo];
}

+ (void)postGateOpened:(Gate *)gate {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:gate forKey:DICT_ELEMENT_GATE];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_BP_GATE_OPENED object:self userInfo:userInfo];
}

+ (void)postRewardGiven:(Reward *)reward {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reward forKey:DICT_ELEMENT_REWARD];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_BP_REWARD_GIVEN object:self userInfo:userInfo];
}

+ (void)postGateCanBeOpened:(Gate *)gate {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:gate forKey:DICT_ELEMENT_GATE];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_BP_GATE_CAN_BE_OPENED object:self userInfo:userInfo];
}

+ (void)postMissionCompleted:(Mission *)mission {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:mission forKey:DICT_ELEMENT_MISSION];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_BP_MISSION_COMPLETED object:self userInfo:userInfo];
}

@end
