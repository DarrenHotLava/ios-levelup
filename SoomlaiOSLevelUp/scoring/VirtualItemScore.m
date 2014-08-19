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

#import "VirtualItemScore.h"
#import "LUJSONConsts.h"
#import "SoomlaUtils.h"


@implementation VirtualItemScore

@synthesize associatedItemId;

static NSString* TAG = @"SOOMLA VirtualItemScore";


// TODO: Override other constructors and throw exceptions, since they don't have the associated item ID and desired balance

- (id)initWithScoreId:(NSString *)oScoreId andAssociatedItemId:(NSString *)oAssociatedItemId {
    if (self = [super initWithScoreId:oScoreId]) {
        self.associatedItemId = oAssociatedItemId;
    }
    
    return self;
}

- (id)initWithScoreId:(NSString *)oScoreId andName:(NSString *)oName andHigherBetter:(BOOL)oHigherBetter andAssociatedItemId:(NSString *)oAssociatedItemId {
    if (self = [super initWithScoreId:oScoreId andName:oName andHigherBetter:oHigherBetter]) {
        self.associatedItemId = oAssociatedItemId;
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        self.associatedItemId = dict[LU_ASSOCITEMID];
    }
    
    return self;
}

- (NSDictionary*)toDictionary {
    NSDictionary* parentDict = [super toDictionary];
    
    NSMutableDictionary* toReturn = [[NSMutableDictionary alloc] initWithDictionary:parentDict];
    [toReturn setObject:self.associatedItemId forKey:LU_ASSOCITEMID];
    
    return toReturn;
}

@end
