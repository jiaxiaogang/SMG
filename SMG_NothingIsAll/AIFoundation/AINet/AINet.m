//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "AIPointer.h"
#import "NSObject+Extension.h"
#import "AINetIndex.h"
#import "AICMVManager.h"
#import "AIPort.h"
#import "AIAbsManager.h"
#import "AINetDirectionReference.h"
#import "AIAbsCMVManager.h"
#import "AIAbsCMVNode.h"
#import "AIKVPointer.h"
#import "AINetIndexReference.h"
#import "AIFrontOrderNode.h"
#import "AINetUtils.h"
#import "AIAlgNodeManager.h"
#import "Output.h"

@interface AINet () <AICMVManagerDelegate,AIAbsCMVManagerDelegate>

@property (strong, nonatomic) AINetIndex *netIndex; //索引区(皮层/海马)
@property (strong, nonatomic) AICMVManager *cmvManager;     //网络树根(杏仁核)
@property (strong, nonatomic) AIAbsManager *absManager;     //抽具象序列
@property (strong, nonatomic) AINetDirectionReference *netDirectionReference;
@property (strong, nonatomic) AIAbsCMVManager *absCmvManager;//网络cmv的抽象;
@property (strong, nonatomic) AINetIndexReference *reference;

@end


@implementation AINet

static AINet *_instance;
+(AINet*) sharedInstance{
    if (_instance == nil) {
        _instance = [[AINet alloc] init];
    }
    return _instance;
}


-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.netIndex = [[AINetIndex alloc] init];
    self.cmvManager = [[AICMVManager alloc] init];
    self.cmvManager.delegate = self;
    self.absManager = [[AIAbsManager alloc] init];
    self.netDirectionReference = [[AINetDirectionReference alloc] init];
    self.reference = [[AINetIndexReference alloc] init];
    self.absCmvManager = [[AIAbsCMVManager alloc] init];
    self.absCmvManager.delegate = self;
}


//MARK:===============================================================
//MARK:                     < index >
//MARK:===============================================================
-(NSMutableArray*) getAlgsArr:(NSObject*)algsModel {
    if (algsModel) {
        NSDictionary *modelDic = [NSObject getDic:algsModel containParent:true];
        NSMutableArray *algsArr = [[NSMutableArray alloc] init];
        NSString *algsType = NSStringFromClass(algsModel.class);
        
        //1. algsType & dataSource
        for (NSString *dataSource in modelDic.allKeys) {
            //1. 转换AIModel&dataType;//废弃!(参考n12p12)
            //2. 存储索引;
            NSNumber *data = NUMTOOK([modelDic objectForKey:dataSource]);
            AIPointer *pointer = [self.netIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource isOut:false];
            if (pointer) {
                [algsArr addObject:pointer];
            }
        } 
        return algsArr;
    }
    return nil;
}

//单data装箱
-(AIPointer*) getNetDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    return [self.netIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource isOut:false];
}

//小脑索引
-(AIKVPointer*) getOutputIndex:(NSString*)dataSource outputObj:(NSNumber*)outputObj {
    if (outputObj) {
        return [self.netIndex getDataPointerWithData:outputObj algsType:NSStringFromClass(Output.class) dataSource:dataSource isOut:true];
    }
    return nil;
}


//MARK:===============================================================
//MARK:                     < reference >
//MARK:===============================================================

-(void) setNetReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue{
    [self.reference setReference:indexPointer target_p:target_p difStrong:difValue];
}

-(NSArray*) getNetReference:(AIKVPointer*)pointer limit:(NSInteger)limit {
    return [self.reference getReference:pointer limit:limit];
}


//MARK:===============================================================
//MARK:                     < cmv >
//MARK:===============================================================
-(AIFrontOrderNode*) createCMV:(NSArray*)imvAlgsArr order:(NSArray*)order{
    return [self.cmvManager create:imvAlgsArr order:order];
}


/**
 *  MARK:--------------------AICMVManagerDelegate--------------------
 */
-(void)aiNetCMV_CreatedNode:(AIKVPointer *)indexPointer nodePointer:(AIKVPointer *)nodePointer{
    if (ISOK(indexPointer, AIKVPointer.class)) {
        //1. kv_p时,记录node对index的引用;
        //2. op时,strong+1 & 记录输出的引用 & 记录可输出;
        [self setNetReference:indexPointer target_p:nodePointer difValue:1];
        
        //if (indexPointer.isOut) {
        //  [self.cerebel 记录可输出];
        //}
    }
}

-(void) aiNetCMV_CreatedCMVNode:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(NSInteger)difStrong{
    [self.netDirectionReference setNodePointerToDirectionReference:cmvNode_p mvAlgsType:mvAlgsType direction:direction difStrong:difStrong];
}

//MARK:===============================================================
//MARK:                     < abs >
//MARK:===============================================================
-(AINetAbsFoNode*) createAbs:(AIFoNodeBase*)foA foB:(AIFoNodeBase*)foB orderSames:(NSArray*)orderSames{
    return [self.absManager create:foA foB:foB orderSames:orderSames];
}

//MARK:===============================================================
//MARK:                     < directionReference >
//MARK:===============================================================
-(AIPort*) getNetNodePointersFromDirectionReference_Single:(NSString*)mvAlgsType direction:(MVDirection)direction {
    return ARR_INDEX([self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction limit:1], 0);
}

-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(int)limit{
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction limit:limit];
}

-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction filter:(NSArray*(^)(NSArray *protoArr))filter{
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction filter:filter];
}

-(void) setNetNodePointerToDirectionReference:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(int)difStrong{
    [self.netDirectionReference setNodePointerToDirectionReference:cmvNode_p mvAlgsType:mvAlgsType direction:direction difStrong:difStrong];
}


//MARK:===============================================================
//MARK:                     < absCmv >
//MARK:===============================================================
-(AIAbsCMVNode*) createAbsCMVNode:(AIKVPointer*)absNode_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p{
    return [self.absCmvManager create:absNode_p aMv_p:aMv_p bMv_p:bMv_p];
}

/**
 *  MARK:--------------------AIAbsCMVManagerDelegate--------------------
 */
-(void) aiNetCMVNode_createdAbsCMVNode:(AIKVPointer*)absCmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(NSInteger)difStrong{
    [self.netDirectionReference setNodePointerToDirectionReference:absCmvNode_p mvAlgsType:mvAlgsType direction:direction difStrong:difStrong];
}


//MARK:===============================================================
//MARK:                     < algNode >
//MARK:===============================================================
-(AIAlgNode*) createAlgNode:(NSArray*)algsArr{
    return [AIAlgNodeManager createAlgNode:algsArr];
}

-(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)algSames algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB{
    return [AIAlgNodeManager createAbsAlgNode:algSames algA:algA algB:algB];
}

@end
