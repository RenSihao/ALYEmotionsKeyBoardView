//
//  NSArray+Category.h
//  My_iOS_Dev_Tools
//
//  Created by RenSihao on 16/7/8.
//  Copyright © 2016年 RenSihao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  全部做了防止越界处理
 */
@interface NSArray (Category)

- (id)firstObject;
- (id)lastObject;
- (id)objectAtIndexNotBeyond:(NSUInteger)index;

@end
