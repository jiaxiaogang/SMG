//
//  AIFoNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/19.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------时序节点基类--------------------
 *  @name 前因序列
 *  1. 是frontOrderNode和absNode的基类;
 */
@interface AIFoNodeBase : AINodeBase

/**
 *  MARK:--------------------cmvNode_p结果--------------------
 *  @desc 指向mv基本模型的价值影响节点;
 */
@property (strong, nonatomic) AIKVPointer *cmvNode_p;

/**
 *  MARK:--------------------生物钟时间间隔记录--------------------
 *  @desc
 *      1. 功能: 用于记录时序中,每元素间的生物钟间隔 (单位:s);
 *      2. 比如: [我,打,豆豆]->{mv+},记录成deltaTime后为[0,1,100,0];
 *      3. 表示: 我用1ms打了,100ms豆豆,0ms内就感受到了爽;
 *      4. 首位: 首位总是0,因为本序列采用了首位参照,所以为0;
 *  @deltaTimes元素有可能为0的情况;
 *      1. 首位为0;
 *      2. 末位为N或L时,为0 (因为N和L抽象自frontAlg);
 *      3. isOut=true时,为0,比如反射反应触发"吃",是即时触发的,自然是0;
 */
@property (strong, nonatomic) NSMutableArray *deltaTimes;
@property (assign, nonatomic) NSTimeInterval mvDeltaTime;

@property (strong, nonatomic) NSMutableArray *diffSubPorts; //反向反馈-虚mv时序
@property (strong, nonatomic) NSMutableArray *diffBasePorts;//反向反馈-实mv时序

@end
