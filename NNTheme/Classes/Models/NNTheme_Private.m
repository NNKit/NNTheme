//
//  NNTheme_Private.m
//  NNTheme
//
//  Created by XMFraker on 2017/11/21.
//

#import "NNTheme_Private.h"
#import <NNCore/NNCore.h>

@implementation NNTheme (NNTheme_Private)

+ (instancetype)globalTheme {
    
    static id theme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theme = [[[self class] alloc] init];
    });
    return theme;
}

+ (NSUserDefaults *)themeDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:@"NNTheme"] ? : [NSUserDefaults standardUserDefaults];
}

+ (void)storeIdentifier:(NSString *)identifier {
    if (![[NNTheme globalTheme].storedThemeIdentifiers containsObject:identifier]) {
        [[NNTheme globalTheme].storedThemeIdentifiers addObject:identifier];
        [self storeObjectUsingThemeDefaults:[NNTheme globalTheme].storedThemeIdentifiers forKey:kNNStoredThemeIdentifiersKey];
    }
}

+ (void)removeIdentifier:(NSString *)identifier {
    
    if ([[NNTheme globalTheme].storedThemeIdentifiers containsObject:identifier]) {
        [[NNTheme globalTheme].storedThemeIdentifiers removeObject:identifier];
        [self storeObjectUsingThemeDefaults:[NNTheme globalTheme].storedThemeIdentifiers forKey:kNNStoredThemeIdentifiersKey];
    }
}

+ (id)storedObjectUsingThemeDefaultsForKey:(NSString *)key {
    return [[NNTheme themeDefaults] objectForKey:key];
}

+ (void)storeObjectUsingThemeDefaults:(nullable id)object forKey:(NSString *)key {
    
    [[NNTheme themeDefaults] setObject:object forKey:key];
    [[NNTheme themeDefaults] synchronize];
}

@end


@implementation NNTheme (NNTheme_JSONPrivate)

+ (id)valueWithThemeIdentifier:(NSString *)identifier key:(NSString *)key {
    
    NSAssert(identifier, @"theme identifier should not be nil");
    NSAssert(key, @"theme value key should not be nil");
    id value = nil;
    
    NSDictionary *themeInfo = [[[NNTheme storedThemeInfos] safeObjectForKey:identifier] safeObjectForKey:@"info"];
    
    // get color info
    NSString *colorHexString = [[themeInfo safeObjectForKey:@"color"] safeObjectForKey:key];
    if (colorHexString.length) { value = NNColorString(colorHexString); }
    if (value) { return value; }

    // get image info
    NSString *imageName = [[themeInfo safeObjectForKey:@"image"] safeObjectForKey:key];
    if (imageName.length) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = [[[NNTheme storedThemeInfos] safeObjectForKey:identifier] safeObjectForKey:@"path"];
        if (path.length) { path = [documentPath stringByAppendingPathComponent:path]; }
        UIImage *image = path ? [UIImage imageWithContentsOfFile:path] : [UIImage imageNamed:imageName];
        if (!image) { image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:imageName]]; }
        if (!image) { image = [UIImage imageNamed:imageName]; }
        else value = image;
    }
    if (value) { return value; }
    
    // get other info
    if (!value) { value = [[themeInfo safeObjectForKey:@"other"] safeObjectForKey:key]; }
    return value;
}

@end


@implementation NNThemeConfig (NNTheme_Private)

- (void)storeCustomHandler:(NNThemeHandler)handler identifier:(NSString *)identifier {
    
    [NNTheme storeIdentifier:identifier];
    NSMutableDictionary *info = [self.blockConfigInfo safeObjectForKey:identifier];
    if (!info) {  info = [NSMutableDictionary dictionary]; };
    [info setObject:[NSNull null] forKey:handler];
    [self.blockConfigInfo setObject:info forKey:identifier];
    [self updateThemeAfterThemeConfiged:identifier];
}

- (void)storeKeyPath:(NSString *)keyPath value:(id)value identifier:(NSString *)identifier {
    NSAssert(keyPath && value && identifier, @"store keyPath params invalid");
    [NNTheme storeIdentifier:identifier];
    NSMutableDictionary *info = [self.keyPathConfigInfo safeObjectForKey:identifier];
    if (!info) {  info = [NSMutableDictionary dictionary]; };
    [info setObject:value forKey:keyPath];
    [self.keyPathConfigInfo setObject:info forKey:keyPath];
    [self updateThemeAfterThemeConfiged:identifier];
}

- (void)storeSelector:(SEL)sel values:(NSArray *)values  identifier:(NSString *)identifier {
    NSAssert(sel && identifier, @"store selector params invalid");
    [NNTheme storeIdentifier:identifier];
    NSMutableDictionary *info = [self.selectorConfigInfo safeObjectForKey:identifier];
    if (!info) { info = [NSMutableDictionary dictionary]; };
    [info setObject:values forKey:NSStringFromSelector(sel)];
    [self.selectorConfigInfo setObject:info forKey:identifier];
    [self updateThemeAfterThemeConfiged:identifier];
}

- (void)handleThemeConfigRemovedNotification:(NSNotification *)notification {
    
    NSString *identifier = [notification.userInfo safeObjectForKey:@"identifier"];
    NSAssert(identifier.length, @"identifier should not be nil");
    self.removeConfigWithIdentifier(identifier);
}

- (void)handleThemeConfigStoredNotification:(NSNotification *)notification {
    
    NSString *identifier = [notification.userInfo safeObjectForKey:@"identifier"];
    NSAssert(identifier.length, @"identifier should not be nil");
    
    NSDictionary *keyPathInfo = [self.keyConfigInfo safeObjectForKey:@(NNConfigThemeKeyModeKeyPath)];
    [keyPathInfo enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, NSString *valueKey, BOOL * _Nonnull stop) {
        id value = [NNTheme valueWithThemeIdentifier:identifier key:valueKey];
        if (value) { self.keyPathAndValue(identifier, keyPath, value); }
    }];
    
    NSDictionary *selectorInfo = [self.keyConfigInfo safeObjectForKey:@(NNConfigThemeKeyModeSelector)];
    [selectorInfo enumerateKeysAndObjectsUsingBlock:^(NSString *sel, NSArray *vauleKeys, BOOL * _Nonnull stop) {
        NSArray *values = [[vauleKeys map:^id _Nonnull(__kindof NSString * _Nonnull obj, NSInteger index) {
            return (obj.isValueKeyOfTheme ? [NNTheme valueWithThemeIdentifier:identifier key:obj] : obj) ? : [NSNull null];
        }] filter:^BOOL(__kindof NSString * _Nonnull obj) {
            return [obj isKindOfClass:[NSNull class]];
        }];
        if (values.count && values.count == vauleKeys.count) {  self.selectorAndArray(identifier, NSSelectorFromString(sel), values); }
    }];
}

- (void)updateThemeAfterThemeConfiged:(NSString *)identifier {
    
    if ([identifier isEqualToString:[NNTheme usingThemeIdentifier]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.updatingCurrentThemeHandler) { self.updatingCurrentThemeHandler(); }
        });
    }
}

@end


@implementation NSObject (NNThemeConfig_Private)

+ (void)load {
    
    NNSwizzleMethod([self class],
                    NSSelectorFromString(@"dealloc"),
                    [self class],
                    @selector(theme_dealloc));
}

- (void)theme_dealloc {
    
    if (objc_getAssociatedObject(self, @selector(themeConfig)) != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNNThemeChangedNotification object:nil];
        objc_removeAssociatedObjects(self);
    }
    [self theme_dealloc];
}

#pragma mark - Public Methods

- (void)handleThemeConfigChangedNotification:(NSNotification *)notification {
    
    if (self.isUsingThemeConfigChanged) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.themeConfig.currentThemeChangingHandler) { self.themeConfig.currentThemeChangingHandler([NNTheme usingThemeIdentifier], self); }
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self updateThemeConfig];
            [CATransaction commit];
        });
    }
}

#pragma mark - Private Methods

- (void)updateThemeConfig {
    
    NSString *identifier = self.themeConfig.usingThemeIdentifier = [NNTheme usingThemeIdentifier];
    // update block
    NSDictionary *blockInfos = [self.themeConfig.blockConfigInfo safeObjectForKey:identifier];
    for (id block in blockInfos.allKeys) {
        id value = [blockInfos safeObjectForKey:block];
        if ([value isKindOfClass:[NSNull class]]) { ((NNThemeHandler)block)(self); }
        else { ((NNThemeValueHandler)block)(self, value); }
    }
    
    // update keypath
    NSDictionary *keyPathInfos = [self.themeConfig.keyPathConfigInfo safeObjectForKey:identifier];
    for (id keyPath in keyPathInfos.allKeys) {
        if ([keyPath isKindOfClass:[NSString class]]) {
            [self setValue:[keyPathInfos safeObjectForKey:keyPath] forKey:keyPath];
        }
    }
    
    // update SEL
    NSDictionary *selectorInfos = [self.themeConfig.selectorConfigInfo safeObjectForKey:identifier];
    for (NSString *selector in selectorInfos.allKeys) {
        NSArray *values = [selectorInfos safeObjectForKey:selector];
        
        SEL sel = NSSelectorFromString(selector);
        
        NSMethodSignature *signature = [self methodSignatureForSelector:sel];
        if (!signature) [self doesNotRecognizeSelector:sel];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        if (!invocation) [self doesNotRecognizeSelector:sel];
        
        [invocation setTarget:self];
        [invocation setSelector:sel];
        
        if (signature.numberOfArguments == (values.count + 2)) {
            __block BOOL suc = YES;
            [values execute:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                suc = suc && [self configInvocation:invocation argument:obj index:(idx + 2)];
            }];
            if (suc) { [invocation invoke]; }
        } else {
            NSAssert(NO, @"SEL :%@ arguments is not same", selector);
        }
    }
}

- (BOOL)configInvocation:(NSInvocation *)invocation argument:(id)argument index:(NSUInteger)index {
    
    if (invocation.methodSignature.numberOfArguments <= index) return NO;
    char *type = (char *)[invocation.methodSignature getArgumentTypeAtIndex:index];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
    BOOL unsupportedType = NO;
    switch (*type) {
        case 'v': // 1: void
        case 'B': // 1: bool
        case 'c': // 1: char / BOOL
        case 'C': // 1: unsigned char
        case 's': // 2: short
        case 'S': // 2: unsigned short
        case 'i': // 4: int / NSInteger(32bit)
        case 'I': // 4: unsigned int / NSUInteger(32bit)
        case 'l': // 4: long(32bit)
        case 'L': // 4: unsigned long(32bit)
        { // 'char' and 'short' will be promoted to 'int'.
            int value = [argument intValue];
            [invocation setArgument:&value atIndex:index];
        } break;
            
        case 'q': // 8: long long / long(64bit) / NSInteger(64bit)
        case 'Q': // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
        {
            long long value = [argument longLongValue];
            [invocation setArgument:&value atIndex:index];
        } break;
            
        case 'f': // 4: float / CGFloat(32bit)
        { // 'float' will be promoted to 'double'.
            double value = [argument doubleValue];
            float valuef = value;
            [invocation setArgument:&valuef atIndex:index];
        } break;
            
        case 'd': // 8: double / CGFloat(64bit)
        {
            double value = [argument doubleValue];
            [invocation setArgument:&value atIndex:index];
        } break;
            
        case '*': // char *
        case '^': // pointer
        {
            if ([argument isKindOfClass:UIColor.class]) argument = (id)[argument CGColor]; //CGColor转换
            if ([argument isKindOfClass:UIImage.class]) argument = (id)[argument CGImage]; //CGImage转换
            void *value = (__bridge void *)argument;
            [invocation setArgument:&value atIndex:index];
        } break;
            
        case '@': // id
        {
            [invocation setArgument:&argument atIndex:index];
        } break;
            
        case '{': // struct
        {
            if (strcmp(type, @encode(CGPoint)) == 0) {
                CGPoint value = [argument CGPointValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGSize)) == 0) {
                CGSize value = [argument CGSizeValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGRect)) == 0) {
                CGRect value = [argument CGRectValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGVector)) == 0) {
                CGVector value = [argument CGVectorValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                CGAffineTransform value = [argument CGAffineTransformValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                CATransform3D value = [argument CATransform3DValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(NSRange)) == 0) {
                NSRange value = [argument rangeValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(UIOffset)) == 0) {
                UIOffset value = [argument UIOffsetValue];
                [invocation setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                UIEdgeInsets value = [argument UIEdgeInsetsValue];
                [invocation setArgument:&value atIndex:index];
            } else {
                unsupportedType = YES;
            }
        } break;
            
        case '(': // union
        case '[': // array
        default: // what?!
            unsupportedType = YES;
            break;
    }
    
    NSAssert(unsupportedType == NO, @"method :%@ unsupport argument :%@", invocation.methodSignature ,argument);
    return (unsupportedType == NO);
}

#pragma mark - Getter

- (BOOL)isUsingThemeConfigChanged {
    return !self.themeConfig.usingThemeIdentifier || ![self.themeConfig.usingThemeIdentifier isEqualToString:[NNTheme usingThemeIdentifier]];
}

@end
