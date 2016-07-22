//
//  ALYEmotionsKeyboardView.m
//  GIF_Keyboard_Demo
//
//  Created by RenSihao on 16/7/20.
//  Copyright © 2016年 RenSihao. All rights reserved.
//

#import "ALYEmotionsKeyboardView.h"
#import "Masonry.h"
#import "UIImage+Color.h"
#import "YYImage.h"
#import "ALYEmotionsKeyboardViewModel.h"
#import "NSArray+Category.h"

NSString * const GIFNameKey = @"GIFNameKey";
NSString * const GIFDatakey = @"GIFDataKey";

static NSInteger GIF_COL   = 4; //GIF   4列
static NSInteger GIF_ROW   = 2; //GIF   2行
static NSInteger EMOJI_COL = 7; //Emoji 7列
static NSInteger EMOJI_ROW = 3; //Emoji 3行
static NSInteger PNG_COL   = 7; //PNG   7列
static NSInteger PNG_ROW   = 3; //PNG   3行

static CGFloat EMOTION_KEYBOARD_SCALE = 0.8;    //表情区域 底部按钮bar 高度之比
static CGFloat EMOTION_GIF_SCALE      = 0.5;    //GIF表情缩放比例
static CGFloat EMOTION_EMOJI_SCALE    = 1.0;    //Emoji表情缩放比例
static CGFloat EMOTION_PNG_SCALE      = 1.0;    //PNG表情缩放比例

/**
 *  表情分类bar按钮触发事件类型
 */
typedef NS_ENUM(NSUInteger, EmotionCategoryType) {
    /**
     *  点击gif
     */
    EmotionCategoryTypeGIF,
    /**
     *  点击emoji
     */
    EmotionCategoryTypeEmoji,
    /**
     *  点击发送
     */
    EmotionCategoryTypeSend
};

@interface ALYEmotionsKeyboardView ()
<
UIScrollViewDelegate
>

/**
 *  表情scrollView
 */
@property (nonatomic, strong) UIScrollView *emotionsScrollView;

/**
 *  实时记录contentSize的宽度
 */
@property (nonatomic, assign) CGFloat contentSizeWidth;

/**
 *  实时记录当前处于活动状态的表情分类（默认gif）
 */
@property (nonatomic, assign) EmotionCategoryType currentCategoryType;

/**
 *  上一次滚动区域的下标（默认为0）
 */
@property (nonatomic, assign) NSInteger beforeIndex;

/**
 *  pageControl
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 *  表情分类bar
 */
@property (nonatomic, strong) UIView *emotionCategoryBar;

/**
 *  底部表情分类bar 当前被选中按钮
 */
@property (nonatomic, strong) UIButton *currentSelectBtn;

#pragma mark - GIF
/**
 *  gif图片
 */
@property (nonatomic, strong) NSArray *gifImageNames;

/**
 *  gif初始ContentOffSet
 */
@property (nonatomic, assign) CGPoint gifContentOffset;

/**
 *  gif模块 第一页的下标 （从0开始）
 */
@property (nonatomic, assign) NSInteger gifIndex;

#pragma mark - Emoji
/**
 *  emoji表情
 */
@property (nonatomic, strong) NSArray *emojiNames;

/**
 *  emoji初始ContentOffSet
 */
@property (nonatomic, assign) CGPoint emojiContentOffset;

/**
 *  emoji模块 第一页的下标
 */
@property (nonatomic, assign) NSInteger emojiIndex;

#pragma mark - PNG
/**
 *  png图片
 */
@property (nonatomic, strong) NSArray *pngImageNames;

/**
 *  png初始ContentOffSet
 */
@property (nonatomic, assign) CGPoint pngContentOffset;

/**
 *  png模块 第一页的下标
 */
@property (nonatomic, assign) NSInteger pngIndex;

@end

@implementation ALYEmotionsKeyboardView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<ALYEmotionsKeyboardViewDelegate>)delegate gifImageNames:(NSArray *)gifImageNames emojiNames:(NSArray *)emojiNames pngImageNames:(NSArray *)pngImageNames
{
    if (self = [super initWithFrame:frame])
    {
        _delegate = delegate;
        _gifImageNames = gifImageNames;
        _emojiNames = emojiNames;
        _pngImageNames = pngImageNames;
        
        //1、加载子控件
        [self addAllSubViews];
        
        //2、设置gif模块
        [self configureGIF];
        
        //3、设置emoji模块
        [self configureEmoji];
        
        //后续可以增加任意表情模块...
        
        //4、设置pageControl (默认gif被选中)
        [self configurePageControlWithALYEmotionType:ALYEmotionTypeGIF currentPage:0];
        
        //5、设置scrollView
        [self configureEmotionScrollView];
        
    }
    return self;
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    [self.emotionsScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(height*EMOTION_KEYBOARD_SCALE);
    }];
    
    [self.emotionCategoryBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(height*(1-EMOTION_KEYBOARD_SCALE));
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(width, 10));
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.emotionCategoryBar.mas_top).offset(-5);
    }];
}

#pragma mark - private method

- (void)addAllSubViews
{
    [self addSubview:self.emotionsScrollView];
    [self addSubview:self.emotionCategoryBar];
    [self addSubview:self.pageControl];
}
- (void)configurePNG
{
    //...
}
- (void)configureGIF
{
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height*EMOTION_KEYBOARD_SCALE;
    
    //单页数量
    NSInteger singlePageCount = GIF_COL * GIF_ROW;
    //实际gif图片数量
    NSInteger gifTotalCount = _gifImageNames.count;
    //实际需要gif页数
    NSInteger gifPageCount = gifTotalCount%singlePageCount == 0 ? (gifTotalCount/singlePageCount) : (gifTotalCount/singlePageCount+1);
    
    //scrollView 添加 gif页
    for (int i=0; i<gifPageCount; i++)
    {
        //获取本页的所有gif图片
        NSArray *gifImageNames = [ALYEmotionsKeyboardViewModel getGifEmotionsWithGifArray:_gifImageNames singleCount:singlePageCount index:i];
        
        //实例化gif pageView
        CGRect frame = CGRectMake(self.contentSizeWidth+i*width, 0, width, height);
        ALYGIFPageView *gifPageView = [[ALYGIFPageView alloc] initWithFrame:frame gifImageNames:gifImageNames];
        
        typeof(self) __weak weakSelf = self;
        [gifPageView setClickGIFEmotionBlock:^(NSDictionary *gifDict) {
            
            //回调给controller...
            if ([self.delegate respondsToSelector:@selector(emotionsKeyboardView:emotionType:didUseEmoji:didUseGIF:)])
            {
                [self.delegate emotionsKeyboardView:weakSelf
                                        emotionType:ALYEmotionTypeGIF
                                        didUseEmoji:@""
                                          didUseGIF:gifDict];
            }
            
        }];
        
        //逐页添加
        [self.emotionsScrollView addSubview:gifPageView];
    }
    
    //记录gif模块的contentOffSet (默认首个被选中)
    self.gifContentOffset = CGPointZero;
    
    //记录contentSize的宽度
    self.contentSizeWidth += width*gifPageCount;
    
    //记录gif模块首页的下标
    self.gifIndex = self.gifContentOffset.x / width;
}
- (void)configureEmoji
{
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height*EMOTION_KEYBOARD_SCALE;
    
    //单页数量 (每页emoji 右下角有个删除按钮)
    NSInteger singlePageCount = EMOJI_COL * EMOJI_ROW - 1;
    //实际emoji数量
    NSInteger emojiTotalCount = _emojiNames.count;
    //实际需要emoji页数
    NSInteger emojiPageCount = emojiTotalCount%singlePageCount == 0 ? (emojiTotalCount/singlePageCount) : (emojiTotalCount/singlePageCount+1);
    
    //scrollView 添加 emoji页
    for (int i=0; i<emojiPageCount; i++)
    {
        //获取本页的emoji
        NSArray *emojiArray = [ALYEmotionsKeyboardViewModel getEmojiEmotionsWithEmojiArray:_emojiNames singleCount:singlePageCount index:i];
        
        //实例化emoji 单页
        CGRect frame = CGRectMake(self.contentSizeWidth+i*width, 0, width, height);
        ALYEmojiPageView *emojiPageView = [[ALYEmojiPageView alloc] initWithFrame:frame emojiArray:emojiArray];
        
        typeof(self) __weak weakSelf = self;
        [emojiPageView setClickEmojiEmotionBlock:^(NSString *emoji, BOOL isDelete) {
            
            if (isDelete)
            {
                //emoji 点击删除
                if ([weakSelf.delegate respondsToSelector:@selector(emotionsKeyboardView:emotionType:didDelete:)])
                {
                    [weakSelf.delegate emotionsKeyboardView:self emotionType:ALYEmotionTypeEmoji didDelete:isDelete];
                }
            }
            else
            {
                //emoji 点击表情
                if ([weakSelf.delegate respondsToSelector:@selector(emotionsKeyboardView:emotionType:didUseEmoji:didUseGIF:)])
                {
                    [weakSelf.delegate emotionsKeyboardView:self emotionType:ALYEmotionTypeEmoji didUseEmoji:emoji didUseGIF:nil];
                }
            }
            
        }];
        
        //逐页添加
        [self.emotionsScrollView addSubview:emojiPageView];
    }
    
    //记录emoji模块的contentOffSet
    self.emojiContentOffset = CGPointMake(self.contentSizeWidth, 0);
    
    //记录contentSize的宽度
    self.contentSizeWidth += width*emojiPageCount;
    
    //记录emoji模块首页的下标
    self.emojiIndex = self.emojiContentOffset.x / width;
}
- (void)configurePageControlWithALYEmotionType:(ALYEmotionType)type currentPage:(NSInteger)currentPage
{
    //单页数量
    NSInteger singlePageCount = 0;
    //总数量
    NSInteger totalCount = 0;
    //实际需要页数
    NSInteger pageCount = 0;
    
    switch (type) {
        case ALYEmotionTypeGIF:
        {
            singlePageCount = GIF_COL * GIF_ROW;
            totalCount = _gifImageNames.count;
            pageCount = totalCount%singlePageCount == 0 ? (totalCount/singlePageCount) : (totalCount/singlePageCount+1);
        }
            break;
        case ALYEmotionTypePNG:
        {
            //...
        }
            break;
        case ALYEmotionTypeEmoji:
        {
            singlePageCount = EMOJI_COL * EMOJI_ROW - 1;
            totalCount = _emojiNames.count;
            pageCount = totalCount%singlePageCount == 0 ? (totalCount/singlePageCount) : (totalCount/singlePageCount+1);
        }
            break;
            
        default:
            break;
    }
    
    //更新pageControl
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = currentPage;
}
- (void)updateEmotionCategoryBar:(ALYEmotionType)type
{
    //记录当前被选中的按钮
    if (type == ALYEmotionTypeGIF)
    {
        self.currentSelectBtn = [self getButtonInCategoryBarWithEmotionCategoryType:EmotionCategoryTypeGIF];
    }
    
    if (type == ALYEmotionTypeEmoji)
    {
        self.currentSelectBtn = [self getButtonInCategoryBarWithEmotionCategoryType:EmotionCategoryTypeEmoji];
    }
    
    //处理被选中高亮状态
    for (UIButton *btn  in self.emotionCategoryBar.subviews)
    {
        if (btn.tag == type)
        {
            btn.selected = YES;
        }
        else
        {
            btn.selected = NO;
        }
    }
}
- (void)configureEmotionScrollView
{
    //最后一步，设置scrollView 实际滚动范围
    self.emotionsScrollView.contentSize = CGSizeMake(self.contentSizeWidth, 0);
}
- (UIButton *)getButtonInCategoryBarWithEmotionCategoryType:(EmotionCategoryType)type
{
    for (UIButton *btn  in self.emotionCategoryBar.subviews)
    {
        if (btn.tag == type)
        {
            return btn;
        }
    }
    return [UIButton buttonWithType:UIButtonTypeCustom];
}

#pragma mark - 点击事件

/**
 *  点击pageControl
 *
 *  @param pageControl
 */
- (void)pageChange:(UIPageControl *)pageControl
{
    CGFloat x = pageControl.currentPage * self.bounds.size.width;
    [self.emotionsScrollView setContentOffset:CGPointMake(self.emotionsScrollView.contentOffset.x+x, 0) animated:YES];
}

/**
 *  点击底部工具bar
 *
 *  @param button
 */
- (void)clickEmotionsBar:(UIButton *)button
{
    if (self.currentSelectBtn == button)
    {
        return ;
    }
    
    if (button.tag == EmotionCategoryTypeSend)
    {
        //点击发送 回调吧 -.-
        if ([self.delegate respondsToSelector:@selector(emotionsKeyboardView:didClickSend:)])
        {
            [self.delegate emotionsKeyboardView:self didClickSend:YES];
        }
        return ;
    }
    
    self.currentSelectBtn.selected = NO;
    self.currentSelectBtn = button;
    self.currentSelectBtn.selected = YES;
    
    switch (button.tag) {
        case EmotionCategoryTypeGIF:
        {
            //设置contenOffSet
            self.emotionsScrollView.contentOffset = self.gifContentOffset;
            
            //更新pagecontrol
            [self configurePageControlWithALYEmotionType:ALYEmotionTypeGIF currentPage:0];
            
            //更新beforeIndex
            self.beforeIndex = self.gifIndex;
        }
            break;
        case EmotionCategoryTypeEmoji:
        {
            self.emotionsScrollView.contentOffset = self.emojiContentOffset;
            [self configurePageControlWithALYEmotionType:ALYEmotionTypeEmoji currentPage:0];
            self.beforeIndex = self.emojiIndex;
        }
            break;
        case EmotionCategoryTypeSend:
        {
            //发送...
            
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"start x ==> %lf", scrollView.contentOffset.x);
    //开始...
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"x ==> %lf", scrollView.contentOffset.x);
    
    //下标（每一页表情都有一个唯一的下标）
    
    //上次滚动区域的下标
    NSInteger beforeIndex = self.beforeIndex;
    
    //本次滚动区域的下标
    NSInteger afterIndex = scrollView.contentOffset.x / self.emotionsScrollView.frame.size.width;
    
    if (beforeIndex == afterIndex)
    {
        return ;
    }
    else
    {
        //滚动范围：gif模块内
        if ((self.gifIndex <= beforeIndex && beforeIndex < self.emojiIndex) &&
            (self.gifIndex <= afterIndex  && afterIndex < self.emojiIndex))
        {
            self.pageControl.currentPage = afterIndex;
            self.beforeIndex = afterIndex;
            return ;
        }
        
        //滚动范围：从 gif模块 进入 emoji模块
        if ((self.gifIndex <= beforeIndex && beforeIndex < self.emojiIndex) &&
            (self.emojiIndex <= afterIndex))
        {
            //更新pageControl
            [self configurePageControlWithALYEmotionType:ALYEmotionTypeEmoji currentPage:0];
            
            //更新当前选中按钮
            [self updateEmotionCategoryBar:ALYEmotionTypeEmoji];
           
            self.beforeIndex = afterIndex;
            return ;
        }
        
        //滚动范围：emoji模块内
        if ((beforeIndex >= self.emojiIndex) && (afterIndex >= self.emojiIndex))
        {
            self.pageControl.currentPage = (afterIndex - self.emojiIndex);
            self.beforeIndex = afterIndex;
            return ;
        }
        
        //滚动范围：从 emoji模块 进入 gif模块
        if ((beforeIndex >= self.emojiIndex) && (afterIndex < self.emojiIndex))
        {
            [self configurePageControlWithALYEmotionType:ALYEmotionTypeGIF currentPage:self.emojiIndex-1];
            [self updateEmotionCategoryBar:ALYEmotionTypeGIF];
            self.beforeIndex = afterIndex;
            return ;
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"end x ==> %lf", scrollView.contentOffset.x);
    //结束...
}


#pragma mark - getter

- (UIScrollView *)emotionsScrollView
{
    if (!_emotionsScrollView)
    {
        _emotionsScrollView = [[UIScrollView alloc] init];
        _emotionsScrollView.delegate = self;
        _emotionsScrollView.contentInset = UIEdgeInsetsZero;
        _emotionsScrollView.pagingEnabled = YES;
        _emotionsScrollView.scrollEnabled = YES;
        _emotionsScrollView.alwaysBounceHorizontal = YES;
        _emotionsScrollView.alwaysBounceVertical = NO;
        _emotionsScrollView.showsHorizontalScrollIndicator = NO;
        _emotionsScrollView.showsVerticalScrollIndicator = NO;
        _emotionsScrollView.backgroundColor = [UIColor lightGrayColor];
    }
    return _emotionsScrollView;
}
- (CGFloat)contentSizeWidth
{
    if (!_contentSizeWidth)
    {
        _contentSizeWidth = 0.f;
    }
    return _contentSizeWidth;
}
- (EmotionCategoryType)currentCategoryType
{
    if (!_currentCategoryType)
    {
        _currentCategoryType = EmotionCategoryTypeGIF;
    }
    return _currentCategoryType;
}
- (NSInteger)beforeIndex
{
    if (!_beforeIndex)
    {
        _beforeIndex = 0;
    }
    return _beforeIndex;
}
- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        //根据测试，微信的pagecontrol并没有触发事件
//        [_pageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventTouchUpInside];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}
- (UIView *)emotionCategoryBar
{
    if (!_emotionCategoryBar)
    {
        _emotionCategoryBar = [[UIView alloc] init];
        _emotionCategoryBar.backgroundColor = [UIColor whiteColor];
        
        //暂时加三个按钮
        NSArray *titles = @[@"GIF", @"Emoji", @"发送"];
        CGFloat width = self.frame.size.width/titles.count;
        CGFloat height = self.frame.size.height*(1-EMOTION_KEYBOARD_SCALE);
        
        for (int i=0; i<titles.count; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i*width, 0, width, height);
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateSelected];
            
            switch (i) {
                case 0:
                {
                    button.tag = EmotionCategoryTypeGIF;
                    //默认gif按钮被选中
                    [self clickEmotionsBar:button];
                }
                    break;
                case 1:
                {
                    button.tag = EmotionCategoryTypeEmoji;
                }
                    break;
                case 2:
                {
                    button.tag = EmotionCategoryTypeSend;
                }
                    break;
                    
                default:
                    break;
            }
            
            [button addTarget:self action:@selector(clickEmotionsBar:) forControlEvents:UIControlEventTouchUpInside];
            [_emotionCategoryBar addSubview:button];
        }
        
    }
    return _emotionCategoryBar;
}
- (UIButton *)currentSelectBtn
{
    if (!_currentSelectBtn)
    {
        //默认gif按钮被选中
        for (UIButton *btn in self.emotionCategoryBar.subviews)
        {
            if (btn.tag == EmotionCategoryTypeGIF)
            {
                _currentSelectBtn = btn;
                break;
            }
        }
    }
    return _currentSelectBtn;
}

@end

/**************************** GIF表情页 **************************************/

#pragma mark - GIF表情页

@interface ALYGIFPageView ()

/**
 *  gif图片数组
 */
@property (nonatomic, strong) NSArray *gifImageNames;
@end

@implementation ALYGIFPageView

- (instancetype)initWithFrame:(CGRect)frame gifImageNames:(NSArray *)gifImageNames
{
    if (self = [super initWithFrame:frame])
    {
        _gifImageNames = gifImageNames;
        
        CGFloat width  = self.frame.size.width  / GIF_COL;
        CGFloat height = self.frame.size.height / GIF_ROW;
        
        for (int i=0; i<GIF_COL*GIF_ROW; i++)
        {
            //行号
            NSInteger row = i/GIF_COL;
            //列号
            NSInteger col = i%GIF_COL;
            //x
            CGFloat x = width*col;
            //y
            CGFloat y = height*row;
            
            //实例化
            YYImage *gifImage = [YYImage imageNamed:[_gifImageNames objectAtIndex:i]];
            YYAnimatedImageView *gifImageView = [[YYAnimatedImageView alloc] initWithImage:gifImage];
            gifImageView.frame = CGRectMake(x, y, width, height);
            gifImageView.tag = i;
            
            //根据缩放比例进行缩放
            CGSize originSize = gifImageView.frame.size;
            CGSize newSize = CGSizeMake(originSize.width*EMOTION_GIF_SCALE, originSize.height*EMOTION_GIF_SCALE);
            
            CGPoint originXY = gifImageView.frame.origin;
            CGPoint newXY = CGPointMake(originXY.x+(originSize.width-newSize.width)/2, originXY.y+(originSize.height-newSize.height)/2);
          
            gifImageView.frame = (CGRect) {newXY, newSize};
            
            //添加点击事件
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickGIFImage:)];
            tap.numberOfTapsRequired    = 1;
            tap.numberOfTouchesRequired = 1;
            
            gifImageView.userInteractionEnabled = YES;
            [gifImageView addGestureRecognizer:tap];
            
            
            [self addSubview:gifImageView];
        }
    }
    return self;
}
/**
 *  点击某个gif表情
 *
 *  @param tap
 */
- (void)clickGIFImage:(UITapGestureRecognizer *)tap
{
    NSInteger index = tap.view.tag;
    
    if (index < _gifImageNames.count)
    {
        NSString *gifName = [_gifImageNames objectAtIndexNotBeyond:index];
        
        YYImage *image = [YYImage imageNamed:gifName];
        
        NSData *gifData = image.animatedImageData;
        
        //回调...
        if (_clickGIFEmotionBlock)
        {
            NSDictionary *gifDict = @{GIFNameKey:gifName, GIFDatakey:gifData};
            
            _clickGIFEmotionBlock(gifDict);
        }
        
    }
    else
    {
        //数组越界...
        return ;
    }
}

@end


/**************************** Emoji表情页 **************************************/

#pragma mark - Emoji表情页

@interface ALYEmojiPageView ()

/**
 *  emoji数组
 */
@property (nonatomic, strong) NSArray *emojiArray;
@end

@implementation ALYEmojiPageView

- (instancetype)initWithFrame:(CGRect)frame emojiArray:(NSArray *)emojiArray
{
    if (self = [super initWithFrame:frame])
    {
        _emojiArray = emojiArray;
        
        CGFloat width  = self.frame.size.width  / EMOJI_COL;
        CGFloat height = self.frame.size.height / EMOJI_ROW;
        
        for (int i=0; i<EMOJI_COL*EMOJI_ROW; i++)
        {
            //行号
            NSInteger row = i/EMOJI_COL;
            //列号
            NSInteger col = i%EMOJI_COL;
            //x
            CGFloat x = width*col;
            //y
            CGFloat y = height*row;
            
            //实例化
            UIButton *emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            //最后一个 emoji删除按钮
            if (i == EMOJI_COL*EMOJI_ROW-1)
            {
                [emojiBtn setBackgroundImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
            }
            //emoji正常按钮
            else
            {
                NSString *emojiStr = [_emojiArray objectAtIndexNotBeyond:i];
                
                if (emojiStr.length > 0)
                {
                    [emojiBtn setTitle:[_emojiArray objectAtIndexNotBeyond:i] forState:UIControlStateNormal];
//                    [emojiBtn setTitle:@"\ue415" forState:UIControlStateNormal];
                    [emojiBtn setBackgroundColor:[UIColor redColor]];
                }
                else
                {
                    //不足一页，空位为nil
                    continue;
                }
                
            }
            
            emojiBtn.frame = CGRectMake(x, y, width, height);
            emojiBtn.tag = i;
            
            //根据缩放比例进行缩放
            CGSize originSize = emojiBtn.frame.size;
            CGPoint originXY = emojiBtn.frame.origin;
            
            CGSize newSize = CGSizeMake(originSize.width*EMOTION_GIF_SCALE, originSize.height*EMOTION_GIF_SCALE);
            CGPoint newXY = CGPointMake(originXY.x+(originSize.width-newSize.width)/2, originXY.y+(originSize.height-newSize.height)/2);
            
            emojiBtn.frame = (CGRect) {newXY, newSize};
            
            //添加点击事件
            [emojiBtn addTarget:self action:@selector(clickEmojiOrDelete:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:emojiBtn];
        }
    }
    return self;
}

/**
 *  点击emoji表情 或者 删除按钮
 *
 *  @param btn
 */
- (void)clickEmojiOrDelete:(UIButton *)btn;
{
    if (btn.tag == EMOJI_COL*EMOJI_ROW-1)
    {
        //点击删除
        if (_clickEmojiEmotionBlock)
        {
            _clickEmojiEmotionBlock(@"", YES);
        }
    }
    else
    {
        //点击emoji
        if (_clickEmojiEmotionBlock)
        {
            NSString *emojiStr = [_emojiArray objectAtIndexNotBeyond:btn.tag];
            _clickEmojiEmotionBlock(emojiStr, NO);
        }
        
    }
}

@end


#warning 暂时废弃PNG

#pragma mark - PNG表情页
/**************************** PNG表情页 **************************************/

@implementation ALYPNGPageView

- (instancetype)initWithFrame:(CGRect)frame pngImageNames:(NSArray *)pngImageNames
{
    if (self = [super initWithFrame:frame])
    {
        
    }
    return self;
}

@end














