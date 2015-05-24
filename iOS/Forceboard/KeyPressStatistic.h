//
//  KeyPressStatistic.h
//  Forceboard
//
//  Created by 楊順堯 on 2015/5/25.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyPressStatistic : NSObject
-(void)CalculateHardPressesAndLightPresses:(int *)hard or:(int *)light andInput:(char *)str;
@end
