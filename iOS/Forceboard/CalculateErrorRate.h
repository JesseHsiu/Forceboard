//
//  CalculateErrorRate.h
//  Forceboard
//
//  Created by 楊順堯 on 2015/5/24.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculateErrorRate : NSObject
-(int)LevenshteinDistance:(char *)String1 andCorrect:(char *)String2;
@end
