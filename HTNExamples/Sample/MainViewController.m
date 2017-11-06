//
//  MainViewController.m
//  Sample
//
//  Created by sunshinelww on 2017/11/1.
//  Copyright © 2017年 AsyncDisplayKit. All rights reserved.
//

#import "MainViewController.h"
#import "Flexbox.h"

@interface MainViewController ()

@property (strong, nonatomic)Flexbox *flexBoxNode;

@end

@implementation MainViewController

- (instancetype)init{
    ASDisplayNode *node = [ASDisplayNode new];
    _flexBoxNode = [[Flexbox alloc] init];
    __weak typeof(self) weakSelf = self;
    node.automaticallyManagesSubnodes = YES;
    node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
        return [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY sizingOptions:ASCenterLayoutSpecSizingOptionMinimumX child:weakSelf.flexBoxNode];
    };
    self=[super initWithNode:node];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
