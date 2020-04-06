//
//  TIRUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/1/10.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIRUtils : NSObject

/**
 *  MARK:--------------------时序识别之: protoFo&assFo匹配判断--------------------
 */
+(void) TIR_Fo_CheckFoValidMatch:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo checkItemValid:(BOOL(^)(AIKVPointer *itemAlg,AIKVPointer *assAlg))checkItemValid success:(void(^)(NSInteger lastAssIndex,CGFloat matchValue))success failure:(void(^)(NSString *msg))failure;


//MARK:===============================================================
//MARK:                     < 概念局部匹配 >
//MARK:===============================================================

/**
 *  MARK:--------------------概念局部匹配--------------------
 *  @param except_ps : 排除_ps; (如:同一批次输入的概念组,不可用来识别自己)
 */
+(AIAlgNodeBase*) partMatching_Alg:(AIAlgNodeBase*)algNode isMem:(BOOL)isMem except_ps:(NSArray*)except_ps;

/**
 *  MARK:--------------------通用局部匹配方法--------------------
 *  注: 根据引用找出相似度最高且达到阀值的结果返回; (相似度匹配)
 *  从content_ps的所有value.refPorts找前cPartMatchingCheckRefPortsLimit个, 如:contentCount9*limit5=45个;
 *  @param checkBlock : notnull 对可能的结果,进行检查; (就是自身 或 不应期则false)
 *  @param refPortsBlock : notnull 取item_p.refPorts的方法;
 *  @result 把最匹配的返回;
 */
+(id) partMatching_General:(NSArray*)proto_ps
             refPortsBlock:(NSArray*(^)(AIKVPointer *item_p))refPortsBlock
                checkBlock:(BOOL(^)(AIPointer *target_p))checkBlock;


//MARK:===============================================================
//MARK:                     < 模糊匹配 >
//MARK:===============================================================
+(NSArray*) matchAlg2FuzzyAlgV2:(AIAlgNodeBase*)protoAlg matchAlg:(AIAlgNodeBase*)matchAlg except_ps:(NSArray*)except_ps;


//MARK:===============================================================
//MARK:                     < 内类比 >
//MARK:===============================================================

//内类比构建抽象概念
+(AIAbsAlgNode*)createInnerAbsAlg_NoRepeat:(AIAlgNodeBase*)conAlg value_p:(AIPointer*)value_p;

//内类比构建抽象时序
+(AINetAbsFoNode*)createInnerAbsFo:(AIAlgNodeBase*)backAlg rangeAlg_ps:(NSArray*)rangeAlg_ps conFo:(AIFoNodeBase*)conFo;

@end
