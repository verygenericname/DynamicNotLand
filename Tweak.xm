#import <UIKit/UIKit.h>

@interface _SBGainMapView : UIView
@end

@interface _SBSystemApertureGainMapView : UIView
@end

%hook _SBGainMapView

- (void)layoutSubviews {
    %orig;

    static int changed = 0;
    if (changed == 3) return;
    changed += 1;

    // self.layer.disableUpdateMask |= 31;
    CGRect frame = self.frame;
    frame.origin.y = -48.3;
    self.frame = frame;
    // self.layer.opacity = 0.1;

    if (/*changed == 2 ||*/ changed == 3) {
        [self removeFromSuperview];
    }
}

- (void)setFrame:(CGRect)frame {
    if ([self.superview isMemberOfClass:%c(_SBSystemApertureGainMapView)]) {
        if (frame.size.width >= 127) {
            self.hidden = NO;
            if (frame.origin.y <= -48.3) {
                frame.origin.y = 0;
                [UIView performWithoutAnimation:^{
                    %orig(frame);
                }];
                return;
            }
        } else {
            self.hidden = YES;
            if (frame.origin.y <= 0) {
                frame.origin.y = -999;
                [UIView performWithoutAnimation:^{
                    %orig(frame);
                }];
                return;
            }
        }
        %orig(frame);
    } else {
        %orig(frame);
    }
}

%end

