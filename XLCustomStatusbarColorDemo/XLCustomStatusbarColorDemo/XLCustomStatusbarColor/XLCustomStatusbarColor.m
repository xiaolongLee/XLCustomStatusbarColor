//
//  XLCustomStatusbarColor.m
//  XLCustomStatusbarColorDemo
//
//  Created by Mac-Qke on 2019/1/9.
//  Copyright © 2019 Mac-Qke. All rights reserved.
//

#import "XLCustomStatusbarColor.h"
#import <objc/runtime.h>

#define XLSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while(0)

__attribute__((constructor))
static void resetPreferredStatusBarStyle(void) {
    [[NSBundle mainBundle].infoDictionary setValue:@(YES) forKey:@"UIViewControllerBasedStatusBarAppearance"];
}

@interface UIImage (XLStatusbarIconColor)

- (UIImage *)xl_imageWithColor:(UIColor *)color;

@end

@implementation UIImage (XLStatusbarIconColor)

- (UIImage *)xl_imageWithColor:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end



id xl_imageHook(id self, SEL _cmd, UIImage *image, UIImage *shadowImage) {
    UIColor *color = objc_getAssociatedObject([XLCustomStatusbarColor class], @"xl_statusbarIconColor");
    if (color) {
        image = [image xl_imageWithColor:color];
        shadowImage = [shadowImage xl_imageWithColor:color];
    }
    
    XLSuppressPerformSelectorLeakWarning(id obj = [self performSelector:NSSelectorFromString(@"xl_imageFromImage:withShadowImage:") withObject:image withObject:shadowImage];
                                         return  obj;
                                         );
}

id xl__accessoryImage(id self, SEL _cmd) {
    
    UIImage *image;
    XLSuppressPerformSelectorLeakWarning(image = [self performSelector:NSSelectorFromString(@"xl__accessoryImage")];
                                         );
    UIColor *color = objc_getAssociatedObject([XLCustomStatusbarColor class], @"xl_statusbarIconColor");
    if (color) {
        image = [image xl_imageWithColor:color];
    }
    
    return image;
}

UIColor *xl_tintColor(id self, SEL _cmd) {
    UIColor *color = objc_getAssociatedObject([XLCustomStatusbarColor class], @"xl_statusbarIconColor");
    if (color) {
        return color;
    }
    XLSuppressPerformSelectorLeakWarning(return [self performSelector:NSSelectorFromString(@"xl_tintColor")];
                                         );
}

void xl_setStatusBarStyle(id self, SEL _cmd, NSInteger arg1, id arg2) {
    objc_setAssociatedObject([UIViewController class], @"xl_preferredStatusBarStyle", @(arg1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    XLSuppressPerformSelectorLeakWarning([self performSelector:NSSelectorFromString(@"xl_setStatusBarStyle:animationParameters:") withObject:@(arg1) withObject:arg2];
                                         );
    
}

@implementation XLCustomStatusbarColor
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Method  m = class_getClassMethod(NSClassFromString(@"_UILegibilityImageSet"), NSSelectorFromString(@"imageFromImage:withShadowImage:"));
        
        class_addMethod(object_getClass((id)NSClassFromString(@"_UILegibilityImageSet")), NSSelectorFromString(@"xl_imageFromImage:withShadowImage:"), (IMP)xl_imageHook, method_getTypeEncoding(m));
        
        Method m1 = class_getClassMethod(NSClassFromString(@"_UILegibilityImageSet"),NSSelectorFromString(@"imageFromImage:withShadowImage:"));
        Method m2 = class_getClassMethod(NSClassFromString(@"_UILegibilityImageSet"), NSSelectorFromString(@"xl_imageFromImage:withShadowImage:"));
        method_exchangeImplementations(m1,m2);
        
        //
        m = class_getInstanceMethod(NSClassFromString(@"UIStatusBarBatteryItemView"), NSSelectorFromString(@"_accessoryImage"));
        
        class_addMethod(NSClassFromString(@"UIStatusBarBatteryItemView"), NSSelectorFromString(@"xl__accessoryImage"), (IMP)xl__accessoryImage, method_getTypeEncoding(m));
        
        m1 = class_getInstanceMethod(NSClassFromString(@"UIStatusBarBatteryItemView"),NSSelectorFromString(@"_accessoryImage"));
        m2 = class_getInstanceMethod(NSClassFromString(@"UIStatusBarBatteryItemView"), NSSelectorFromString(@"xl__accessoryImage"));
        method_exchangeImplementations(m1,m2);
        
        //
        m = class_getInstanceMethod(NSClassFromString(@"UIStatusBarForegroundStyleAttributes"), NSSelectorFromString(@"tintColor"));
        
        class_addMethod(NSClassFromString(@"UIStatusBarForegroundStyleAttributes"), NSSelectorFromString(@"xl_tintColor"), (IMP)xl_tintColor, method_getTypeEncoding(m));
        
        m1 = class_getInstanceMethod(NSClassFromString(@"UIStatusBarForegroundStyleAttributes"),NSSelectorFromString(@"tintColor"));
        m2 = class_getInstanceMethod(NSClassFromString(@"UIStatusBarForegroundStyleAttributes"), NSSelectorFromString(@"xl_tintColor"));
        method_exchangeImplementations(m1,m2);
        
        //
        //
        m = class_getInstanceMethod(NSClassFromString(@"UIApplication"), NSSelectorFromString(@"setStatusBarStyle:animationParameters:"));
        
        class_addMethod(NSClassFromString(@"UIApplication"), NSSelectorFromString(@"xl_setStatusBarStyle:animationParameters:"), (IMP)xl_setStatusBarStyle, method_getTypeEncoding(m));
        
        m1 = class_getInstanceMethod(NSClassFromString(@"UIApplication"),NSSelectorFromString(@"setStatusBarStyle:animationParameters:"));
        m2 = class_getInstanceMethod(NSClassFromString(@"UIApplication"), NSSelectorFromString(@"xl_setStatusBarStyle:animationParameters:"));
        method_exchangeImplementations(m1,m2);
    });
    
   
}

+ (void)updateStatusbarIconColor:(UIColor *)color {
    objc_setAssociatedObject([self class], @"xl_statusbarIconColor", color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSInteger style = [objc_getAssociatedObject([UIViewController class], @"xl_preferredStatusBarStyle") integerValue];
    
    objc_setAssociatedObject([UIViewController class], @"xl_preferredStatusBarStyle",@(labs(1 - style)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[UIApplication sharedApplication].keyWindow.rootViewController setNeedsStatusBarAppearanceUpdate];
}
@end


@interface UIViewController (StatusBarColor)
@end
@interface UINavigationController (StatusBarColor)
@end

@implementation UIViewController (StatusBarColor)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return  [objc_getAssociatedObject([UIViewController class], @"xl_preferredStatusBarStyle") integerValue];
}

@end

@implementation UINavigationController (StatusBarColor)

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

@end
