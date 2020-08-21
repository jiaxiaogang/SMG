//
//  AINetAbsUtils.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/6/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIKVPointer,AIPort;
@interface AINetAbsFoUtils : NSObject

/**
 *  MARK:--------------------从ports中搜索出某个port--------------------
 *  判断条件 : port的指针是target_p;
 */
+(AIPort*) searchPortWithTargetP:(AIKVPointer*)target_p fromPorts:(NSArray*)ports;

/**
 *  MARK:--------------------从conFos中提取deltaTimes--------------------
 *  @result notnull
 */
+(NSMutableArray*) getDeltaTimes:(NSArray*)conFos absFo:(AIFoNodeBase*)absFo;

/**
 *  MARK:--------------------将order转换成alg_ps--------------------
 */
+(NSMutableArray*) convertOrder2Alg_ps:(NSArray*)order;

/**
 *  MARK:--------------------将order转成deltaTimes--------------------
 */
+(NSMutableArray*) convertOrder2DeltaTimes:(NSArray*)order;

@end
