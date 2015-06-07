//
//  SplitViewController.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/27.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "KeysBtnView.h"
@interface SplitViewController : ViewController
{
    CGPoint orignCenter;
    CGPoint leftCenter;
    CGPoint rightCenter;
    
    BOOL isCurrentLeft;
    
    IBOutlet KeysBtnView *dKey;
    IBOutlet KeysBtnView *kKey;
    
    
    IBOutlet NSLayoutConstraint *middleLineConstraint;
    
}
@end
