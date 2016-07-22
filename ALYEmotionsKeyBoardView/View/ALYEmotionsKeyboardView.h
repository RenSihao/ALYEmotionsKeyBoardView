//
//  ALYEmotionsKeyboardView.h
//  GIF_Keyboard_Demo
//
//  Created by RenSihao on 16/7/20.
//  Copyright © 2016年 RenSihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height

extern NSString * const GIFNameKey;
extern NSString * const GIFDatakey;

@class ALYEmotionsKeyboardView;

/**
 *  表情种类
 */
typedef NS_ENUM(NSUInteger, ALYEmotionType) {
    /**
     *  gif表情
     */
    ALYEmotionTypeGIF,
    /**
     *  emoji表情 （所有Unicode编码表情，以plist文件形式存储本地）
     */
    ALYEmotionTypeEmoji,
    /**
     *  png静态图片 (暂时废弃因为QQ表情版权问题，但是预留接口)
     */
    ALYEmotionTypePNG
};

/**
 *  Emoji表情五种分类
 */
typedef NS_ENUM(NSUInteger, ALYEmojiType) {
    /**
     *  人
     */
    ALYEmojiTypePeople,
    /**
     *  动物、植物
     */
    ALYEmojiTypeNature,
    /**
     *  事物
     */
    ALYEmojiTypeObjects,
    /**
     *  地点（暂时废弃）
     */
    ALYEmojiTypePlaces
};

@protocol ALYEmotionsKeyboardViewDelegate <NSObject>

/**
 *  点击某个表情
 *
 *  @param emojiKeyboardView 表情键盘view
 *  @param type              表情类型
 *  @param emoji             返回该表情的emoji字符
 *  @param gif               返回该表情的gif字典（两对值，）
 */
- (void)emotionsKeyboardView:(ALYEmotionsKeyboardView *)emojiKeyboardView
                 emotionType:(ALYEmotionType)type
                 didUseEmoji:(NSString *)emoji
                   didUseGIF:(NSDictionary *)gifDict;

/**
 *  点击了删除
 *
 *  @param emojiKeyboardView 表情键盘view
 *  @param type              表情类型
 *  @param didDelete         是否删除
 */
- (void)emotionsKeyboardView:(ALYEmotionsKeyboardView *)emojiKeyboardView
                 emotionType:(ALYEmotionType)type
                   didDelete:(BOOL)didDelete;
/**
 *  点击了发送
 *
 *  @param emojiKeyboardView 表情键盘view
 *  @param isSend            是否发送
 */
- (void)emotionsKeyboardView:(ALYEmotionsKeyboardView *)emojiKeyboardView didClickSend:(BOOL)isSend;

@end

/**
 *  表情键盘封装view
 */
@interface ALYEmotionsKeyboardView : UIView

/**
 *  delegate
 */
@property (nonatomic, copy) id<ALYEmotionsKeyboardViewDelegate> delegate;

/**
 *  init方法
 *
 *  @param frame         frame
 *  @param delegate      delegate
 *  @param gifImageNames gif
 *  @param emojiNames    emoji
 *  @param pngImageNames png
 *
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<ALYEmotionsKeyboardViewDelegate>)delegate
                gifImageNames:(NSArray *)gifImageNames
                   emojiNames:(NSArray *)emojiNames
                pngImageNames:(NSArray *)pngImageNames;


@end



/**************************** GIF表情页 **************************************/

@interface ALYGIFPageView : UIView

/**
 *  点击gif回调
 */
@property (nonatomic, copy) void(^clickGIFEmotionBlock)(id gifData);

- (instancetype)initWithFrame:(CGRect)frame gifImageNames:(NSArray *)gifImageNames;
@end



/**************************** Emoji表情页 **************************************/


@interface ALYEmojiPageView : UIView

/**
 *  点击emoji回调
 */
@property (nonatomic, copy) void(^clickEmojiEmotionBlock)(NSString *emoji, BOOL isDelete);

- (instancetype)initWithFrame:(CGRect)frame emojiArray:(NSArray *)emojiArray;
@end

#warning 暂时废弃PNG
/**************************** PNG表情页 **************************************/

@interface ALYPNGPageView : UIView


- (instancetype)initWithFrame:(CGRect)frame pngImageNames:(NSArray *)pngImageNames;
@end



