#import <UIKit/UIKit.h>
#import <substrate.h>

#define SYS_VER_GREAT_OR_EQUAL(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:64] != NSOrderedAscending)

static BOOL enableTweak = NO;
static BOOL autoCloseCC = NO;
static BOOL disableTint = NO;
static BOOL showSlider = NO;

%hook SBControlCenterContainerView

-(void)_updateDarkeningFrame
{
	if(enableTweak)
	{
		%orig;
		UIView * darkeningView = MSHookIvar<UIView*>(self,"_darkeningView");

		if(disableTint)
		{	
			darkeningView.alpha = 0.01;
			return;
		}
		else
		{
			darkeningView.alpha = 1;
			return;
		}
	}
	else
	{
		%orig;
		UIView * darkeningView = MSHookIvar<UIView*>(self,"_darkeningView");
		darkeningView.alpha = 1;
	}
}

%end

%hook SBCCBrightnessSectionController

-(void)_sliderDidBeginTracking:(id)var
{
	%orig;
	if(enableTweak)
	{
		UIViewController * parent = MSHookIvar<UIViewController*>(self,"_parentViewController");
		UIView * parentView = [parent view];
		NSLog(@"parentView: %@",parentView);

		if(showSlider)
		{
			UIView * sbcccv = MSHookIvar<UIView*>(parentView,"_contentContainerView");
			CALayer * maskLayer = [CALayer layer];
			maskLayer.backgroundColor = [UIColor blackColor].CGColor;
			maskLayer.frame = CGRectMake([self view].frame.origin.x,[self view].frame.origin.y,[self view].frame.size.width,[self view].frame.size.height);
			NSLog(@"mask: %@",maskLayer);
			sbcccv.layer.mask = maskLayer;

			if(!SYS_VER_GREAT_OR_EQUAL(@"8.0"))
			{
				//iOS7
				NSLog(@"disableTint fix for iOS7");
				if(!disableTint)
				{
					UIView * darkeningView = MSHookIvar<UIView*>(parentView,"_darkeningView");
					darkeningView.alpha = 0.01;
				}
			}
		}
		else
		{
			UIView * sbcv = [parentView _rootView];
			[UIView beginAnimations:nil context:NULL];
			sbcv.hidden = YES;
			[UIView commitAnimations];
		}
	}
}

-(void)_sliderDidEndTracking:(id)var
{
	%orig;
	if(enableTweak)
	{
		UIViewController * parent = MSHookIvar<UIViewController*>(self,"_parentViewController");
		UIView * parentView = [parent view];
		NSLog(@"parentView: %@",parentView);

		if(showSlider)
		{
			UIView * sbcccv = MSHookIvar<UIView*>(parentView,"_contentContainerView");
			sbcccv.layer.mask = nil;

			if(!SYS_VER_GREAT_OR_EQUAL(@"8.0"))
			{
				//iOS7
				NSLog(@"disableTint fix for iOS7");
				if(!disableTint)
				{
					UIView * darkeningView = MSHookIvar<UIView*>(parentView,"_darkeningView");
					darkeningView.alpha = 1;
				}
			}
		}
		else
		{
			UIView * sbcv = [parentView _rootView];
			[UIView beginAnimations:nil context:NULL];
			sbcv.hidden = NO;
			[UIView commitAnimations];
		}

		if(autoCloseCC)
		{
			[[%c(SpringBoard) sharedApplication] _runControlCenterDismissTest];
		}
	}
}

%end

static void loadPrefs() 
{
	NSLog(@"Loading CCLiveBrightness prefs");
    CFPreferencesAppSynchronize(CFSTR("com.joshdoctors.cclivebrightness"));

    enableTweak = !CFPreferencesCopyAppValue(CFSTR("enableTweak"), CFSTR("com.joshdoctors.cclivebrightness")) ? NO : [(id)CFPreferencesCopyAppValue(CFSTR("enableTweak"), CFSTR("com.joshdoctors.cclivebrightness")) boolValue];
    autoCloseCC = !CFPreferencesCopyAppValue(CFSTR("autoCloseCC"), CFSTR("com.joshdoctors.cclivebrightness")) ? NO : [(id)CFPreferencesCopyAppValue(CFSTR("autoCloseCC"), CFSTR("com.joshdoctors.cclivebrightness")) boolValue];
    disableTint = !CFPreferencesCopyAppValue(CFSTR("disableTint"), CFSTR("com.joshdoctors.cclivebrightness")) ? NO : [(id)CFPreferencesCopyAppValue(CFSTR("disableTint"), CFSTR("com.joshdoctors.cclivebrightness")) boolValue];
    showSlider = !CFPreferencesCopyAppValue(CFSTR("showSlider"), CFSTR("com.joshdoctors.cclivebrightness")) ? NO : [(id)CFPreferencesCopyAppValue(CFSTR("showSlider"), CFSTR("com.joshdoctors.cclivebrightness")) boolValue];

    if (enableTweak) {
        NSLog(@"[CCLiveBrightness] We are enabled");
    } else {
        NSLog(@"[CCLiveBrightness] We are NOT enabled");
    }
}

%ctor
{
	NSLog(@"Loading CCLiveBrightness");
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                (CFNotificationCallback)loadPrefs,
                                CFSTR("com.joshdoctors.cclivebrightness/settingschanged"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
	loadPrefs();
}