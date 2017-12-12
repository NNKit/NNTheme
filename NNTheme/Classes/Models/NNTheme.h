//
//  NNTheme.h
//  NNTheme
//
//  Created by XMFraker on 2017/11/21.
//

#import <UIKit/UIKit.h>
#import <NNCore/NNCore.h>
#import <NNTheme/NNThemeHelper.h>

NS_ASSUME_NONNULL_BEGIN

@interface NNTheme : NSObject

/** 根据主题标识符-切换主题 */
+ (void)usingThemeWithIdentifier:(NSString *)identifier;
/** 设置默认主题标识符 */
+ (void)usingDefaultThemeWithIdentifier:(NSString *)identifier;
/** 当前正在使用的主题标识符 */
+ (NSString *)usingThemeIdentifier;
/** 当前已经保存的主题标识符 */
+ (NSArray<NSString *> *)storedThemeIdentifiers;
/** 当前已经保存的主题信息 */
+ (NSDictionary *)storedThemeInfos;

@end

@interface NNTheme (NNThemeJSON)

/**
 保存一个主题信息

 @param themeInfo  主题相关信息
 @param identifier 主题标识符
 @param path       主题资源对应的存储路径, 默认为nil
 */
+ (void)storeThemeInfo:(id)themeInfo forIdentifier:(NSString *)identifier path:(nullable NSString *)path;

/**
 移除一个主题信息

 @discussion 移除主题, 如果有对应的主题path, 会同时删除该path文件夹下所有文件
 @param identifier 主题标识符
 */
+ (void)removeStoredThemeConfigInfoWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
