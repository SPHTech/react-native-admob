#import "RNGADBannerView.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>
#else
#import "RCTBridgeModule.h"
#import "UIView+React.h"
#import "RCTLog.h"
#endif

@implementation RNGADBannerView
{
    GADBannerView *_bannerView;
}

- (void)dealloc
{
    _bannerView.delegate = nil;
    _bannerView.adSizeDelegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        super.backgroundColor = [UIColor clearColor];
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootViewController = [keyWindow rootViewController];
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
        _bannerView.delegate = self;
        // TODO: removed because currently not using fluid ad sizes, should add back later
        // _bannerView.adSizeDelegate = self;
        _bannerView.rootViewController = rootViewController;
        [self addSubview:_bannerView];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    RCTLogError(@"RNGADBannerView cannot have subviews");
}
#pragma clang diagnostic pop

- (void)loadBanner
{
    // TODO: Size is fixed right now, need to enable fuild size later
    // if(self.onSizeChange) {
    //     //CGSize size = CGSizeFromGADAdSize(_bannerView.adSize);//sometimes comes as 300x249 issue
    //     CGSize size = CGSizeMake(300.0f, 250.0f);
    //     if(!CGSizeEqualToSize(size, self.bounds.size)) {
    //         self.onSizeChange(@{
    //                             @"width": @(300.0f),
    //                             @"height": @(250.0f)
    //                             });
    //     }
    // }
    GADRequest *request = [GADRequest request];
    request.testDevices = _testDevices;
    [_bannerView loadRequest:request];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

# pragma mark GADBannerViewDelegate

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(__unused GADBannerView *)adView
{
    if (self.onSizeChange) {
        //        self.onSizeChange(@{
        //                            @"width": @(adView.frame.size.width),
        //                            @"height": @(adView.frame.size.height) });
        self.onSizeChange(@{
                            @"width": @(300.0),
                            @"height": @(250.0) });
    }

    if (self.onAdLoaded) {
        self.onAdLoaded(@{});
    }
}

/// Tells the delegate an ad request failed.
- (void)adView:(__unused GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (self.onAdFailedToLoad) {
        self.onAdFailedToLoad(@{ @"error": @{ @"message": [error localizedDescription] } });
    }
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(__unused GADBannerView *)adView
{
    if (self.onAdOpened) {
        self.onAdOpened(@{});
    }
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(__unused GADBannerView *)adView
{
    if (self.onAdClosed) {
        self.onAdClosed(@{});
    }
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(__unused GADBannerView *)adView
{
    if (self.onAdLeftApplication) {
        self.onAdLeftApplication(@{});
    }
}

# pragma mark GADAdSizeDelegate

- (void)adView:(__unused GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size
{
    CGSize adSize = CGSizeFromGADAdSize(size);
    self.onSizeChange(@{
                              @"width": @(adSize.width),
                              @"height": @(adSize.height) });
}

- (void)reactSetFrame:(CGRect)frame {
    _bannerView.frame = CGRectMake(frame.origin.x, frame.origin.y, 300.0, 250.0);
}

@end
