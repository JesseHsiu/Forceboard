//
//  TaskLabel.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/16.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskLabel : UILabel
{
    NSArray *taskArray;
}
-(void)nextTask;
@end
