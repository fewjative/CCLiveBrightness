#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>

@interface CCLiveBrightnessSettingsListController: PSListController {
}
@end

@interface ViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@end

@implementation CCLiveBrightnessSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"CCLiveBrightnessSettings" target:self] retain];
	}
	return _specifiers;

}

-(void)twitter {

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/Fewjative"]];

}

@end
