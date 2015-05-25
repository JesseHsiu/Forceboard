//
//  KeyPressStatistic.m
//  Forceboard
//
//  Created by 楊順堯 on 2015/5/25.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "KeyPressStatistic.h"

@implementation KeyPressStatistic
-(void)CalculateHardPressesAndLightPresses:(int *)hard or:(int *)light andInput:(char *)str{
//    char lihgtPressSet[] = {'q','a','z','e','d','c','t','g','b','u','j','m','o','l','.'};
//    char hardPressSer[] = {'w','s','x','r','f','v','y','h','n','i','k',',','p',';','/'};
    *hard = 0;
    *light = 0;
    NSDictionary *lihgtPressSet = @{@"q":@1,
                                     @"a":@1,
                                     @"z":@1,
                                     @"e":@1,
                                     @"d":@1,
                                     @"c":@1,
                                     @"t":@1,
                                     @"g":@1,
                                     @"b":@1,
                                     @"u":@1,
                                     @"j":@1,
                                     @"m":@1,
                                     @"o":@1,
                                     @"l":@1,
                                     @".":@1
                                    };
    NSDictionary *hardPressSet = @{@"w":@1,
                                   @"s":@1,
                                   @"x":@1,
                                   @"r":@1,
                                   @"f":@1,
                                   @"v":@1,
                                   @"y":@1,
                                   @"h":@1,
                                   @"n":@1,
                                   @"i":@1,
                                   @"k":@1,
                                   @",":@1,
                                   @"p":@1,
                                   @";":@1,
                                   @"/":@1
                                   };
//    NSLog(@"%@", [lihgtPressSet objectForKey:@"w"]);
    for (int i = 0; i < strlen(str); ++i) {
        if ([lihgtPressSet objectForKey:[NSString stringWithFormat:@"%c", str[i]]]) {
            *light +=1;
        }else if([hardPressSet objectForKey:[NSString stringWithFormat:@"%c", str[i]]]){
            *hard += 1;
        }
    }
    
    }

@end
