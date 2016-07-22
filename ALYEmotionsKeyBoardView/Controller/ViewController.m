//
//  ViewController.m
//  GIF_Keyboard_Demo
//
//  Created by RenSihao on 16/7/19.
//  Copyright © 2016年 RenSihao. All rights reserved.
//

#import "ViewController.h"
#import "ALYEmotionsKeyboardView.h"
#import "ALYEmotionsKeyboardViewModel.h"
#import "YYImage.h"

@interface ViewController () <ALYEmotionsKeyboardViewDelegate>

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"GIF表情demo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *gifs   = [ALYEmotionsKeyboardViewModel getAllGifs];
    NSArray *emojis = [ALYEmotionsKeyboardViewModel getAllEmojis];
    
    ALYEmotionsKeyboardView *emotionsKeyboardView = [[ALYEmotionsKeyboardView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 216) delegate:self gifImageNames:gifs emojiNames:emojis pngImageNames:nil];
    
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 44)];
    textView.backgroundColor = [UIColor grayColor];
    textView.inputView = emotionsKeyboardView;
    
    [self.view addSubview:textView];
    
}

#pragma mark - ALYEmotionsKeyboardViewDelegate

//点击表情回调
- (void)emotionsKeyboardView:(id)emojiKeyboardView
                 emotionType:(ALYEmotionType)type
                 didUseEmoji:(NSString *)emoji
                   didUseGIF:(NSDictionary *)gifDict
{
    NSLog(@"%s", __func__);
    
    switch (type) {
        case ALYEmotionTypeGIF:
        {
            NSString *gifName = [gifDict valueForKey:GIFNameKey];
            NSData   *gifData = [gifDict valueForKey:GIFDatakey];
            
            //...
            NSLog(@"点击了gif表情！\n gifName ==> %@ \n gifData ==> %@", gifName, gifData);
        }
            break;
        case ALYEmotionTypePNG:
        {
            
        }
            break;
        case ALYEmotionTypeEmoji:
        {
            NSLog(@"点击了emoji表情！\n ==> %@", emoji);
        }
            break;
        default:
            break;
    }
    
    
}
//点击删除回调
- (void)emotionsKeyboardView:(ALYEmotionsKeyboardView *)emojiKeyboardView emotionType:(ALYEmotionType)type didDelete:(BOOL)didDelete
{
    if (didDelete)
    {
        //目前只有emoji页面需要删除按钮
        NSLog(@"emoji点击了删除...");
    }
}
- (void)emotionsKeyboardView:(ALYEmotionsKeyboardView *)emojiKeyboardView didClickSend:(BOOL)isSend
{
    if (isSend)
    {
        NSLog(@"点击了发送按钮!");
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end


