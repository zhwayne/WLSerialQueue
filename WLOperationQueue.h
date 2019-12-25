//
//  WLOperationQueue.h
//  WLOperationQueue
//
//  Created by 张尉 on 2018/7/6.
//  Copyright © 2018年 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "WLOperationQueueDefinition.h"
#import "WLOperationGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLOperationQueue : NSObject <WLOperationQueueDefinition>

+ (instancetype)queueForID:(NSString *)ID;
+ (instancetype)queueForID:(NSString *)ID asynchronous:(BOOL)asynchronous;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
