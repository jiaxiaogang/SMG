//
//  ModuleView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "ModuleView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "NodeView.h"
#import "NodeCompareModel.h"

@interface ModuleView ()<NodeViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (strong, nonatomic) NSMutableArray *nodeArr;

@end

@implementation ModuleView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setBackgroundColor:[UIColor clearColor]];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
}

-(void) initData{
    self.nodeArr = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    [self refreshDisplay_Line];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setDataWithModuleId:(NSString*)moduleId{
    _moduleId = moduleId;
    [self.titleLab setText:STRTOOK(self.moduleId)];
}

-(void) setDataWithNodeData:(id)nodeData{
    if (![self.nodeArr containsObject:nodeData]) {
        [self.nodeArr addObject:nodeData];
        [self refreshDisplayWithNodeData:nodeData];
    }
}

-(void) refreshDisplayWithNodeData:(id)nodeData{
    //1. 显示新节点
    if (nodeData) {
        NodeView *nodeView = [[NodeView alloc] init];
        nodeView.delegate = self;
        [nodeView setDataWithNodeData:nodeData];
        [self addSubview:nodeView];
    }
    
    //2. 节点排版算法,重置计算所有节点坐标;
    [self refreshDisplay_Node];
    
    //3. 重绘关联线
    [self refreshDisplay_Line];
}

//MARK:===============================================================
//MARK:                     < Node >
//MARK:===============================================================
/**
 *  MARK:--------------------节点排版算法--------------------
 *  1. 有可能,a组与b组间没抽具象关系;此时只能默认往底部排;
 */
-(void) refreshDisplay_Node{
    //1. 找出所有有关系的NodeCompareModel
    NSArray *compareModels = [self getNodeCompareModels];
    
    //2. 获取分组数据;
    NSArray *sortGroups = [self getSortGroups:compareModels];
    
    //3. 转成编层号字典; (每组的y单独从0开始,各组的x都要累加)
    NSMutableDictionary *xDic = [[NSMutableDictionary alloc] init];//从左往右编号
    NSMutableDictionary *yDic = [[NSMutableDictionary alloc] init];//从下往上编号
    int curX = -1;
    for (NSArray *sortGroup in sortGroups) {
        int curY = 0;
        //判断当前sortItem是否是上一个last的抽象; (是则curY+1,不是则curY+0)
        id lastSortItem = nil;
        for (id sortItem in sortGroup) {
            NSComparisonResult compare = [self compareNodeData1:sortItem nodeData2:lastSortItem compareModels:compareModels];
            ///1. 排y_抽象加一层;
            if (compare == NSOrderedAscending) {
                [yDic setObject:@(++curY) forKey:sortItem];
            }else if(compare == NSOrderedSame){
                ///2. 排y_平层在同一层;
                [yDic setObject:@(curY) forKey:sortItem];
            }else{
                NSLog(@"错误!!! 排更后面的节点,不允许比具象更具象! (请检查排序算法,是否排反了)");
            }
            ///3. 排x;
            [xDic setObject:@(++curX) forKey:sortItem];
            
            ///4. 记录last,下一个;
            lastSortItem = sortItem;
        }
    }
    
    //3. 根据编号计算坐标;
    NSArray *nodeViews = ARRTOOK([self subViews_AllDeepWithClass:NodeView.class]);
    for (NodeView *nodeView in nodeViews) {
        NSInteger x = [NUMTOOK([xDic objectForKey:nodeView.data]) integerValue];
        NSInteger y = [NUMTOOK([yDic objectForKey:nodeView.data]) integerValue];
        [nodeView setX:x * 12];
        [nodeView setX:(self.height - y * 12)];
    }
}

/**
 *  MARK:--------------------获取dataArr的排版分组--------------------
 *  注: 其中最具象为0,抽象往上,越抽象值越大,越具象值越小;
 *  @result : 二维数组,元素为组,组中具象在前,抽象在后;
 */
-(NSMutableArray*) getSortGroups:(NSArray*)compareModels{
    //1. 数据检查
    compareModels = ARRTOOK(compareModels);
    
    //2. 用相容算法,分组;
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    for (id item in self.nodeArr) {
        ///1. 已有,则加入;
        BOOL joinSuccess = false;
        for (NSMutableArray *group in groups) {
            if ([self containsRelateWithData:item fromGroup:groups compareModels:compareModels]) {
                [group addObject:item];
                joinSuccess = true;
                break;
            }
        }
        
        ///2. 未有,则新组;
        if (!joinSuccess) {
            NSMutableArray *newGroup = [[NSMutableArray alloc] init];
            [newGroup addObject:item];
            [groups addObject:newGroup];
        }
    }
    
    //3. 对groups中,每一组进行独立排序,并取编号结果; (排序:从具象到抽象)
    NSMutableArray *sortGroups = [[NSMutableArray alloc] init];
    for (NSArray *group in groups) {
        NSArray *sortGroup = [group sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [self compareNodeData1:obj1 nodeData2:obj2 compareModels:compareModels];
        }];
        [sortGroups addObject:sortGroup];
    }
    return sortGroups;
}

/**
 *  MARK:--------------------比较nodeData1和2的抽具象关系--------------------
 *  @result : 抽象为大,具象为小,无关系为相等
 *  @desc : 排序规则: (从具象到抽象 / 从小到大)
 */
-(NSComparisonResult)compareNodeData1:(id)n1 nodeData2:(id)n2 compareModels:(NSArray*)compareModels{
    //1. 数据检查
    if (n1 && n2) {
        compareModels = ARRTOOK(compareModels);
        
        //2. 判断n1与n2的关系,并返回大或小;
        for (NodeCompareModel *model in compareModels) {
            if ([model isA:n1 andB:n2]) {
                return [n1 isEqual:model.smallNodeData] ? NSOrderedDescending : NSOrderedAscending;
            }
        }
    }
    //3. 无关系异常
    return NSOrderedSame;
}

/**
 *  MARK:--------------------收集所有nodeData的关系模型--------------------
 */
-(NSArray*)getNodeCompareModels {
    //1. 进行一一比较,并收集;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.nodeArr.count; i++) {
        for (NSInteger j = i + 1; j < self.nodeArr.count; j++) {
            id iData = ARR_INDEX(self.nodeArr, i);
            id jData = ARR_INDEX(self.nodeArr, j);
            if (iData && jData) {
                //2. n1抽象指向n2
                NSArray *iAbs = ARRTOOK([self moduleView_AbsNodeDatas:iData]);
                NSLog(@"此处,检查下指针能否使用containsObject:如果不能,要使用smgutils中的方法;");
                if ([iAbs containsObject:jData]) {
                    [result addObject:[NodeCompareModel newWithBig:jData small:iData]];
                    continue;
                }
                //3. n1具象指向n2
                NSArray *iCon = ARRTOOK([self moduleView_ConNodeDatas:iData]);
                if ([iCon containsObject:jData]) {
                    [result addObject:[NodeCompareModel newWithBig:iData small:jData]];
                }
            }
        }
    }
    return result;
}

/**
 *  MARK:--------------------检查group中有没有和checkData有关系的--------------------
 */
-(BOOL) containsRelateWithData:(id)checkData fromGroup:(NSArray*)group compareModels:(NSArray*)compareModels{
    //1. 数据检查
    if (checkData) {
        group = ARRTOOK(group);
        compareModels = ARRTOOK(compareModels);
        
        //2. 检查group中,是否有元素与checkData有关系;
        for (id groupData in group) {
            for (NodeCompareModel *model in compareModels) {
                if ([model isA:groupData andB:checkData]) {
                    return true;
                }
            }
        }
    }
    return false;
}

//MARK:===============================================================
//MARK:                     < Line >
//MARK:===============================================================
-(void) refreshDisplay_Line{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(50, 50)];
    [path addLineToPoint:CGPointMake(100, 100)];
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.lineWidth = 1;
    pathLayer.strokeColor = UIColorWithRGBHexA(0x0000FF, 0.3).CGColor;
    pathLayer.fillColor = nil;
    pathLayer.path = path.CGPath;
    [self.containerView.layer addSublayer:pathLayer];
}

/**
 *  MARK:--------------------NodeViewDelegate--------------------
 */
-(UIView *)nodeView_GetCustomSubView:(id)nodeData{
    return [self moduleView_GetCustomSubView:nodeData];
}
-(NSString*) nodeView_GetTipsDesc:(id)nodeData{
    return [self moduleView_GetTipsDesc:nodeData];
}
-(void) nodeView_TopClick:(id)nodeData{
    NSArray *absNodeDatas = [self moduleView_AbsNodeDatas:nodeData];
    NSLog(@"%@",absNodeDatas);
}
-(void) nodeView_BottomClick:(id)nodeData{
    NSArray *conNodeDatas = [self moduleView_ConNodeDatas:nodeData];
    NSLog(@"%@",conNodeDatas);
}
-(void) nodeView_LeftClick:(id)nodeData{
    NSArray *contentNodeDatas = [self moduleView_ContentNodeDatas:nodeData];
    NSLog(@"%@",contentNodeDatas);
}
-(void) nodeView_RightClick:(id)nodeData{
    NSArray *refNodeDatas = [self moduleView_RefNodeDatas:nodeData];
    NSLog(@"%@",refNodeDatas);
}

//MARK:===============================================================
//MARK:                     < SelfDelegate >
//MARK:===============================================================
-(UIView *)moduleView_GetCustomSubView:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_GetCustomSubView:)]) {
        return [self.delegate moduleView_GetCustomSubView:nodeData];
    }
    return nil;
}

-(NSString*)moduleView_GetTipsDesc:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_GetTipsDesc:)]) {
        return [self.delegate moduleView_GetTipsDesc:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_AbsNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_AbsNodeDatas:)]) {
        return [self.delegate moduleView_AbsNodeDatas:nodeData];
    }
    return nil;
}
-(NSArray*)moduleView_ConNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_ConNodeDatas:)]) {
        return [self.delegate moduleView_ConNodeDatas:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_ContentNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_ContentNodeDatas:)]) {
        return [self.delegate moduleView_ContentNodeDatas:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_RefNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_RefNodeDatas:)]) {
        return [self.delegate moduleView_RefNodeDatas:nodeData];
    }
    return nil;
}

@end
