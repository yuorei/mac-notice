#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static NSString *_fakeBundleIdentifier = nil;

@implementation NSBundle (FakeIdentifier)

- (NSString *)__bundleIdentifier {
    if (self == [NSBundle mainBundle]) {
        return _fakeBundleIdentifier ?: [self __bundleIdentifier];
    }
    return [self __bundleIdentifier];
}

@end

void InstallFakeBundleIdentifierHook(NSString *fakeBundleID) {
    _fakeBundleIdentifier = [fakeBundleID copy];
    Class class = objc_getClass("NSBundle");
    method_exchangeImplementations(
        class_getInstanceMethod(class, @selector(bundleIdentifier)),
        class_getInstanceMethod(class, @selector(__bundleIdentifier))
    );
}
