//
//  NNThemeHelper.h
//  NNTheme
//
//  Created by XMFraker on 2017/11/21.
//

#ifndef NNThemeHelper_h
#define NNThemeHelper_h

@class NNThemeConfig;

typedef void(^NNThemeHandler)(id item);
typedef void(^NNThemeValueHandler)(id item, id value);
typedef void(^NNThemeChangingHandler)(NSString *identifier, id item);

typedef NNThemeConfig *(^NNConfigThemeKey)(NSString *key);
typedef NNThemeConfig *(^NNConfigThemeKeyAndState)(NSString *key, UIControlState state);
typedef NNThemeConfig *(^NNConfigThemeKeyAndHandler)(NSString *key, NNThemeValueHandler handler);
typedef NNThemeConfig *(^NNConfigThemeColor)(NSString *identifier, id color);
typedef NNThemeConfig *(^NNConfigThemeImage)(NSString *identifier, id image);
typedef NNThemeConfig *(^NNConfigThemeColorAndState)(NSString *identifier, id color, UIControlState state);
typedef NNThemeConfig *(^NNConfigThemeImageAndState)(NSString *identifier, id image, UIControlState state);

typedef NNThemeConfig *(^NNConfigThemeSelectorAndColor)(NSString *identifier, SEL sel, id color);
typedef NNThemeConfig *(^NNConfigThemeSelectorAndImage)(NSString *identifier, SEL sel, id image);
typedef NNThemeConfig *(^NNConfigThemeSelectorAndValues)(NSString *identifier, SEL sel, ...);
typedef NNThemeConfig *(^NNConfigThemeSelectorAndArray)(NSString *identifier, SEL sel, NSArray * values);

typedef NNThemeConfig *(^NNConfigThemeKeyPathAndValue)(NSString *identifier, NSString *keyPath, id value);

typedef NNThemeConfig *(^NNConfigThemeChangingHandler)(NNThemeChangingHandler handler);
typedef NNThemeConfig *(^NNConfigThemeCustomHandler)(NSString *identifier, NNThemeHandler);
typedef NNThemeConfig *(^NNConfigMultiThemeCustomHandler)(NSArray<NSString *> *identifiers, NNThemeHandler);

typedef NNThemeConfig *(^NNConfigRemoveThemeKeyPathHandler)(NSString *identifier, NSString *keyPath);
typedef NNThemeConfig *(^NNConfigRemoveThemeSelectorHandler)(NSString *identifier, SEL sel);
typedef NNThemeConfig *(^NNConfigRemoveKeyPathHandler)(NSString *keyPath);
typedef NNThemeConfig *(^NNConfigRemoveThemeHandler)(NSString *identifier);
typedef NNThemeConfig *(^NNConfigRemoveSelectorHandler)(SEL sel);
typedef NNThemeConfig *(^NNConfigRemoveConfigsHandler)(void);

@interface NNThemeConfig : NSObject

/// ========================================
/// @name   Global
/// ========================================

/** 配置theme改变后回调handler @code  .changingHandler(^(NSString *identifier, id item) { youd custom }) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeChangingHandler changingHandler;

/// ========================================
/// @name   Basic
/// ========================================

/** 配置自定义配置回调 @code .customHandler(@"identifier", ^(id item) { your custom theme handler }) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeCustomHandler customHandler;
/** 配置多个theme自定义配置回调 @code .customHandler(@[@"identifier1", @"identifier2"], ^(id item) { your custom theme handler }) @endcode */
@property (copy, nonatomic, readonly)   NNConfigMultiThemeCustomHandler multiCustomHandler;
/** 配置theme setValue:forKeyPath @code .keyPathAndValue(@"identifier", @"keyPath", your value) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKeyPathAndValue keyPathAndValue;
/** 配置theme SEL And Image @code .selectorAndImage(@"identifier", your selector, your image value) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeSelectorAndImage selectorAndImage;
/** 配置theme SEL And Image @code .selectorAndColor(@"identifier", your selector, your color value) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeSelectorAndColor selectorAndColor;
/** 配置theme SEL And Image @code .selectorAndColor(@"identifier", your selector, your values, ...) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeSelectorAndValues selectorAndValues;
/** 配置theme SEL And Image @code .selectorAndColor(@"identifier", your selector, @[your values]) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeSelectorAndArray  selectorAndArray;

/** 移除keyPath配置 @code .removeKeyPath(@"identifier", @"keyPath") @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveThemeKeyPathHandler removeKeyPath;
/** 移除selector配置 @code .removeSelector(@"identifier", your selector) @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveThemeSelectorHandler removeSelector;
/** 移除所有配置 @code .removeConfigs() @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveConfigsHandler removeConfigs;
/** 移除指定theme的配置 @code .removeConfigWithIdentifier(@"identifier") @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveThemeHandler removeConfigWithIdentifier;
/** 移除指定keyPath的配置 @code .removeConfigWithKeyPath(@"your keyPath") @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveKeyPathHandler removeConfigWithKeyPath;
/** 移除指定keyPath的配置 @code .removeConfigWithSelector(@"your selector") @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveSelectorHandler removeConfigWithSelector;

/// ========================================
/// @name   Color
/// ========================================

/** item should respondsToSelector:@selector(setTintColor:) @code .tintColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor tintColor;
/** item should respondsToSelector:@selector(setTextColor:) @code .textColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor textColor;
/** item should respondsToSelector:@selector(setFillColor:) @code .fillColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor fillColor;
/** item should respondsToSelector:@selector(setStrokeColor:) @code .strokeColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor strokeColor;
/** item should respondsToSelector:@selector(setBorderColor:) @code .borderColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor borderColor;
/** item should respondsToSelector:@selector(setShadowColor:) @code .shadowColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor shadowColor;
/** item should respondsToSelector:@selector(setOnTintColor:) @code .onTintColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor onTintColor;
/** item should respondsToSelector:@selector(setThumbTintColor:) @code .thumbTintColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor thumbTintColor;
/** item should respondsToSelector:@selector(setSeparatorColor:) @code .separatorColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor separatorColor;
/** item should respondsToSelector:@selector(setBarTintColor:) @code .barTintColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor barTintColor;
/** item should respondsToSelector:@selector(setBackgroundColor:) @code .backgroundColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor backgroundColor;
/** 配置placeholderColor @code .placeholderColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor placeholderColor;
/** item should respondsToSelector:@selector(setTrackTintColor:) @code .trackTintColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor trackTintColor;
/** item should respondsToSelector:@selector(setProgressTintColor:) @code .progressTintColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor progressTintColor;
/** item should respondsToSelector:@selector(setHighlightTextColor:) @code .highlightTextColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor highlightTextColor;
/** item should respondsToSelector:@selector(setPageIndicatorTintColor:) @code .pageIndicatorTintColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor pageIndicatorTintColor;
/** item should respondsToSelector:@selector(setCurrentPageIndicatorTintColor:) @code .currentPageIndicatorTintColor(@"<#your theme identifier#>", <#UIColor#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColor currentPageIndicatorTintColor;

/** item should respondsToSelector:@selector(setTitleColor:forState:) @code .buttonTitleColor(@"<#your theme identifier#>", <#UIColor#>, <#state#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColorAndState buttonTitleColor;
/** item should respondsToSelector:@selector(setTitleShadowColor:forState:) @code .buttonTitleShadowColor(@"<#your theme identifier#>", <#UIColor#>, <#state#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeColorAndState buttonTitleShadowColor;

/// ========================================
/// @name   Image
/// ========================================

/** item should respondsToSelector:@selector(setImage:) @code .image(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage image;
/** item should respondsToSelector:@selector(setTrackImage:) @code .trackImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage trackImage;
/** item should respondsToSelector:@selector(setProgressImage:) @code .progressImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage progressImage;
/** item should respondsToSelector:@selector(setShadowImage:) @code .shadowImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage shadowImage;
/** item should respondsToSelector:@selector(setSelectedIamge:) @code .selectedImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage selectedImage;
/** item should respondsToSelector:@selector(setBackgroundImage:) @code .backgroundImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage backgroundImage;
/** item should respondsToSelector:@selector(setBackIndicatorImage:) @code .backIndicatorImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage backIndicatorImage;
/** item should respondsToSelector:@selector(setBackIndicatorTransitionMaskImage:) @code .backIndicatorTransitionMaskImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage backIndicatorTransitionMaskImage;
/** item should respondsToSelector:@selector(setSelectionIndicatorImage:) @code .selectionIndicatorImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage selectionIndicatorImage;
/** item should respondsToSelector:@selector(setScopeBarBackgroundImage:) @code .scopeBarBackgroundImage(@"<#your theme identifier#>", <#UIImage#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImage scopeBarBackgroundImage;

/** item should respondsToSelector:@selector(setImage:forState:) @code .buttonImage(@"<#your theme identifier#>", <#UIImage#>, <#state#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImageAndState buttonImage;
/** item should respondsToSelector:@selector(setBackgroundImage:forState:) @code .buttonBackgroundImage(@"<#your theme identifier#>", <#UIImage#>, <#state#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeImageAndState buttonBackgroundImage;

@end

@interface NNThemeConfig (NNThemeKey)

/// ========================================
/// @name   Basic
/// ========================================

@property (copy, nonatomic, readonly)   NNThemeConfig *(^keyPathAndValueKey)(NSString *keyPath, NSString *valueKey);
@property (copy, nonatomic, readonly)   NNThemeConfig *(^selectorAndValueKey)(SEL sel, NSString *valueKey);
@property (copy, nonatomic, readonly)   NNThemeConfig *(^selectorAndValueKeyArray)(SEL sel, NSArray *valueArray);

/** 移除指定keyPath的valueKey配置 @code .removeKeyPathValueKey(keyPath) @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveKeyPathHandler removeKeyPathValueKey;
/** 移除指定selector的valueKey配置 @code .removeSelectorValueKey(selector) @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveSelectorHandler removeSelectorValueKey;
/** 移除通过key配置的主题信息 @code .removeValueKey() @endcode */
@property (copy, nonatomic, readonly)   NNConfigRemoveConfigsHandler removeValueKey;

/// ========================================
/// @name   Color
/// ========================================

/** item should respondsToSelector:@selector(setTintColor:) @code .tintColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey tintColorKey;
/** item should respondsToSelector:@selector(setTextColor:) @code .textColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey textColorKey;
/** item should respondsToSelector:@selector(setFillColor:) @code .fillColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey fillColorKey;
/** item should respondsToSelector:@selector(setStrokeColor:) @code .strokeColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey strokeColorKey;
/** item should respondsToSelector:@selector(setBorderColor:) @code .borderColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey borderColorKey;
/** item should respondsToSelector:@selector(setShadowColor:) @code .shadowColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey shadowColorKey;
/** item should respondsToSelector:@selector(setOnTintColor:) @code .onTintColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey onTintColorKey;
/** item should respondsToSelector:@selector(setThumbTintColor:) @code .thumbTintColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey thumbTintColorKey;
/** item should respondsToSelector:@selector(setSeparatorColor:) @code .separatorColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey separatorColorKey;
/** item should respondsToSelector:@selector(setBarTintColor:) @code .barTintColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey barTintColorKey;
/** item should respondsToSelector:@selector(setBackgroundColor:) @code .backgroundColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey backgroundColorKey;
/** 配置placeholderColor @code .placeholderColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey placeholderColorKey;
/** item should respondsToSelector:@selector(setTrackTintColor:) @code .trackTintColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey trackTintColorKey;
/** item should respondsToSelector:@selector(setProgressTintColor:) @code .progressTintColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey progressTintColorKey;
/** item should respondsToSelector:@selector(setHighlightTextColor:) @code .highlightTextColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey highlightTextColorKey;
/** item should respondsToSelector:@selector(setPageIndicatorTintColor:) @code .pageIndicatorTintColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey pageIndicatorTintColorKey;
/** item should respondsToSelector:@selector(setCurrentPageIndicatorTintColor:) @code .currentPageIndicatorTintColorKey(@"<#your color value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey currentPageIndicatorTintColorKey;

/** item should respondsToSelector:@selector(setTitleColor:forState:) @code .buttonTitleColorKey(@"<#your color value key#>", <#state#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKeyAndState buttonTitleColorKey;
/** item should respondsToSelector:@selector(setTitleShadowColor:forState:) @code .buttonTitleShadowColorKey(@"<#your color value key#>", <#state#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKeyAndState buttonTitleShadowColorKey;

/// ========================================
/// @name   Image
/// ========================================

/** item should respondsToSelector:@selector(setImage:) @code .imageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey imageKey;
/** item should respondsToSelector:@selector(setTrackImage:) @code .trackImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey trackImageKey;
/** item should respondsToSelector:@selector(setProgressImage:) @code .progressImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey progressImageKey;
/** item should respondsToSelector:@selector(setShadowImage:) @code .shadowImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey shadowImageKey;
/** item should respondsToSelector:@selector(setSelectedIamge:) @code .selectedImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey selectedImageKey;
/** item should respondsToSelector:@selector(setBackgroundImage:) @code .backgroundImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey backgroundImageKey;
/** item should respondsToSelector:@selector(setBackIndicatorImage:) @code .backIndicatorImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey backIndicatorImageKey;
/** item should respondsToSelector:@selector(setBackIndicatorTransitionMaskImage:) *
 * @code .backIndicatorTransitionMaskImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey backIndicatorTransitionMaskImageKey;
/** item should respondsToSelector:@selector(setSelectionIndicatorImage:) @code .selectionIndicatorImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey selectionIndicatorImageKey;
/** item should respondsToSelector:@selector(setScopeBarBackgroundImage:) @code .scopeBarBackgroundImageKey(@"<#your image value key#>") @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKey scopeBarBackgroundImageKey;

/** item should respondsToSelector:@selector(setImage:forState:) @code .buttonImageKey(@"<#your image value key#>", <#state#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKeyAndState buttonImageKey;
/** item should respondsToSelector:@selector(setBackgroundImage:forState:) @code .buttonBackgroundImageKey(@"<#your image value key#>", <#state#>) @endcode */
@property (copy, nonatomic, readonly)   NNConfigThemeKeyAndState buttonBackgroundImageKey;

@end

@interface NSString (NNThemeKey)
@property (assign, nonatomic, readonly, getter=isValueKeyOfTheme) BOOL valueKeyOfTheme;
+ (instancetype)stringWithThemeKey:(NSString *)key;
@end

@interface NSObject (NNThemeConfig)
@property (strong, nonatomic, readonly) NNThemeConfig *themeConfig;
@end

#endif /* NNThemeHelper_h */
