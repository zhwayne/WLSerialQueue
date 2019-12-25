//
//  WLOperationGroup.h
//  WLOperationQueue
//
//  Created by 张尉 on 2018/7/9.
//  Copyright © 2018年 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLOperationGroup : NSObject

/// 组名，不能为空！
@property (nonatomic, copy, readonly) NSString *name;

/// 所有的操作对象
@property (nonatomic, readonly, nullable) NSArray <NSOperation*> *operations;

/// 该组内的操作是否允许并发执行
@property (nonatomic, readonly, getter=isAsynchronous) BOOL asynchronous;

/// 组内允许的最大并发数，只在 `isAsynchronous` 为 YES 时有效。w
/// 为 0 时表示不限制并发数，实际并发数量由系统控制。
@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;

/// 组内所有操作已完成的回调函数。
@property (nonatomic, copy, nullable) void (^allOperationsAreFinished)(void);

- (instancetype)initWithName:(NSString *)name asynchronous:(BOOL)asynchronous;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 从数组中添加操作，由于添加操作是线程安全的，因此当一次性添加多个操作时，推荐用此方式。
/// @param operations 操作数组
- (void)addOperations:(NSArray <NSOperation *>*)operations;
- (void)addOperation:(NSOperation *)operation;

@end

NS_ASSUME_NONNULL_END
