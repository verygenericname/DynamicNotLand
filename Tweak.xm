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

@interface CALayer()
@property(atomic, assign) NSUInteger disableUpdateMask;
@end

static UIView *targetGainMapView = nil;

%group regularHooks

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

    _SBGainMapView *gainMapView = [[_SBGainMapView alloc] initWithFrame:CGRectMake(-1.3, -0.9, 1, 1)];

    gainMapView.backgroundColor = nil;
    gainMapView.userInteractionEnabled = NO;
    gainMapView.layer.disableUpdateMask |= 18;

    [rootWindow addSubview:gainMapView];
    targetGainMapView.layer.disableUpdateMask |= 31;
}

%end

BOOL islandInUse;
%hook SBSystemApertureController
- (void)systemApertureViewController:(id)vc containsAnyContent:(BOOL)contains {
    %orig;
    islandInUse = contains;
    if (contains == NO) {
        targetGainMapView.layer.disableUpdateMask |= 31;
    } else {
        targetGainMapView.layer.disableUpdateMask &= ~31;
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

- (void)layoutSubviews {
    %orig;

    static int changed = 0;
    if (changed == 3) return;
    changed += 1;

    if ([self.superview isMemberOfClass:%c(_SBSystemApertureMagiciansCurtainView)]) {
        [self removeFromSuperview];
    }
    if ([self.superview isMemberOfClass:%c(_SBSystemApertureGainMapView)]) {
        targetGainMapView = self;
    }
}
%end

%end

%group shadow

%hook SBFTouchPassThroughView

- (void)layoutSubviews {
    %orig;
    static BOOL once = NO; 
    if (once == NO) {
        if (self.subviews.count == 4) {
            UIView *targetSubview = self.subviews[0];
            if ([targetSubview isKindOfClass:%c(MTMaterialView)]) {
                once = YES;
                [targetSubview removeFromSuperview];
            }
        }
    }
}

%end

%hook SBSystemApertureContainerView

- (void)setShadowStyle:(NSInteger)arg1 {
    //
}

%end

%end

%ctor {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.nathan.dynamicnotland"];
    if ([prefs objectForKey:@"enabled"] ? [prefs boolForKey:@"enabled"] : YES) {
        %init(regularHooks);
    }
    if ([prefs objectForKey:@"shadowDisabled"] ? [prefs boolForKey:@"shadowDisabled"] : NO) {
        %init(shadow);
    }
}