//
//  CalculateErrorRate.m
//  Forceboard
//
//  Created by 楊順堯 on 2015/5/24.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "CalculateErrorRate.h"

@implementation CalculateErrorRate
-(int)LevenshteinDistance:(NSString *)String1 andCorrect:(NSString *)String2
    {
        int len1 = (int)String1.length;
        int len2 = (int)String2.length;
        
        int d[len1+1][len2+1];
        for (int i = 0;  i <= len1; ++i) {
            for (int j = 0; j <= len2; ++j) {
                d[i][j] = 0;
            }
        }
        for (int i = 1; i <= len1; ++i) {
            d[i][0] = i;
        }
        for (int j = 1; j <= len2; ++j) {
            d[0][j] = j;
        }
        
        for (int j = 1; j <= len2; ++j) {
            for (int i = 1; i <= len1; ++i) {
                if([String1 characterAtIndex:i-1] == [String2 characterAtIndex:j-1]){
                    d[i][j] = d[i-1][j-1];
//                    NSLog(@"%d %d %c %c", i, j, String1[i], String2[j]);
                }
                else{
                    int deletion = d[i-1][j] + 1;
                    int insertion = d[i][j-1] + 1;
                    int substitution = d[i-1][j-1] + 1;
                    d[i][j] = MIN(MIN(deletion, insertion), substitution);
                }
            }
        }
        
//        NSLog(@"%s", String1);
//        NSLog(@"%s", String2);
//        for (int i = 0;  i <= len1; ++i) {
//            for (int j = 0; j <= len2; ++j) {
//                printf("%d", d[i][j]);
//            }
//            printf("\n");
//        }
        return d[len1][len2];
    }
@end
