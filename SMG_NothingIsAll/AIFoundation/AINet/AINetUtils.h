//
//  AINetUtils.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AINetUtils : NSObject

/**
 *  MARK:--------------------检查是否可以输出algsType&dataSource--------------------
 *  1. 有过输出记录,即可输出;
 */
+(BOOL) checkCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource;


/**
 *  MARK:--------------------标记canout--------------------
 *  @param algsType     : 分区标识
 *  @param dataSource   : 算法标识
 */
+(void) setCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource ;


/**
 *  MARK:--------------------插线到ports--------------------
 */
+(void) insertPointer:(AIPointer*)pointer toPorts:(NSMutableArray*)ports;


/**
 *  MARK:--------------------插线到ports (分文件优化)--------------------
 *  @param pointerFileName : 指针序列文件名,如FILENAME_Reference_ByPointer
 *  @param portFileName : 强度序列文件名,如FILENAME_Reference_ByPort
 *
 *  1. 各种神经元中只保留"指针"和"类型";
 *  2. 其它absPorts,conPorts,refPorts都使用单独文件的方式;
 *  3. 暂不使用 (未完成)
 */
-(void) insertPointer:(AIKVPointer*)node_p target_p:(AIKVPointer*)target_p difStrong:(int)difStrong pointerFileName:(NSString*)pointerFileName portFileName:(NSString*)portFileName;

@end
