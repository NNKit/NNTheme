//
//  NNTheme_Private.h
//  NNTheme
//
//  Created by XMFraker on 2017/11/21.
//

#import <NNTheme/NNTheme.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NNConfigThemeKeyMode) {
    NNConfigThemeKeyModeKeyPath,
    NNConfigThemeKeyModeSelector,
    NNConfigThemeKeyModeBlock,
};

static NSString * const kNNThemeChangedNotification = @"com.XMFraker.NNTheme.kNNThemeChangedNotification";
static NSString * const kNNThemeStoredNotification = @"com.XMFraker.NNTheme.kNNThemeStoredNotification";
static NSString * const kNNThemeRemovedNotification = @"com.XMFraker.NNTheme.kNNThemeRemovedNotification";

static NSString * const kNNUsingThemeIdentifierKey = @"com.XMFraker.NNTheme.kNNThemeIdentifierKey";
static NSString * const kNNStoredThemeIdentifiersKey = @"com.XMFraker.NNTheme.kNNStoredThemeIdentifiersKey";
static NSString * const kNNStoredThemeInfosKey = @"com.XMFraker.NNTheme.kNNStoredThemeConfigInfosKey";

@interface NNTheme ()

@property (copy, nonatomic, nonnull)   NSString *identifier;
@property (copy, nonatomic, nonnull)   NSString *defaultIdentifier;
@property (strong, nonatomic, nonnull) NSMutableArray<NSString *> *storedThemeIdentifiers;
@property (strong, nonatomic, nonnull) NSMutableDictionary *storedThemeInfos;

@end


@interface NNThemeConfig ()

@property (copy, nonatomic)   void(^updatingCurrentThemeHandler)(void);
@property (copy, nonatomic)   NNThemeChangingHandler currentThemeChangingHandler;

@property (copy, nonatomic)   NSString *usingThemeIdentifier;

/** @{identifier : @{block : value}} */
@property (strong, nonatomic) NSMutableDictionary <NSString * , NSMutableDictionary *>*blockConfigInfo;
/** @{identifier : @{keyPath : value}} */
@property (strong, nonatomic) NSMutableDictionary <NSString * , NSMutableDictionary *>*keyPathConfigInfo;
/** @{identifier : @{SEL.string : @[parameter, parameter, ...]}} */
@property (strong, nonatomic) NSMutableDictionary <NSString * , NSMutableDictionary *>*selectorConfigInfo;
/** @{ @(mode) : @{@(keypath or block) : key} } or @{ @(mode) : @{SEL.string : @[key, key, ...]} }*/
@property (strong, nonatomic) NSMutableDictionary <NSNumber * , NSMutableDictionary *>*keyConfigInfo;

@end

@interface NNTheme (NNTheme_Private)
+ (instancetype)globalTheme;
+ (NSUserDefaults *)themeDefaults;
+ (void)storeIdentifier:(NSString *)identifier;
+ (void)removeIdentifier:(NSString *)identifier;

+ (nullable id)storedObjectUsingThemeDefaultsForKey:(NSString *)key;
+ (void)storeObjectUsingThemeDefaults:(nullable id)object forKey:(NSString *)key;
@end

@interface NNTheme (NNTheme_JSONPrivate)
+ (nullable id)valueWithThemeIdentifier:(NSString *)identifier key:(NSString *)key;
@end


@interface NNThemeConfig (NNTheme_Private)

- (void)storeCustomHandler:(NNThemeHandler)handler identifier:(NSString *)identifier;
- (void)storeKeyPath:(NSString *)keyPath value:(id)value identifier:(NSString *)identifier;
- (void)storeSelector:(SEL)sel values:(NSArray *)values  identifier:(NSString *)identifier;

- (void)handleThemeConfigRemovedNotification:(NSNotification *)notification;
- (void)handleThemeConfigStoredNotification:(NSNotification *)notification;

- (void)updateThemeAfterThemeConfiged:(NSString *)identifier;
@end

@interface NSObject (NNThemeConfig_Private)

- (void)updateThemeConfig;
- (void)handleThemeConfigChangedNotification:(NSNotification *)notification;
@end

NS_ASSUME_NONNULL_END
