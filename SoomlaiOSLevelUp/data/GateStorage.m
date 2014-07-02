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

#import "GateStorage.h"
#import "LevelUp.h"
#import "Gate.h"
#import "KeyValueStorage.h"
#import "LevelUpEventHandling.h"


@implementation GateStorage


+ (void)setOpen:(BOOL)open forGate:(Gate*)gate {
    [self setOpen:open forGate:gate];
}

+ (void)setOpen:(BOOL)open forGate:(Gate*)gate andEvent:(BOOL)notify {
    NSString* key = [self keyGateOpen:gate.gateId];
    
    if (open) {
        [KeyValueStorage setValue:@"yes" forKey:key];
        
        if (notify) {
            [LevelUpEventHandling postGateOpened:gate];
        }
    } else {
        [KeyValueStorage deleteValueForKey:key];
    }
}

+ (BOOL)isOpen:(Gate*)gate {
    NSString* key = [self keyGateOpen:gate.gateId];
    NSString* val = [KeyValueStorage getValueForKey:key];
    return (val && [val length] > 0);
}


// Private

+ (NSString*)keyGatesWithGateId:(NSString*)gateId andPostfix:(NSString*)postfix {
    return [NSString stringWithFormat: @"%@gates.%@.%@", LU_DB_KEY_PREFIX, gateId, postfix];
}

+ (NSString*)keyGateOpen:(NSString*)gateId {
    return [self keyGatesWithGateId:gateId andPostfix:@"open"];
}

@end