//
//  NodeView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NodeView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface NodeView ()

@property (strong,nonatomic) IBOutlet UIControl *containerView;

@end

@implementation NodeView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
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

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setDataWithNodeData:(id)nodeData{
    _data = nodeData;
    [self refreshDisplay];
}

-(void) refreshDisplay{
    //1. 移除旧的subView
    [self.containerView removeAllSubviews];
    
    //2. 优先取自定义subView
    UIView *subView = [self nodeView_GetCustomSubView:self.data];
    
    //3. 再取默认subView
    if (!subView) {
        subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [subView setBackgroundColor:[UIColor redColor]];
    }
    
    //4. 显示
    [self.containerView addSubview:subView];
}

//MARK:===============================================================
//MARK:                     < onClick >
//MARK:===============================================================
- (IBAction)contentViewTouchDown:(id)sender {
    NSString *desc = [self nodeView_GetTipsDesc:self.data];
    NSLog(@"按下:%@",desc);
}
- (IBAction)contentViewTouchCancel:(id)sender {
    NSLog(@"松开");
}
- (IBAction)topBtnOnClick:(id)sender {
    [self nodeView_TopClick:self.data];
    NSLog(@"absPorts");
}
- (IBAction)bottomBtnOnClick:(id)sender {
    [self nodeView_BottomClick:self.data];
    NSLog(@"conPorts");
}
- (IBAction)leftBtnOnClick:(id)sender {
    [self nodeView_LeftClick:self.data];
    NSLog(@"content");
}
- (IBAction)rightBtnOnClick:(id)sender {
    [self nodeView_RightClick:self.data];
    NSLog(@"refPorts");
}

//MARK:===============================================================
//MARK:                     < SelfDelegate >
//MARK:===============================================================
-(UIView*) nodeView_GetCustomSubView:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_GetCustomSubView:)]) {
        return [self.delegate nodeView_GetCustomSubView:nodeData];
    }
    return nil;
}
-(NSString*) nodeView_GetTipsDesc:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_GetTipsDesc:)]) {
        return [self.delegate nodeView_GetTipsDesc:nodeData];
    }
    return nil;
}
-(void) nodeView_TopClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_TopClick:)]) {
        [self.delegate nodeView_TopClick:nodeData];
    }
}
-(void) nodeView_BottomClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_BottomClick:)]) {
        [self.delegate nodeView_BottomClick:nodeData];
    }
}
-(void) nodeView_LeftClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_LeftClick:)]) {
        [self.delegate nodeView_LeftClick:nodeData];
    }
}
-(void) nodeView_RightClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_RightClick:)]) {
        [self.delegate nodeView_RightClick:nodeData];
    }
}

@end
