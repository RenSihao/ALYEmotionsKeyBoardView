//
//  ALYEmotionsViewModel.h
//  GIF_Keyboard_Demo
//
//  Created by RenSihao on 16/7/20.
//  Copyright © 2016年 RenSihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALYEmotionsKeyboardView.h"

extern NSString * const ALYEmojiTypePeopleKey;
extern NSString * const ALYEmojiTypeNatureKey;
extern NSString * const ALYEmojiTypeObjectsKey;
extern NSString * const ALYEmojiTypePlacesKey;

@interface ALYEmotionsKeyboardViewModel : NSObject

#pragma mark - GIF

/**
 *  获取本地gif所有文件
 *
 *  @return gif数组
 */
+ (NSArray *)getAllGifs;
/**
 *  获取单页gif数组
 *
 *  @param gifArray    所有gif
 *  @param singleCount 单页数量
 *  @param index       页码
 *
 *  @return
 */
+ (NSArray *)getGifEmotionsWithGifArray:(NSArray *)gifArray singleCount:(NSInteger)singleCount index:(NSInteger)index;

#pragma mark - Emoji

/**
 *  获取本地所有支持的emoji表情
 *
 *  @return emoji字典
 */
+ (NSDictionary *)getAllEmojiDict;
/**
 *  获取本地所有的emoji表情
 *
 *  @return emoji数组
 */
+ (NSArray *)getAllEmojis;
/**
 *  获取单页emoji数组
 *
 *  @param emojiArray  所有emoji
 *  @param singleCount 单页数量
 *  @param index       页码
 *
 *  @return emoji数组
 */
+ (NSArray *)getEmojiEmotionsWithEmojiArray:(NSArray *)emojiArray singleCount:(NSInteger)singleCount index:(NSInteger)index;
/**
 *  根据emoji类型获取对应的数组
 *
 *  @param type
 *
 *  @return emoji数组
 */
+ (NSArray *)getEmojiEmotionsWithEmojiType:(ALYEmojiType)type;

#pragma mark - PNG

/**
 *  获取所有的png表情
 *
 *  @return png数组
 */
+ (NSArray *)getAllPngs;

@end



/********************************* Emoji表情管理工具 ***********************************/

#define MAKE_Q(x) @#x
#define MAKE_EM(x,y) MAKE_Q(x##y)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunicode"
#define MAKE_EMOJI(x) MAKE_EM(\U000,x)
#pragma clang diagnostic pop

#define EMOJI_METHOD(x,y) + (NSString *)x { return MAKE_EMOJI(y); }
#define EMOJI_HMETHOD(x) + (NSString *)x;
#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

@interface EmojiManager : NSObject

/**
 *  根据Unicode编码转换成iOS内置表情字符串
 *
 *  @param code 十六进制编码
 *
 *  @return emoji表情字符串
 */
+ (NSString *)emojiWithCode:(int)code;
/**
 *  获取iOS默认支持的所有emoji表情
 *
 *  @return
 */
+ (NSArray *)defaultAllEmoticons;

@end


