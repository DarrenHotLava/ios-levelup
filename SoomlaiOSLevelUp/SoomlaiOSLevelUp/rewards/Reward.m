/*
 Copyright (C) 2012-2014 Soomla Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "Reward.h"
#import "BPJSONConsts.h"
#import "RewardStorage.h"
#import "StoreUtils.h"
#import "BadgeReward.h"
#import "VirtualItemReward.h"
#import "RandomReward.h"
#import "SequenceReward.h"
#import "DictionaryFactory.h"
#import "LevelUpEventHandling.h"

@implementation Reward

@synthesize rewardId, name, repeatable;

static NSString* TAG = @"SOOMLA Reward";
static NSString* TYPE_NAME = @"reward";
static DictionaryFactory* dictionaryFactory;
static NSDictionary* typeMap;


- (id)initWithRewardId:(NSString *)oRewardId andName:(NSString *)oName {
    self = [super init];
    if ([self class] == [Reward class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Error, attempting to instantiate AbstractClass directly." userInfo:nil];
    }
    
    if (self) {
        self.rewardId = oRewardId;
        self.name = oName;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if ([self class] == [Reward class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Error, attempting to instantiate AbstractClass directly." userInfo:nil];
    }
    
    if (self) {
        self.rewardId = dict[BP_REWARD_REWARDID];
        self.name = dict[BP_NAME];
        self.repeatable = [dict[BP_REWARD_REPEAT] boolValue];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            self.rewardId, BP_REWARD_REWARDID,
            self.name, BP_NAME,
            self.repeatable, BP_REWARD_REPEAT,
            nil];
}

- (BOOL)give {
    if ([RewardStorage isRewardGiven:self] && !self.repeatable) {
        LogDebug(TAG, ([NSString stringWithFormat:@"Reward was already given and is not repeatable. id: %@", self.rewardId]));
        return NO;
    }

    if ([self giveInner]) {
        [RewardStorage setStatus:YES forReward:self];
        return YES;
    }
    
    return NO;
}

- (BOOL)take {
    if ([RewardStorage isRewardGiven:self]) {
        LogDebug(TAG, ([NSString stringWithFormat:@"Reward not give. id: %@", self.rewardId]));
        return NO;
    }
    
    if ([self takeInner]) {
        [RewardStorage setStatus:NO forReward:self];
        [LevelUpEventHandling postRewardTaken:self];
        return YES;
    }
    return NO;
}

- (BOOL)isOwned {
    return [RewardStorage isRewardGiven:self];
}

- (BOOL)giveInner {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)takeInner {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


// Static methods

+ (Reward *)fromDictionary:(NSDictionary *)dict {
    return (Reward *)[dictionaryFactory createObjectWithDictionary:dict andTypeMap:typeMap];
}

+ (NSString *)getTypeName {
    return TYPE_NAME;
}


+ (void)initialize {
    if (self == [Reward self]) {
        dictionaryFactory = [[DictionaryFactory alloc] init];
        typeMap = @{
                    [BadgeReward getTypeName]       : [BadgeReward class],
                    [RandomReward getTypeName]      : [RandomReward class],
                    [SequenceReward getTypeName]    : [SequenceReward class],
                    [VirtualItemReward getTypeName] : [VirtualItemReward class]
                    };
    }
}


@end