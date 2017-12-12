//
//  NNViewController.m
//  NNTheme
//
//  Created by ws00801526 on 11/21/2017.
//  Copyright (c) 2017 ws00801526. All rights reserved.
//

#import "NNViewController.h"
#import <NNTheme/NNTheme.h>

static NSString *const kNNThemeDay = @"DAY";
static NSString *const kNNThemeNight = @"NIGHT";

@interface NNViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation NNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [NNTheme usingDefaultThemeWithIdentifier:kNNThemeNight];
    
    [NNTheme storeThemeInfo:@{
        @"color": @{
            @"ident1": @"#c22b4f",
            @"ident2": @"#9a1938",
            @"ident7": @"#FFFFFF",
            @"ident8": @"#000000"
        },
        @"image": @{
            @"ident3": @"night.png",
            @"ident4": @"true.png"
        },
        @"other": @{
            @"ident5": @"Night 1.0",
            @"ident6": @"1.0"
        }
    } forIdentifier:kNNThemeNight path:nil];
    
    [NNTheme storeThemeInfo:@{
                              @"color": @{
                                      @"ident1": @"#11c2c3",
                                      @"ident2": @"#9a1938",
                                      @"ident7": @"#FFFFFF",
                                      @"ident8": @"#000000"
                                      },
                              @"image": @{
                                      @"ident3": @"day.png",
                                      @"ident4": @"true.png"
                                      },
                              @"other": @{
                                      @"ident5": @"Day 1.0",
                                      @"ident6": @"1.0"
                                      }
                              } forIdentifier:kNNThemeDay path:nil];
    
    self.view.themeConfig.backgroundColor(kNNThemeDay, NNColorHex(0xf6f6f6)).backgroundColor(kNNThemeNight, NNColorHex(0x0e0e0e));
    self.view.themeConfig.changingHandler(^(NSString *identifier, id item) {
        NNLogD(@"theme changed :%@ for item :%@", identifier, item);
    });
    self.view.themeConfig.customHandler(kNNThemeDay, ^(id item) {
        NNLogD(@"changed %@ :%@", kNNThemeDay, item);
    }).customHandler(kNNThemeNight, ^(id item) {
//        NNLogD(@"changed %@ :%@", kNNThemeNight, item);
    });
    
    self.label.themeConfig.textColorKey(@"ident1");
    self.label.themeConfig.textColor(kNNThemeDay, [UIColor lightGrayColor]).textColor(kNNThemeNight, [UIColor greenColor]);
    self.textField.themeConfig.textColor(kNNThemeDay, [UIColor lightGrayColor]).textColor(kNNThemeNight, [UIColor greenColor]);
    self.switchControl.themeConfig.onTintColor(kNNThemeDay, [UIColor lightGrayColor]).onTintColor(kNNThemeNight, [UIColor redColor]);
    self.progressView.themeConfig.progressTintColor(kNNThemeDay, [UIColor lightGrayColor]).progressTintColor(kNNThemeNight, [UIColor redColor]);
    self.label.themeConfig.selectorAndValueKey(@selector(setText:), @"ident5");
    
    self.label.themeConfig.borderColor(kNNThemeDay, [UIColor purpleColor])
    .borderColor(kNNThemeNight, [UIColor magentaColor])
    .selectorAndArray(kNNThemeDay, @selector(setBorderWidth:), @[@3])
    .selectorAndArray(kNNThemeNight, @selector(setBorderWidth:), @[@5]);
    self.imageView.themeConfig.imageKey(@"ident3");
    
    self.button.themeConfig.buttonTitleColor(kNNThemeDay, [UIColor redColor], UIControlStateNormal)
                            .buttonTitleColor(kNNThemeNight, [UIColor greenColor], UIControlStateNormal)
                            .selectorAndArray(kNNThemeDay, @selector(setTitle:forState:), @[kNNThemeDay, @(UIControlStateNormal)])
                            .selectorAndArray(kNNThemeNight, @selector(setTitle:forState:), @[kNNThemeNight, @(UIControlStateNormal)]);
    
    self.pageControl.themeConfig.pageIndicatorTintColor(kNNThemeDay, [UIColor redColor]).currentPageIndicatorTintColor(kNNThemeDay, [UIColor greenColor]).pageIndicatorTintColor(kNNThemeNight, [UIColor greenColor]).currentPageIndicatorTintColor(kNNThemeNight, [UIColor redColor]);
}

#pragma mark - Events

- (IBAction)handleThemeChanged:(UISwitch *)sender {
    [NNTheme usingThemeWithIdentifier:sender.on ? kNNThemeDay : kNNThemeNight];
}

- (IBAction)handleButtonThemeChanged:(UIButton *)sender {
    
    if ([[NNTheme usingThemeIdentifier] isEqualToString:kNNThemeDay]) {
        [NNTheme usingThemeWithIdentifier:kNNThemeNight];
    } else {
        [NNTheme usingThemeWithIdentifier:kNNThemeDay];
    }
}

@end
