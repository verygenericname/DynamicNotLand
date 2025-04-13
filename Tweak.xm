#import <UIKit/UIKit.h>

@interface _SBGainMapView : UIView
@end

@interface _SBSystemApertureGainMapView : UIView
@end

@interface _SBSystemApertureMagiciansCurtainView : UIView
@end

@interface SBFTouchPassThroughView : UIView
@end

@interface SBSystemApertureContainerView : UIView
@end

@interface CALayer(Undocumented)
@property(atomic, assign) NSUInteger disableUpdateMask;
@end


@interface FakeGainMapLayer : CALayer
@property (nonatomic, assign) NSString *renderMode;
@end

@implementation FakeGainMapLayer
@end

static UIView *targetGainMapView = nil;
static UIView *targetFrontGainMapView = nil;
static BOOL islandInUse = YES;
static BOOL backboarddMap = NO;

%group RegularHooks

%hook SpringBoard

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;

    UIWindow *rootWindow = nil;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:%c(SBRootSceneWindow)]) {
            rootWindow = window;
            break;
        }
    }

    if (!rootWindow) return;

    backboarddMap = YES;
    _SBGainMapView *gainMapView = [[_SBGainMapView alloc] initWithFrame:CGRectMake(-1.3, -0.9, 1, 1)];

    gainMapView.backgroundColor = nil;
    gainMapView.userInteractionEnabled = NO;
    gainMapView.layer.disableUpdateMask |= 18;

    [rootWindow addSubview:gainMapView];
    targetGainMapView.layer.opacity = 0.0;
}

%end

%hook SBSystemApertureController

- (void)systemApertureViewController:(id)vc containsAnyContent:(BOOL)contains {
    %orig;
    islandInUse = contains;
    if (contains == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            targetGainMapView.layer.opacity = 0.0;
            targetFrontGainMapView.layer.opacity = 0.0;
        }];
    } else {
        targetGainMapView.layer.opacity = 1.0;
        targetFrontGainMapView.layer.opacity = 1.0;
    }
}

%end

%hook SBSystemApertureViewController

+ (id)_sharedFeedbackGenerator {
    if (islandInUse == NO) {
        return nil;
    } else {
        return %orig;
    }
}

%end

%hook _SBGainMapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig(frame);
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews {
    %orig;
    static BOOL once = NO;
    if (once == NO) {
        if ([self.superview isMemberOfClass:%c(_SBSystemApertureGainMapView)]) {
            once = YES;
            targetGainMapView = self;
            CGAffineTransform transform = self.transform;
            transform.d = 1.01;
            self.transform = transform;
        }
    }
}

+ (Class)layerClass {
    if (backboarddMap == YES) {
        backboarddMap = NO;
        return %orig;
    }
    return [FakeGainMapLayer class];
}

%end

%hook _SBSystemApertureMagiciansCurtainView

- (void)layoutSubviews {
    [self removeFromSuperview];
}

%end

%hook SBSystemApertureContainerView

- (void)setFrame:(CGRect)frame {
    if (islandInUse == NO) {
        return;
    }
	%orig(frame);
}

%end

%end

%group KeepShadow

%hook SBFTouchPassThroughView

- (void)layoutSubviews {
    %orig;
    static BOOL once = NO;
    if (once == NO) {
        if (self.subviews.count == 4) {
            UIView *targetSubview2 = self.subviews[2];
            if ([targetSubview2 isKindOfClass:%c(UIView)]) {
                once = YES;
               targetFrontGainMapView = targetSubview2;
            }
        }
    }
}

%end

%end

%group NoShadow

%hook SBFTouchPassThroughView

- (void)layoutSubviews {
    %orig;
    static BOOL once = NO; 
    if (once == NO) {
        if (self.subviews.count == 4) {
            UIView *targetSubview = self.subviews[0];
            UIView *targetSubview2 = self.subviews[2];
            if ([targetSubview2 isKindOfClass:%c(UIView)]) {
                targetFrontGainMapView = targetSubview2;
            }
            if ([targetSubview isKindOfClass:%c(MTMaterialView)]) {
                once = YES;
                [targetSubview removeFromSuperview];
            }
        }
    }
}

%end

%hook SBSystemApertureContainerView

- (void)setShadowStyle:(NSInteger)arg1 {}

%end

%end

%ctor {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.nathan.dynamicnotland"];
    if ([prefs objectForKey:@"enabled"] ? [prefs boolForKey:@"enabled"] : YES) {
        %init(RegularHooks);
    }
    if ([prefs objectForKey:@"shadowDisabled"] ? [prefs boolForKey:@"shadowDisabled"] : NO) {
        %init(NoShadow);
    } else {
        %init(KeepShadow);
    }
}