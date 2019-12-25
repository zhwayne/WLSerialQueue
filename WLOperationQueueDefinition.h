//
//  WLOperationQueueDefinition.h
//  WLOperationQueue
//
//  Created by 张尉 on 2018/7/9.
//  Copyright © 2018年 Wayne. All rights reserved.
//

#ifndef UniversalQueueProtocol_h
#define UniversalQueueProtocol_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WLOperationGroup;

@protocol WLOperationQueueDefinition <NSObject>

#pragma mark - 添加

/// 向默认全局队列添加一个操作，该操作会在何时的时机自动执行。添加的操作无法取消。
/// @param operation 操作对象：一般为 NSOperation 的子类。
- (void)addOperationToDefaultQueue:(NSOperation *)operation;

/// 向指定的队列添加一个操作，该操作会在何时的时机自动执行。如果指定的队列不存在则会自动创建一个新的队列。
/// @param operation 操作对象：一般为 NSOperation 的子类。
/// @param queueName 指定的队列名
- (void)addOperation:(NSOperation *)operation toQueueWithName:(nullable NSString *)queueName;

/// 添加一个操作组，组内所有操作都将在同一队列中执行。该方法会使用组名创建一个队列（如果不存在）。
/// 添加同一所属的操作组（组名相同）时，如果与组名绑定的队列存在，则会向其中追加操作。但无论如何，
/// 我们都不建议这么做。
/// @param group 操作组对象，包含若干个操作。
- (void)addOperationGroup:(WLOperationGroup *)group;

#pragma mark - 取消

/// 取消某个操作组内的所有操作（如果组存在）
/// @param groupName 操作组的名称
- (void)cancelAllOperationsInGroupWithName:(NSString *)groupName;

/// 取消指定队列中的所有操作。注意，操作不会立即全部停止，正在执行的操作无法取消。
/// @param queueName 指定的队列名
- (void)cancelAllOperationsInQueueWithName:(NSString *)queueName;

/// 取消默认队列中的全部操作。
- (void)cancelAllOperationsInDefaultQueue;

/// 取消已知的全部操作。该方法会遍历所有现存的队列并依次取消其中的操作。
- (void)cancelAllOperations NS_UNAVAILABLE;

#pragma mark - 查询

/// 获取指定的队列的现存操作
/// @param queueName 指定的队列名
- (nullable NSArray<NSOperation*> *)operationsInQueue:(nullable NSString *)queueName;

/// 获取全局队列的现存操作
- (nullable NSArray<NSOperation*> *)operationsInDefaultQueue;

/// 获取组内的现存操作
/// @param queueName 指定的组名
- (nullable NSArray<NSOperation*> *)operationsInGroup:(NSString *)groupName;

@end

NS_ASSUME_NONNULL_END

#endif /* UniversalQueueProtocol_h */
