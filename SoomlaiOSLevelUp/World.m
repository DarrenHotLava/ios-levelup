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

#import "World.h"
#import "Challenge.h"
#import "Score.h"
#import "RangeScore.h"
#import "VirtualItemScore.h"
#import "GatesList.h"
#import "GatesListAND.h"
#import "GatesListOR.h"
#import "WorldStorage.h"
#import "JSONConsts.h"
#import "LUJSONConsts.h"
#import "SoomlaUtils.h"
#import "DictionaryFactory.h"
#import "Reward.h"

@implementation World

@synthesize worldId, gates, innerWorlds, scores, challenges;

static NSString* TAG = @"SOOMLA World";
static DictionaryFactory* dictionaryFactory;


- (id)initWithWorldId:(NSString *)oWorldId {
    if (self = [super init]) {
        worldId = oWorldId;
        gates = nil;
        innerWorlds = [NSMutableDictionary dictionary];
        scores = [NSMutableDictionary dictionary];
        challenges = [NSMutableArray array];
    }
    return self;
}

- (id)initWithWorldId:(NSString *)oWorldId andGates:(GatesList *)oGates
       andInnerWorlds:(NSMutableDictionary *)oInnerWorlds andScores:(NSMutableDictionary *)oScores andChallenges:(NSArray *)oChallenges {
    if (self = [super init]) {
        worldId = oWorldId;
        gates = oGates;
        innerWorlds = oInnerWorlds;
        scores = oScores;
        challenges = [NSMutableArray arrayWithArray:oChallenges];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        
        worldId = dict[LU_WORLD_WORLDID];
        
        NSMutableDictionary* tmpInnerWorlds = [NSMutableDictionary dictionary];
        NSArray* innerWorldDicts = dict[LU_WORLDS];
        
        // Iterate over all inner worlds in the JSON array and for each one create
        // an instance according to the world type
        for (NSDictionary* innerWorldDict in innerWorldDicts) {
            
            World* world = [World fromDictionary:innerWorldDict];
            if (world) {
                [tmpInnerWorlds setObject:world forKey:world.worldId];
            }
        }
        
        innerWorlds = tmpInnerWorlds;
        
        
        NSMutableDictionary* tmpScores = [NSMutableDictionary dictionary];
        NSArray* scoreDicts = dict[LU_SCORES];
        
        // Iterate over all scores in the JSON array and for each one create
        // an instance according to the score type
        for (NSDictionary* scoreDict in scoreDicts) {
            
            Score* score = [Score fromDictionary:scoreDict];
            if (score) {
                [tmpScores setObject:score forKey:score.scoreId];
            }
        }

        scores = tmpScores;
        
        
        NSMutableArray* tmpChallenges = [NSMutableArray array];
        NSArray* challengeDicts = dict[LU_CHALLENGES];
        
        // Iterate over all challenges in the JSON array and create an instance for each one
        for (NSDictionary* challengeDict in challengeDicts) {
            [tmpChallenges addObject:[[Challenge alloc] initWithDictionary:challengeDict]];
        }
        
        challenges = tmpChallenges;

        
        NSDictionary* gateListDict = dict[LU_GATES];
        gates = [GatesList fromDictionary:gateListDict];
    }
    
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject:NSStringFromClass([self class]) forKey:SOOM_CLASSNAME];
    [dict setObject:self.worldId forKey:LU_WORLD_WORLDID];
    
    NSMutableArray* innerWorldsArr = [NSMutableArray array];
    for (NSString* innerWorldId in self.innerWorlds) {
        [innerWorldsArr addObject:[self.innerWorlds[innerWorldId] toDictionary]];
    }
    [dict setObject:innerWorldsArr forKey:LU_WORLDS];
    
    NSMutableArray* scoresArr = [NSMutableArray array];
    for (NSString* scoreId in self.scores) {
        [innerWorldsArr addObject:[self.scores[scoreId] toDictionary]];
    }
    [dict setObject:scoresArr forKey:LU_SCORES];
    
    NSMutableArray* challengesArr = [NSMutableArray array];
    for (Challenge* challenge in self.challenges) {
        [challengesArr addObject:[challenge toDictionary]];
    }
    [dict setObject:challengesArr forKey:LU_CHALLENGES];
    
    [dict setObject:self.gates.toDictionary forKey:LU_GATES];
    
    return dict;
}

- (void)addChallenge:(Challenge *)challenge {
    [self.challenges addObject:challenge];
}

- (NSDictionary *)getRecordScores {
    NSMutableDictionary* recordScores = [NSMutableDictionary dictionary];
    for (Score* score in self.scores) {
        [recordScores setObject:[NSNumber numberWithDouble:[score getRecord]] forKey:score.scoreId];
    }
    return recordScores;
}

- (NSDictionary *)getLatestScores {
    NSMutableDictionary* latestScores = [NSMutableDictionary dictionary];
    for (Score* score in self.scores) {
        [latestScores setObject:[NSNumber numberWithDouble:[score getLatest]] forKey:score.scoreId];
    }
    return latestScores;
}

- (void)setValue:(double)scoreVal toScoreWithScoreId:(NSString *)scoreId {
    Score* score = [self.scores objectForKey:scoreId];
    if (!score) {
        LogError(TAG, ([NSString stringWithFormat:@"(setScore) Can't find scoreId: %@  worldId: %@", scoreId, self.worldId]));
        return;
    }
    [score setTempScore:scoreVal];
}

- (void)addScore:(Score *)score {
    [self.scores setObject:score forKey:score.scoreId];
}

- (void)addGate:(Gate *)gate {
    if (!self.gates) {
        gates = [[GatesListAND alloc] initWithGateId:[[NSUUID UUID] UUIDString]];
    }
    [self.gates addGate:gate];
}

- (void)addInnerWorld:(World *)world {
    [self.innerWorlds setObject:world forKey:world.worldId];
}

- (BOOL)isCompleted {
    return [WorldStorage isWorldCompleted:self];
}

- (void)setCompleted:(BOOL)completed {
    [self setCompleted:completed recursively:NO];
}

- (void)setCompleted:(BOOL)completed recursively:(BOOL)recursive {
    
    if (recursive) {
        for (World* world in self.innerWorlds) {
            [world setCompleted:completed recursively:YES];
        }
    }
    [WorldStorage setCompleted:completed forWorld:self];
}

- (BOOL)canStart {
    return !self.gates || [self.gates isOpen];
}

- (void)assignReward:(Reward*)reward {
    [WorldStorage setReward:reward.rewardId forWorld:self];
}

- (NSString*)getAssignedRewardId {
    return [WorldStorage getAssignedReward:self];
}


// Static methods

+ (World *)fromDictionary:(NSDictionary *)dict {
    return (World *)[dictionaryFactory createObjectWithDictionary:dict];
}

+ (void)initialize {
    if (self == [World self]) {
        dictionaryFactory = [[DictionaryFactory alloc] init];
    }
}



@end
