#import <CoreLocation/CoreLocation.h>

@interface T1AppDelegate

-(void)decideColorPalette;
-(void)configureColorPalette;
-(void)getLocationAndSuntime;
-(void)getSuntimeForLocation:(CLLocation *)location;

@end

@interface TFNTwitterColorSettings : NSObject

+(id)sharedSettings;
-(void)applyCurrentColorPalette;

@end