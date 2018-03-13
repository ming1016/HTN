#import "Flexbox.h"
#import "UIColor+Extension.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface Flexbox ()
@property (strong, nonatomic) ASDisplayNode *div_68_node;
@property (strong, nonatomic) ASDisplayNode *div_67_node;
@property (strong, nonatomic) ASTextNode *textNode_39;
@property (strong, nonatomic) ASTextNode *textNode_27;
@property (strong, nonatomic) ASDisplayNode *div_59_node;
@property (strong, nonatomic) ASDisplayNode *div_15_node;
@property (strong, nonatomic) ASDisplayNode *div_9_node;
@property (strong, nonatomic) ASTextNode *textNode_30;
@property (strong, nonatomic) ASDisplayNode *div_8_node;
@property (strong, nonatomic) ASTextNode *textNode_64;
@property (strong, nonatomic) ASDisplayNode *body_70_node;
@property (strong, nonatomic) ASDisplayNode *div_29_node;
@property (strong, nonatomic) ASTextNode *textNode_13;
@property (strong, nonatomic) ASDisplayNode *div_34_node;
@property (strong, nonatomic) ASDisplayNode *div_38_node;
@property (strong, nonatomic) ASDisplayNode *div_26_node;
@property (strong, nonatomic) ASDisplayNode *div_33_node;
@property (strong, nonatomic) ASTextNode *textNode_5;
@property (strong, nonatomic) ASDisplayNode *div_12_node;
@property (nonatomic, strong) ASNetworkImageNode *imageNode_3;

@property (nonatomic, strong) ASNetworkImageNode *imageNode_20;

@property (nonatomic, strong) ASNetworkImageNode *imageNode_37;

@property (strong, nonatomic) ASTextNode *textNode_22;
@property (strong, nonatomic) ASDisplayNode *div_32_node;
@property (strong, nonatomic) ASDisplayNode *div_42_node;
@property (strong, nonatomic) ASDisplayNode *div_66_node;
@property (strong, nonatomic) ASTextNode *textNode_10;
@property (strong, nonatomic) ASDisplayNode *div_21_node;
@property (strong, nonatomic) ASDisplayNode *div_25_node;
@property (strong, nonatomic) ASTextNode *textNode_47;
@property (strong, nonatomic) ASDisplayNode *div_49_node;
@property (strong, nonatomic) ASDisplayNode *div_43_node;
@property (strong, nonatomic) ASDisplayNode *div_55_node;
@property (strong, nonatomic) ASTextNode *textNode_56;
@property (strong, nonatomic) ASDisplayNode *div_46_node;
@property (strong, nonatomic) ASDisplayNode *div_60_node;
@property (strong, nonatomic) ASTextNode *textNode_61;
@property (strong, nonatomic) ASDisplayNode *div_4_node;
@property (strong, nonatomic) ASTextNode *textNode_44;
@property (strong, nonatomic) ASDisplayNode *div_69_node;
@property (strong, nonatomic) ASDisplayNode *div_63_node;
@property (nonatomic, strong) ASNetworkImageNode *imageNode_54;

@property (strong, nonatomic) ASDisplayNode *div_17_node;
@property (strong, nonatomic) ASDisplayNode *div_50_node;
@property (strong, nonatomic) ASDisplayNode *div_16_node;
@property (strong, nonatomic) ASDisplayNode *div_51_node;

@end

@implementation Flexbox
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _div_68_node=[[ASDisplayNode alloc] init];
        _div_68_node.automaticallyManagesSubnodes = YES;
        _div_67_node=[[ASDisplayNode alloc] init];
        _div_67_node.automaticallyManagesSubnodes = YES;_div_67_node.borderWidth = 1.0;
        _div_67_node.borderColor =[UIColor colorWithHexString:@"#cad0d2"].CGColor;
        _div_67_node.cornerRadius = 4.0;
        
        NSMutableString *str_41= [[NSMutableString alloc] init];
        [str_41 appendString:@"Jatesh V."];
        
        _textNode_39 = [[ASTextNode alloc] init];
        NSMutableParagraphStyle * paragraphStyle_40 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle_40.alignment = NSTextAlignmentCenter;
        
        _textNode_39.attributedText = [[NSAttributedString alloc] initWithString:str_41  attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#57727c"],NSFontAttributeName : [UIFont systemFontOfSize:12],NSParagraphStyleAttributeName: paragraphStyle_40}];
        NSMutableString *str_28= [[NSMutableString alloc] init];
        [str_28 appendString:@"Anybody else wondering when the Blade Runner and Westworld tie-in will be released? #crossover"];
        [str_28 appendString:@"#replicant"];
        
        _textNode_27 = [[ASTextNode alloc] init];
        
        _textNode_27.attributedText = [[NSAttributedString alloc] initWithString:str_28  attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#57727c"],NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        _div_59_node=[[ASDisplayNode alloc] init];
        _div_59_node.automaticallyManagesSubnodes = YES;
        _div_15_node=[[ASDisplayNode alloc] init];
        _div_15_node.automaticallyManagesSubnodes = YES;
        _div_9_node=[[ASDisplayNode alloc] init];
        _div_9_node.automaticallyManagesSubnodes = YES;
        NSMutableString *str_31= [[NSMutableString alloc] init];
        [str_31 appendString:@"June 1"];
        
        _textNode_30 = [[ASTextNode alloc] init];
        
        _textNode_30.attributedText = [[NSAttributedString alloc] initWithString:str_31  attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10],NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#86969c"]}];
        _div_8_node=[[ASDisplayNode alloc] init];
        _div_8_node.automaticallyManagesSubnodes = YES;
        NSMutableString *str_65= [[NSMutableString alloc] init];
        [str_65 appendString:@"May 27"];
        
        _textNode_64 = [[ASTextNode alloc] init];
        
        _textNode_64.attributedText = [[NSAttributedString alloc] initWithString:str_65  attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10],NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#86969c"]}];
        _body_70_node=[[ASDisplayNode alloc] init];
        _body_70_node.automaticallyManagesSubnodes = YES;
        _div_29_node=[[ASDisplayNode alloc] init];
        _div_29_node.automaticallyManagesSubnodes = YES;
        NSMutableString *str_14= [[NSMutableString alloc] init];
        [str_14 appendString:@"June 5"];
        
        _textNode_13 = [[ASTextNode alloc] init];
        
        _textNode_13.attributedText = [[NSAttributedString alloc] initWithString:str_14  attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10],NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#86969c"]}];
        _div_34_node=[[ASDisplayNode alloc] init];
        _div_34_node.automaticallyManagesSubnodes = YES;
        _div_38_node=[[ASDisplayNode alloc] init];
        _div_38_node.automaticallyManagesSubnodes = YES;_div_38_node.style.height = ASDimensionMakeWithPoints(90);
        _div_38_node.style.width = ASDimensionMakeWithPoints(100);
        
        _div_26_node=[[ASDisplayNode alloc] init];
        _div_26_node.automaticallyManagesSubnodes = YES;
        _div_33_node=[[ASDisplayNode alloc] init];
        _div_33_node.automaticallyManagesSubnodes = YES;_div_33_node.borderWidth = 1.0;
        _div_33_node.borderColor =[UIColor colorWithHexString:@"#cad0d2"].CGColor;
        _div_33_node.cornerRadius = 4.0;
        
        NSMutableString *str_7= [[NSMutableString alloc] init];
        [str_7 appendString:@"Ziggie G."];
        
        _textNode_5 = [[ASTextNode alloc] init];
        NSMutableParagraphStyle * paragraphStyle_6 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle_6.alignment = NSTextAlignmentCenter;
        
        _textNode_5.attributedText = [[NSAttributedString alloc] initWithString:str_7  attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#57727c"],NSFontAttributeName : [UIFont systemFontOfSize:12],NSParagraphStyleAttributeName: paragraphStyle_6}];
        _div_12_node=[[ASDisplayNode alloc] init];
        _div_12_node.automaticallyManagesSubnodes = YES;
        _imageNode_3=[[ASNetworkImageNode alloc] init];
        _imageNode_3.style.height = ASDimensionMakeWithPoints(70);
        _imageNode_3.style.width = ASDimensionMakeWithPoints(70);
        _imageNode_3.URL = [NSURL URLWithString:@"https://v2ex.assets.uxengine.net/avatar/00c9/7615/25431_normal.png?m=1462359511"];
        
        _imageNode_20=[[ASNetworkImageNode alloc] init];
        _imageNode_20.style.height = ASDimensionMakeWithPoints(70);
        _imageNode_20.style.width = ASDimensionMakeWithPoints(70);
        _imageNode_20.URL = [NSURL URLWithString:@"https://v2ex.assets.uxengine.net/avatar/c9a1/812d/114282_normal.png?m=1509362466"];
        
        _imageNode_37=[[ASNetworkImageNode alloc] init];
        _imageNode_37.style.height = ASDimensionMakeWithPoints(70);
        _imageNode_37.style.width = ASDimensionMakeWithPoints(70);
        _imageNode_37.URL = [NSURL URLWithString:@"https://v2ex.assets.uxengine.net/avatar/d49a/cbb4/167368_normal.png?m=1499849270"];
        
        NSMutableString *str_24= [[NSMutableString alloc] init];
        [str_24 appendString:@"Damien S."];
        
        _textNode_22 = [[ASTextNode alloc] init];
        NSMutableParagraphStyle * paragraphStyle_23 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle_23.alignment = NSTextAlignmentCenter;
        
        _textNode_22.attributedText = [[NSAttributedString alloc] initWithString:str_24  attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#57727c"],NSFontAttributeName : [UIFont systemFontOfSize:12],NSParagraphStyleAttributeName: paragraphStyle_23}];
        _div_32_node=[[ASDisplayNode alloc] init];
        _div_32_node.automaticallyManagesSubnodes = YES;
        _div_42_node=[[ASDisplayNode alloc] init];
        _div_42_node.automaticallyManagesSubnodes = YES;
        _div_66_node=[[ASDisplayNode alloc] init];
        _div_66_node.automaticallyManagesSubnodes = YES;
        NSMutableString *str_11= [[NSMutableString alloc] init];
        [str_11 appendString:@"I love eating pizza!!!!!!!"];
        
        _textNode_10 = [[ASTextNode alloc] init];
        
        _textNode_10.attributedText = [[NSAttributedString alloc] initWithString:str_11  attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#57727c"],NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        _div_21_node=[[ASDisplayNode alloc] init];
        _div_21_node.automaticallyManagesSubnodes = YES;_div_21_node.style.height = ASDimensionMakeWithPoints(90);
        _div_21_node.style.width = ASDimensionMakeWithPoints(100);
        
        _div_25_node=[[ASDisplayNode alloc] init];
        _div_25_node.automaticallyManagesSubnodes = YES;
        NSMutableString *str_48= [[NSMutableString alloc] init];
        [str_48 appendString:@"May 28"];
        
        _textNode_47 = [[ASTextNode alloc] init];
        
        _textNode_47.attributedText = [[NSAttributedString alloc] initWithString:str_48  attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10],NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#86969c"]}];
        _div_49_node=[[ASDisplayNode alloc] init];
        _div_49_node.automaticallyManagesSubnodes = YES;
        _div_43_node=[[ASDisplayNode alloc] init];
        _div_43_node.automaticallyManagesSubnodes = YES;
        _div_55_node=[[ASDisplayNode alloc] init];
        _div_55_node.automaticallyManagesSubnodes = YES;_div_55_node.style.height = ASDimensionMakeWithPoints(90);
        _div_55_node.style.width = ASDimensionMakeWithPoints(100);
        
        NSMutableString *str_58= [[NSMutableString alloc] init];
        [str_58 appendString:@"CJ C."];
        
        _textNode_56 = [[ASTextNode alloc] init];
        NSMutableParagraphStyle * paragraphStyle_57 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle_57.alignment = NSTextAlignmentCenter;
        
        _textNode_56.attributedText = [[NSAttributedString alloc] initWithString:str_58  attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#57727c"],NSFontAttributeName : [UIFont systemFontOfSize:12],NSParagraphStyleAttributeName: paragraphStyle_57}];
        _div_46_node=[[ASDisplayNode alloc] init];
        _div_46_node.automaticallyManagesSubnodes = YES;
        _div_60_node=[[ASDisplayNode alloc] init];
        _div_60_node.automaticallyManagesSubnodes = YES;
        NSMutableString *str_62= [[NSMutableString alloc] init];
        [str_62 appendString:@"Going hiking with @karla in Yosemite!"];
        
        _textNode_61 = [[ASTextNode alloc] init];
        
        _textNode_61.attributedText = [[NSAttributedString alloc] initWithString:str_62  attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#57727c"],NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        _div_4_node=[[ASDisplayNode alloc] init];
        _div_4_node.automaticallyManagesSubnodes = YES;_div_4_node.style.height = ASDimensionMakeWithPoints(90);
        _div_4_node.style.width = ASDimensionMakeWithPoints(100);
        
        NSMutableString *str_45= [[NSMutableString alloc] init];
        [str_45 appendString:@"Flexboxpatterns.com is the most amazing flexbox resource I've ever used! It's changed my"];
        [str_45 appendString:@"life forever and now everybody tells me that *I'M* amazing, too! Use flexboxpatterns.com!Flexboxpatterns.com is the most amazing flexbox resource I've ever used! It's changed my"];
        [str_45 appendString:@"life forever and now everybody tells me that *I'M* amazing, too! Use flexboxpatterns.com!"];
        [str_45 appendString:@"Love flexboxpatterns.com!"];
        
        _textNode_44 = [[ASTextNode alloc] init];
        
        _textNode_44.attributedText = [[NSAttributedString alloc] initWithString:str_45  attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#57727c"],NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        _div_69_node=[[ASDisplayNode alloc] init];
        _div_69_node.automaticallyManagesSubnodes = YES;
        _div_63_node=[[ASDisplayNode alloc] init];
        _div_63_node.automaticallyManagesSubnodes = YES;
        _imageNode_54=[[ASNetworkImageNode alloc] init];
        _imageNode_54.style.height = ASDimensionMakeWithPoints(70);
        _imageNode_54.style.width = ASDimensionMakeWithPoints(70);
        _imageNode_54.URL = [NSURL URLWithString:@"https://v2ex.assets.uxengine.net/avatar/24f2/51cb/114655_normal.png?m=1492759291"];
        
        _div_17_node=[[ASDisplayNode alloc] init];
        _div_17_node.automaticallyManagesSubnodes = YES;
        _div_50_node=[[ASDisplayNode alloc] init];
        _div_50_node.automaticallyManagesSubnodes = YES;_div_50_node.borderWidth = 1.0;
        _div_50_node.borderColor =[UIColor colorWithHexString:@"#cad0d2"].CGColor;
        _div_50_node.cornerRadius = 4.0;
        
        _div_16_node=[[ASDisplayNode alloc] init];
        _div_16_node.automaticallyManagesSubnodes = YES;_div_16_node.borderWidth = 1.0;
        _div_16_node.borderColor =[UIColor colorWithHexString:@"#cad0d2"].CGColor;
        _div_16_node.cornerRadius = 4.0;
        
        _div_51_node=[[ASDisplayNode alloc] init];
        _div_51_node.automaticallyManagesSubnodes = YES;
        
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    @weakify(self);
    self.body_70_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
        @strongify(self);
        self.div_69_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            @strongify(self);
            self.div_17_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                @strongify(self);
                self.div_9_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                    @strongify(self);
                    self.div_4_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        ASStackLayoutSpec * stackLayout_2 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0 justifyContent: ASStackLayoutJustifyContentCenter alignItems: ASStackLayoutAlignItemsCenter children:@[self.imageNode_3]];
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_2];
                    };
                    self.div_8_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_5];
                    };
                    
                    ASStackLayoutSpec * div_4_node_div_8_node = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0.f  justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_4_node, self.div_8_node]];
                    
                    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
                                                                  child:div_4_node_div_8_node];
                };
                self.div_9_node.style.flexGrow = 0;
                self.div_9_node.style.flexShrink = 1;
                self.div_9_node.style.flexBasis = self.div_9_node.style.width;
                self.div_16_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                    @strongify(self);
                    self.div_12_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_10];
                    };
                    self.div_15_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_13];
                    };
                    ASInsetLayoutSpec *div_15_node_addMargin=
                    [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)
                                                           child:self.div_15_node];
                    
                    ASStackLayoutSpec * div_12_node_div_15_node_addMargin = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0.f  justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_12_node, div_15_node_addMargin]];
                    
                    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)
                                                                  child:div_12_node_div_15_node_addMargin];
                };
                self.div_16_node.style.flexGrow = 1;
                self.div_16_node.style.flexShrink = 1;
                self.div_16_node.style.flexBasis = ASDimensionAuto;
                ASStackLayoutSpec * stackLayout_1 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0 justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_9_node,self.div_16_node]];
                
                return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_1];
            };
            ASInsetLayoutSpec *div_17_node_addMargin=
            [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)
                                                   child:self.div_17_node];
            self.div_34_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                @strongify(self);
                self.div_26_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                    @strongify(self);
                    self.div_21_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        ASStackLayoutSpec * stackLayout_19 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0 justifyContent: ASStackLayoutJustifyContentCenter alignItems: ASStackLayoutAlignItemsCenter children:@[self.imageNode_20]];
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_19];
                    };
                    self.div_25_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_22];
                    };
                    
                    ASStackLayoutSpec * div_21_node_div_25_node = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0.f  justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_21_node, self.div_25_node]];
                    
                    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
                                                                  child:div_21_node_div_25_node];
                };
                self.div_26_node.style.flexGrow = 0;
                self.div_26_node.style.flexShrink = 1;
                self.div_26_node.style.flexBasis = self.div_26_node.style.width;
                self.div_33_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                    @strongify(self);
                    self.div_29_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_27];
                    };
                    self.div_32_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_30];
                    };
                    ASInsetLayoutSpec *div_32_node_addMargin=
                    [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)
                                                           child:self.div_32_node];
                    
                    ASStackLayoutSpec * div_29_node_div_32_node_addMargin = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0.f  justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_29_node, div_32_node_addMargin]];
                    
                    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)
                                                                  child:div_29_node_div_32_node_addMargin];
                };
                self.div_33_node.style.flexGrow = 1;
                self.div_33_node.style.flexShrink = 1;
                self.div_33_node.style.flexBasis = ASDimensionAuto;
                ASStackLayoutSpec * stackLayout_18 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0 justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_26_node,self.div_33_node]];
                
                return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_18];
            };
            ASInsetLayoutSpec *div_34_node_addMargin=
            [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)
                                                   child:self.div_34_node];
            self.div_51_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                @strongify(self);
                self.div_43_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                    @strongify(self);
                    self.div_38_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        ASStackLayoutSpec * stackLayout_36 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0 justifyContent: ASStackLayoutJustifyContentCenter alignItems: ASStackLayoutAlignItemsCenter children:@[self.imageNode_37]];
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_36];
                    };
                    self.div_42_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_39];
                    };
                    
                    ASStackLayoutSpec * div_38_node_div_42_node = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0.f  justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_38_node, self.div_42_node]];
                    
                    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
                                                                  child:div_38_node_div_42_node];
                };
                self.div_43_node.style.flexGrow = 0;
                self.div_43_node.style.flexShrink = 1;
                self.div_43_node.style.flexBasis = self.div_43_node.style.width;
                self.div_50_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                    @strongify(self);
                    self.div_46_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_44];
                    };
                    self.div_49_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_47];
                    };
                    ASInsetLayoutSpec *div_49_node_addMargin=
                    [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)
                                                           child:self.div_49_node];
                    
                    ASStackLayoutSpec * div_46_node_div_49_node_addMargin = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0.f  justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_46_node, div_49_node_addMargin]];
                    
                    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)
                                                                  child:div_46_node_div_49_node_addMargin];
                };
                self.div_50_node.style.flexGrow = 1;
                self.div_50_node.style.flexShrink = 1;
                self.div_50_node.style.flexBasis = ASDimensionAuto;
                ASStackLayoutSpec * stackLayout_35 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0 justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_43_node,self.div_50_node]];
                
                return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_35];
            };
            ASInsetLayoutSpec *div_51_node_addMargin=
            [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)
                                                   child:self.div_51_node];
            self.div_68_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                @strongify(self);
                self.div_60_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                    @strongify(self);
                    self.div_55_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        ASStackLayoutSpec * stackLayout_53 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0 justifyContent: ASStackLayoutJustifyContentCenter alignItems: ASStackLayoutAlignItemsCenter children:@[self.imageNode_54]];
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_53];
                    };
                    self.div_59_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_56];
                    };
                    
                    ASStackLayoutSpec * div_55_node_div_59_node = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0.f  justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_55_node, self.div_59_node]];
                    
                    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
                                                                  child:div_55_node_div_59_node];
                };
                self.div_60_node.style.flexGrow = 0;
                self.div_60_node.style.flexShrink = 1;
                self.div_60_node.style.flexBasis = self.div_60_node.style.width;
                self.div_67_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                    @strongify(self);
                    self.div_63_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_61];
                    };
                    self.div_66_node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
                        @strongify(self);
                        
                        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.textNode_64];
                    };
                    ASInsetLayoutSpec *div_66_node_addMargin=
                    [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)
                                                           child:self.div_66_node];
                    
                    ASStackLayoutSpec * div_63_node_div_66_node_addMargin = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0.f  justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_63_node, div_66_node_addMargin]];
                    
                    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)
                                                                  child:div_63_node_div_66_node_addMargin];
                };
                self.div_67_node.style.flexGrow = 1;
                self.div_67_node.style.flexShrink = 1;
                self.div_67_node.style.flexBasis = ASDimensionAuto;
                ASStackLayoutSpec * stackLayout_52 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0 justifyContent: ASStackLayoutJustifyContentStart alignItems: ASStackLayoutAlignItemsStretch children:@[self.div_60_node,self.div_67_node]];
                
                return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_52];
            };
            ASInsetLayoutSpec *div_68_node_addMargin=
            [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)
                                                   child:self.div_68_node];
            ASStackLayoutSpec * stackLayout_0 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:0 justifyContent: ASStackLayoutJustifyContentEnd alignItems: ASStackLayoutAlignItemsStretch children:@[div_17_node_addMargin,div_34_node_addMargin,div_51_node_addMargin,div_68_node_addMargin]];
            
            return [ASWrapperLayoutSpec wrapperWithLayoutElement:stackLayout_0];
        };
        
        return [ASWrapperLayoutSpec wrapperWithLayoutElement:self.div_69_node];
    };
    ASInsetLayoutSpec *body_70_node_addMargin=
    [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
                                           child:self.body_70_node];
    
    return body_70_node_addMargin;
}

@end


