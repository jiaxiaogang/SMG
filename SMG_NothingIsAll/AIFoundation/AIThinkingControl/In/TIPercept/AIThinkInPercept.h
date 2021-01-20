//
//  AIThinkInPercept.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIShortMatchModel;
@protocol AIThinkInPerceptDelegate <NSObject>

-(NSArray*) tir_getShortMatchModel;

@end

/**
 *  MARK:--------------------感性ThinkIn控制器部分--------------------
 *  @desc 感性In流程的learning类比,抽象;
 *  @desc 理性流程,即FindMV流程;
 */
@class AIFrontOrderNode,AICMVNode;
@interface AIThinkInPercept : NSObject

@property (weak, nonatomic) id<AIThinkInPerceptDelegate> delegate;

/**
 *  MARK:--------------------入口--------------------
 *  @param canAss       : NotNull
 *  @param updateEnergy : NotNull
 */
-(void) dataIn_FindMV:(NSArray*)algsArr
   createMvModelBlock:(AIFrontOrderNode*(^)(NSArray *algsArr,BOOL isMatch))createMvModelBlock
          finishBlock:(void(^)(AICMVNode *commitMvNode))finishBlock
               canAss:(BOOL(^)())canAss
         updateEnergy:(void(^)(CGFloat delta))updateEnergy;


/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 */
+(void) tip_OPushM:(AICMVNode*)newMv;

@end
