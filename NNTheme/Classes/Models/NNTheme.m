//
//  NNTheme.m
//  NNTheme
//
//  Created by XMFraker on 2017/11/21.
//

#import "NNTheme_Private.h"

@implementation NNTheme

#pragma mark - Setter

- (void)setIdentifier:(NSString *)identifier {
    
    if ([_identifier isEqualToString:identifier]) {
        return;
    }
    _identifier = [identifier copy];
    [NNTheme storeObjectUsingThemeDefaults:identifier forKey:kNNUsingThemeIdentifierKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNNThemeChangedNotification object:nil];
}

#pragma mark - Getter

- (NSMutableArray <NSString *> *)storedThemeIdentifiers {
    if (!_storedThemeIdentifiers) {
        _storedThemeIdentifiers = [NSMutableArray arrayWithArray:[NNTheme storedObjectUsingThemeDefaultsForKey:kNNStoredThemeIdentifiersKey]];
    }
    return _storedThemeIdentifiers;
}

- (NSMutableDictionary *)storedThemeInfos {
    
    if (!_storedThemeInfos) {
        _storedThemeInfos = [NSMutableDictionary dictionaryWithDictionary:[NNTheme storedObjectUsingThemeDefaultsForKey:kNNStoredThemeInfosKey]];
    }
    return _storedThemeInfos;
}

#pragma mark - Class Methods

+ (void)usingThemeWithIdentifier:(NSString *)identifier {
    
    NSAssert(identifier, @"主题标识符不能为空");
    NSAssert([[NNTheme storedThemeIdentifiers] containsObject:identifier], @"主题不存在, 检查配置");
    [NNTheme globalTheme].identifier = [identifier copy];
}

+ (void)usingDefaultThemeWithIdentifier:(NSString *)identifier {
    
    NSAssert(identifier, @"主题标识符不能为空");
    [NNTheme globalTheme].defaultIdentifier = identifier;
    if (![NNTheme globalTheme].identifier && ![[NNTheme themeDefaults] stringForKey:kNNUsingThemeIdentifierKey]) {
        [NNTheme globalTheme].identifier = identifier;
    }
}

+ (NSString *)usingThemeIdentifier {
    return [NNTheme globalTheme].identifier ? : [[NNTheme themeDefaults] objectForKey:kNNUsingThemeIdentifierKey];
}

+ (NSArray<NSString *> *)storedThemeIdentifiers {
    return [NNTheme globalTheme].storedThemeIdentifiers;
}

+ (NSDictionary *)storedThemeInfos {
    return [NNTheme globalTheme].storedThemeInfos;
}

@end


@implementation NNTheme (NNThemeJSON)

+ (void)storeThemeInfo:(id)themeInfo forIdentifier:(NSString *)identifier path:(NSString *)path {
    
    NSAssert(themeInfo && [NSJSONSerialization isValidJSONObject:themeInfo], @"themeInfo should be JSON");
    NSAssert(identifier, @"theme identifier should not be nil");
    NSDictionary *storedInfo = path.length ? @{ @"info" : themeInfo, @"path" : path } : @{ @"info" : themeInfo};
    [[NNTheme globalTheme].storedThemeInfos setObject:storedInfo forKey:identifier];
    [NNTheme storeObjectUsingThemeDefaults:[NNTheme globalTheme].storedThemeInfos forKey:kNNStoredThemeInfosKey];
    [NNTheme storeIdentifier:identifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNNThemeStoredNotification object:nil userInfo:@{@"identifier" : identifier}];
}

+ (void)removeStoredThemeConfigInfoWithIdentifier:(NSString *)identifier {
    
    NSAssert(identifier, @"theme identifier should not be nil");
    if ([[NNTheme storedThemeIdentifiers] containsObject:identifier] && ![[NNTheme globalTheme].defaultIdentifier isEqualToString:identifier]) {
        
        // 清除本地path下的存储的图片等信息
        NSDictionary *storedInfo = [[NNTheme storedThemeInfos] safeObjectForKey:identifier];
        NSString *path = [storedInfo safeObjectForKey:@"path"];
        if (path && path.length) {
            NSError *error = nil;
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            [[NSFileManager defaultManager] removeItemAtPath:[documentPath stringByAppendingPathComponent:path] error:&error];
            if (error) { NNLogW(@"clear local path error :%@", error); }
        }
        
        [NNTheme removeIdentifier:identifier];
        [[NNTheme globalTheme].storedThemeInfos removeObjectForKey:identifier];
        [NNTheme storeObjectUsingThemeDefaults:[NNTheme globalTheme].storedThemeInfos forKey:kNNStoredThemeInfosKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNNThemeRemovedNotification object:nil userInfo:@{@"identifier" : identifier}];
        if ([[NNTheme usingThemeIdentifier] isEqualToString:identifier]) { [NNTheme usingThemeWithIdentifier:[NNTheme globalTheme].defaultIdentifier]; }
    }
}

@end

@implementation NNThemeConfig

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        
        _blockConfigInfo = [NSMutableDictionary dictionary];
        _keyPathConfigInfo = [NSMutableDictionary dictionary];
        _selectorConfigInfo = [NSMutableDictionary dictionary];
        _keyConfigInfo = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeConfigRemovedNotification:) name:kNNThemeRemovedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeConfigStoredNotification:) name:kNNThemeStoredNotification object:nil];
        
    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    objc_removeAssociatedObjects(self);
}

#pragma mark - Getter

/// ========================================
/// @name   Global
/// ========================================

- (NNConfigThemeChangingHandler)changingHandler {
    __weak typeof(self) wSelf = self;
    return ^(NNThemeChangingHandler handler) {
        __strong typeof(wSelf) self = wSelf;
        if (handler) { self.currentThemeChangingHandler = handler; }
        return self;
    };
}

/// ========================================
/// @name   Basic
/// ========================================

- (NNConfigThemeCustomHandler)customHandler {
    __weak typeof(self) wSelf = self;
    return ^(NSString *idenfitier, NNThemeHandler handler) {
        __strong typeof(wSelf) self = wSelf;
        [self storeCustomHandler:handler identifier:idenfitier];
        return self;
    };
}

- (NNConfigMultiThemeCustomHandler)multiCustomHandler {
    
    __weak typeof(self) wSelf = self;
    return ^(NSArray<NSString *> *idenfitiers, NNThemeHandler handler) {
        __strong typeof(wSelf) self = wSelf;
        [idenfitiers execute:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self storeCustomHandler:handler identifier:obj];
        }];
        return self;
    };
}

- (NNConfigThemeKeyPathAndValue)keyPathAndValue {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, NSString *keyPath, id value) {
        __strong typeof(wSelf) self = wSelf;
        [self storeKeyPath:keyPath value:value identifier:identifier];
        return self;
    };
}

- (NNConfigThemeSelectorAndValues)selectorAndValues {
    
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, SEL sel, ...) {
        __strong typeof(wSelf) self = wSelf;
        NSMutableArray *array = [NSMutableArray array];
        va_list argsList;
        va_start(argsList, sel);
        id arg;
        while ((arg = va_arg(argsList, id))) {
            [array addObject:arg];
        }
        va_end(argsList);
        [self storeSelector:sel values:array.copy identifier:identifier];
        return self;
    };
}

- (NNConfigThemeSelectorAndArray)selectorAndArray {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, SEL sel, NSArray *values) {
        __strong typeof(wSelf) self = wSelf;
        [self storeSelector:sel values:values identifier:identifier];
        return self;
    };
}

- (NNConfigThemeSelectorAndColor)selectorAndColor {
    
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, SEL sel, id color) {
        __strong typeof(wSelf) self = wSelf;
        id value = color;
        if (![color isKindOfClass:[UIColor class]]) { value = NNColorString(color); }
        else { value = color; }
        [self storeSelector:sel values:value ? @[value] : nil identifier:identifier];
        return self;
    };
}

- (NNConfigThemeSelectorAndImage)selectorAndImage {
    
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, SEL sel, id image) {
        __strong typeof(wSelf) self = wSelf;
        id value;
        if ([image isKindOfClass:[UIImage class]]) { value = image; }
        else if ([image isKindOfClass:[NSString class]]) { value = [UIImage imageWithContentsOfFile:image]; }
        [self storeSelector:sel values:value ? @[value] : nil identifier:identifier];
        return self;
    };
}

- (NNThemeConfig *(^)(NSString *, NSString *))removeKeyPath {
    
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, NSString *keyPath) {
        __strong typeof(wSelf) self = wSelf;
        NSMutableDictionary *info = [self.keyPathConfigInfo safeObjectForKey:keyPath];
        if (info) [info removeObjectForKey:identifier];
        [self.keyPathConfigInfo setObject:info forKey:keyPath];
        return self;
    };
}

- (NNThemeConfig *(^)(NSString *, SEL sel))removeSelector {
    
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, SEL sel) {
        __strong typeof(wSelf) self = wSelf;
        NSMutableDictionary *info = [self.selectorConfigInfo safeObjectForKey:NSStringFromSelector(sel)];
        if (info) [info removeObjectForKey:identifier];
        [self.selectorConfigInfo setObject:info forKey:NSStringFromSelector(sel)];
        return self;
    };
}

- (NNThemeConfig *(^)(NSString *))removeConfigWithIdentifier {
    
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier) {
        __strong typeof(wSelf) self = wSelf;
        
        // keypaths
        for (id keyPath in self.keyPathConfigInfo.allKeys) {
            self.removeKeyPath(identifier, keyPath);
        }
        
        // selectors
        for (NSString *sel in self.selectorConfigInfo.allKeys) {
            self.removeSelector(identifier, NSSelectorFromString(sel));
        }
        
        //blocks
        [self.blockConfigInfo removeObjectForKey:identifier];
        return self;
    };
}

- (NNThemeConfig *(^)(NSString *))removeConfigWithKeyPath {
    __weak typeof(self) wSelf = self;
    return ^(NSString *keyPath) {
        __strong typeof(wSelf) self = wSelf;
        [self.keyPathConfigInfo removeObjectForKey:keyPath];
        return self;
    };
}

- (NNThemeConfig *(^)(SEL sel))removeConfigWithSelector {
    __weak typeof(self) wSelf = self;
    return ^(SEL sel) {
        __strong typeof(wSelf) self = wSelf;
        [self.selectorConfigInfo removeObjectForKey:NSStringFromSelector(sel)];
        return self;
    };
}

- (NNThemeConfig *(^)(void))removeConfigs {
    
    __weak typeof(self) wSelf = self;
    return ^(void) {
        __strong typeof(wSelf) self = wSelf;
        [self.blockConfigInfo removeAllObjects];
        [self.keyPathConfigInfo removeAllObjects];
        [self.selectorConfigInfo removeAllObjects];
        return self;
    };
}

/// ========================================
/// @name   Color
/// ========================================

- (NNConfigThemeColor)tintColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setTintColor:), color);
    };
}

- (NNConfigThemeColor)textColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setTextColor:), color);
    };
}

- (NNConfigThemeColor)fillColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setFillColor:), color);
    };
}

- (NNConfigThemeColor)strokeColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setStrokeColor:), color);
    };
}

- (NNConfigThemeColor)borderColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setBorderColor:), color);
    };
}

- (NNConfigThemeColor)shadowColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setShadowColor:), color);
    };
}

- (NNConfigThemeColor)onTintColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setOnTintColor:), color);
    };
}


- (NNConfigThemeColor)thumbTintColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setThumbTintColor:), color);
    };
}
- (NNConfigThemeColor)separatorColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setSeparatorColor:), color);
    };
}
- (NNConfigThemeColor)barTintColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setBarTintColor:), color);
    };
}

- (NNConfigThemeColor)backgroundColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setBackgroundColor:), color);
    };
}
- (NNConfigThemeColor)placeholderColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.keyPathAndValue(identifier, @"_placeholderLabel.textColor", color);
    };
}
- (NNConfigThemeColor)trackTintColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setTrackTintColor:), color);
    };
}

- (NNConfigThemeColor)progressTintColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setProgressTintColor:), color);
    };
}
- (NNConfigThemeColor)highlightTextColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setHighlightedTextColor:), color);
    };
}
- (NNConfigThemeColor)pageIndicatorTintColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setPageIndicatorTintColor:), color);
    };
}
- (NNConfigThemeColor)currentPageIndicatorTintColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndColor(identifier, @selector(setCurrentPageIndicatorTintColor:), color);
    };
}
- (NNConfigThemeColorAndState)buttonTitleColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color, UIControlState state){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValues(identifier, @selector(setTitleColor:forState:), color, @(state), nil);
    };
}
- (NNConfigThemeColorAndState)buttonTitleShadowColor {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id color, UIControlState state){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValues(identifier, @selector(setTitleShadowColor:forState:), color, @(state), nil);
    };
}

/// ========================================
/// @name   Image
/// ========================================

- (NNConfigThemeImage)image {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setImage:), image);
    };
}

- (NNConfigThemeImage)trackImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setTrackImage:), image);
    };
}

- (NNConfigThemeImage)progressImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setProgressImage:), image);
    };
}

- (NNConfigThemeImage)shadowImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setShadowImage:), image);
    };
}

- (NNConfigThemeImage)selectedImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setSelectedImage:), image);
    };
}

- (NNConfigThemeImage)backgroundImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setBackgroundImage:), image);
    };
}

- (NNConfigThemeImage)backIndicatorImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setBackIndicatorImage:), image);
    };
}

- (NNConfigThemeImage)backIndicatorTransitionMaskImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setBackIndicatorTransitionMaskImage:), image);
    };
}

- (NNConfigThemeImage)selectionIndicatorImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setSelectionIndicatorImage:), image);
    };
}

- (NNConfigThemeImage)scopeBarBackgroundImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndImage(identifier, @selector(setScopeBarBackgroundImage:), image);
    };
}

- (NNConfigThemeImageAndState)buttonImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image, UIControlState state){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValues(identifier, @selector(setImage:forState:), image, @(state), nil);
    };
}

- (NNConfigThemeImageAndState)buttonBackgroundImage {
    __weak typeof(self) wSelf = self;
    return ^(NSString *identifier, id image, UIControlState state){
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValues(identifier, @selector(setBackgroundImage:forState:), image, @(state), nil);
    };
}

@end


@implementation NNThemeConfig (NNThemeKey)


/// ========================================
/// @name   Basic
/// ========================================

- (NNThemeConfig *(^)(void))removeValueKey {
    __weak typeof(self) wSelf = self;
    return ^(void) {
        __strong typeof(wSelf) self = wSelf;
        [self.keyConfigInfo enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSMutableDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj.allKeys execute:^(NSString *storeKey, NSUInteger idx, BOOL * _Nonnull stop) {
                __strong typeof(wSelf) self = wSelf;
                if ([key integerValue] == NNConfigThemeKeyModeKeyPath) { self.removeKeyPathValueKey(storeKey); }
                else if ([key integerValue] == NNConfigThemeKeyModeSelector){ self.removeSelectorValueKey(NSSelectorFromString(storeKey)); }
            }];
        }];
        [self.keyConfigInfo removeAllObjects];
        return self;
    };
}

- (NNThemeConfig *(^)(NSString *, NSString *))keyPathAndValueKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *keyPath, NSString *valueKey) {
        NSAssert(keyPath.length, @"config keyPath should not be nil");
        __strong typeof(wSelf) self = wSelf;
        for (NSString *identifier in [NNTheme storedThemeIdentifiers]) {
            id value = [NNTheme valueWithThemeIdentifier:identifier key:valueKey];
            if (value) { self.keyPathAndValue(identifier, keyPath, value); }
        }
        NSMutableDictionary *info = [self.keyConfigInfo safeObjectForKey:@(NNConfigThemeKeyModeKeyPath)];
        if (!info) { info = [NSMutableDictionary dictionary]; };
        [info setObject:valueKey forKey:keyPath];
        [self.keyConfigInfo setObject:info forKey:@(NNConfigThemeKeyModeKeyPath)];
        return self;
    };
}

- (NNThemeConfig *(^)(SEL , NSString *))selectorAndValueKey {
    
    __weak typeof(self) wSelf = self;
    return ^(SEL sel, NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKeyArray(sel, @[[NSString stringWithThemeKey:valueKey]]);
    };
}

- (NNThemeConfig *(^)(SEL, NSArray *))selectorAndValueKeyArray {
    __weak typeof(self) wSelf = self;
    return ^(SEL sel, NSArray<__kindof NSString *> *valueKeyArray) {
        __strong typeof(wSelf) self = wSelf;
        NSAssert(sel, @"config selector should not be nil");
        for (NSString *identifier in [NNTheme storedThemeIdentifiers]) {
            
            NSArray *values = [[valueKeyArray map:^id _Nonnull(__kindof NSString * _Nonnull obj, NSInteger index) {
                return (obj.isValueKeyOfTheme ? [NNTheme valueWithThemeIdentifier:identifier key:obj] : obj) ? : [NSNull null];
            }] filter:^BOOL(__kindof NSString * _Nonnull obj) {
                return [obj isKindOfClass:[NSNull class]];
            }];
            if (values.count &&values.count == valueKeyArray.count) {  self.selectorAndArray(identifier, sel, values); }
        }
        NSMutableDictionary *info = [self.keyConfigInfo safeObjectForKey:@(NNConfigThemeKeyModeSelector)];
        if (!info) { info = [NSMutableDictionary dictionary]; };
        [info setObject:valueKeyArray ? : @[] forKey:NSStringFromSelector(sel)];
        [self.keyConfigInfo setObject:info forKey:@(NNConfigThemeKeyModeKeyPath)];
        return self;
    };
}

- (NNThemeConfig *(^)(NSString *))removeKeyPathValueKey {
    
    __weak typeof(self) wSelf = self;
    return ^(NSString *keyPath) {
        __strong typeof(wSelf) self = wSelf;
        NSMutableDictionary *info = [self.keyConfigInfo safeObjectForKey:@(NNConfigThemeKeyModeKeyPath)];
        if ([info.allKeys containsObject:keyPath]) {
            [[NNTheme storedThemeIdentifiers] execute:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = [NNTheme valueWithThemeIdentifier:obj key:[info safeObjectForKey:keyPath]];
                if (value) { self.removeKeyPath(obj, keyPath); };
            }];
            [info removeObjectForKey:keyPath];
        }
        if (info) { [self.keyConfigInfo setObject:info forKey:@(NNConfigThemeKeyModeKeyPath)]; };
        return self;
    };
}

- (NNThemeConfig *(^)(SEL))removeSelectorValueKey {
    
    __weak typeof(self) wSelf = self;
    return ^(SEL sel) {
        __strong typeof(wSelf) self = wSelf;
        NSMutableDictionary<NSString *, NSArray *> *info = [self.keyConfigInfo safeObjectForKey:@(NNConfigThemeKeyModeSelector)];
        if ([info.allKeys containsObject:NSStringFromSelector(sel)]) {
            [[NNTheme storedThemeIdentifiers] execute:^(NSString * _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
                __strong typeof(wSelf) self = wSelf;
                NSArray *valueKeyArray = [info safeObjectForKey:NSStringFromSelector(sel)];
                NSArray *values = [[valueKeyArray map:^id _Nonnull(__kindof NSString * _Nonnull key, NSInteger index) {
                    return (key.isValueKeyOfTheme ? [NNTheme valueWithThemeIdentifier:identifier key:key] : key) ? : [NSNull null];
                }] filter:^BOOL(__kindof NSString * _Nonnull obj) {
                    return [obj isKindOfClass:[NSNull class]];
                }];
                if (values.count && values.count == valueKeyArray.count) { self.removeSelector(identifier, sel); }
            }];
            [info removeObjectForKey:NSStringFromSelector(sel)];
        }
        if (info) { [self.keyConfigInfo setObject:info forKey:@(NNConfigThemeKeyModeSelector)]; };
        return self;
    };
}

/// ========================================
/// @name   Color
/// ========================================

- (NNConfigThemeKey)tintColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setTintColor:), valueKey);
    };
}

- (NNConfigThemeKey)textColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setTextColor:), valueKey);
    };
}

- (NNConfigThemeKey)fillColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setFillColor:), valueKey);
    };
}

- (NNConfigThemeKey)strokeColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setStrokeColor:), valueKey);
    };
}

- (NNConfigThemeKey)borderColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setBorderColor:), valueKey);
    };
}

- (NNConfigThemeKey)shadowColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setShadowColor:), valueKey);
    };
}

- (NNConfigThemeKey)onTintColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setOnTintColor:), valueKey);
    };
}

- (NNConfigThemeKey)thumbTintColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setThumbTintColor:), valueKey);
    };
}
- (NNConfigThemeKey)separatorColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setSeparatorColor:), valueKey);
    };
}

- (NNConfigThemeKey)barTintColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setBarTintColor:), valueKey);
    };
}

- (NNConfigThemeKey)backgroundColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setBackgroundColor:), valueKey);
    };
}

- (NNConfigThemeKey)placeholderColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.keyPathAndValueKey(@"_placeholderLabel.textColor", valueKey);
    };
}

- (NNConfigThemeKey)trackTintColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setTrackTintColor:), valueKey);
    };
}

- (NNConfigThemeKey)progressTintColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setProgressTintColor:), valueKey);
    };
}

- (NNConfigThemeKey)highlightTextColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setHighlightedTextColor:), valueKey);
    };
}

- (NNConfigThemeKey)pageIndicatorTintColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setPageIndicatorTintColor:), valueKey);
    };
}

- (NNConfigThemeKey)currentPageIndicatorTintColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setCurrentPageIndicatorTintColor:), valueKey);
    };
}

- (NNConfigThemeKeyAndState)buttonTitleColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey, UIControlState state) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKeyArray(@selector(setTitleColor:forState:), @[[NSString stringWithThemeKey:valueKey], @(state)]);
    };
}

- (NNConfigThemeKeyAndState)buttonTitleShadowColorKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey, UIControlState state) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKeyArray(@selector(setTitleShadowColor:forState:), @[[NSString stringWithThemeKey:valueKey], @(state)]);
    };
}


/// ========================================
/// @name   Image
/// ========================================

- (NNConfigThemeKey)imageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setImage:), valueKey);
    };
}

- (NNConfigThemeKey)trackImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setTrackImage:), valueKey);
    };
}

- (NNConfigThemeKey)progressImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setProgressImage:), valueKey);
    };
}

- (NNConfigThemeKey)shadowImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setShadowImage:), valueKey);
    };
}

- (NNConfigThemeKey)selectedImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setSelectedImage:), valueKey);
    };
}

- (NNConfigThemeKey)backgroundImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setBackgroundImage:), valueKey);
    };
}

- (NNConfigThemeKey)backIndicatorImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setBackIndicatorImage:), valueKey);
    };
}

- (NNConfigThemeKey)backIndicatorTransitionMaskImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setBackIndicatorTransitionMaskImage:), valueKey);
    };
}

- (NNConfigThemeKey)selectionIndicatorImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setSelectionIndicatorImage:), valueKey);
    };
}

- (NNConfigThemeKey)scopeBarBackgroundImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKey(@selector(setScopeBarBackgroundImage:), valueKey);
    };
}

- (NNConfigThemeKeyAndState)buttonImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey, UIControlState state) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKeyArray(@selector(setImage:forState:), @[[NSString stringWithThemeKey:valueKey], @(state)]);
    };
}

- (NNConfigThemeKeyAndState)buttonBackgroundImageKey {
    __weak typeof(self) wSelf = self;
    return ^(NSString *valueKey, UIControlState state) {
        __strong typeof(wSelf) self = wSelf;
        return self.selectorAndValueKeyArray(@selector(setBackgroundImage:forState:), @[[NSString stringWithThemeKey:valueKey], @(state)]);
    };
}

@end

@implementation NSObject (NNThemeConfig)
@dynamic themeConfig;

- (NNThemeConfig *)themeConfig {
    
    NNThemeConfig *config = objc_getAssociatedObject(self, @selector(themeConfig));
    if (!config) {
        NSAssert(![self isKindOfClass:[NNThemeConfig class]], @"should not using themeConfig for its self");
        config = [[NNThemeConfig alloc] init];
        __weak typeof(self) wSelf = self;
        config.updatingCurrentThemeHandler = ^{
            __strong typeof(wSelf) self = wSelf;
            [self updateThemeConfig];
        };
        objc_setAssociatedObject(self, @selector(themeConfig), config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeConfigChangedNotification:) name:kNNThemeChangedNotification object:nil];
    }
    return config;
}

@end

@implementation NSString (NNThemeKey)

+ (instancetype)stringWithThemeKey:(NSString *)key {
    
    NSString *ret = [NSString stringWithString:key];
    objc_setAssociatedObject(ret, @selector(isValueKeyOfTheme), @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return ret;
}

- (BOOL)isValueKeyOfTheme {
    
    id ret = objc_getAssociatedObject(self, @selector(isValueKeyOfTheme));
    if ([ret respondsToSelector:@selector(boolValue)]) return [ret boolValue];
    return NO;
}

@end
