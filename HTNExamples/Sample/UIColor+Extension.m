//
//  UIColor+Extension.m
//  HTNSample
//
//  Created by sunshinelww on 2017/4/6.
//  Copyright © 2017年 sunshinelww. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor *)colorWithHexString:(NSString *)colorHexString {
    CGFloat alpha, red, blue, green;
    
    NSString *colorString = [[colorHexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = colorComponentFromHexString(colorString, 0, 1);
            green = colorComponentFromHexString(colorString, 1, 1);
            blue  = colorComponentFromHexString(colorString, 2, 1);
            break;
            
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = colorComponentFromHexString(colorString, 0, 2);
            green = colorComponentFromHexString(colorString, 2, 2);
            blue  = colorComponentFromHexString(colorString, 4, 2);
            break;
            
        default:
            return nil;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

CGFloat colorComponentFromHexString(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *hexString = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexNum;
    NSScanner *scanner=[NSScanner scannerWithString:hexString];
    [scanner scanHexInt: &hexNum];
    return hexNum / 255.0;
}
@end
