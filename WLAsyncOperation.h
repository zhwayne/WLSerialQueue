//
//  WLAsyncOperation.h
//  WLAsyncOperation
//
//  Created by 张尉 on 2018/7/6.
//  Copyright © 2018年 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WLAsyncOperation;

typedef void(^WLAsyncOperationBlock)(WLAsyncOperation *operation);

/// 支持异步操作的 Operation
@interface WLAsyncOperation : NSOperation

@property (nonatomic, copy, nullable) WLAsyncOperationBlock block;

@property (nonatomic, copy, nullable) void (^beginningBlock)(void);

+ (WLAsyncOperation *)asyncOperationWithBlock:(WLAsyncOperationBlock)block;
+ (WLAsyncOperation *)asyncOperationWithBlock:(WLAsyncOperationBlock)block inMainQueue:(BOOL)runInMainQueue;

- (void)finish;

@end

NS_ASSUME_NONNULL_END
