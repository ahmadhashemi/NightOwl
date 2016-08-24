
#import <CoreLocation/CoreLocation.h>

%hook T1AppDelegate

CLLocationManager *locationManager;
CLLocation *userLocation;

- (void)configureColorPalette {

NSDate *sunrise = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sunrise"];
NSDate *sunset = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sunset"];

if (sunrise && sunset) {

NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
formatter.dateFormat = @"H";

NSInteger nowHour = [[formatter stringFromDate:[[NSDate alloc] init]] integerValue];
NSInteger sunriseHour = [[formatter stringFromDate:sunrise] integerValue];
NSInteger sunsetHour = [[formatter stringFromDate:sunset] integerValue];

// NSLog(@"NOWHOUR: %li",(long)nowHour);
// NSLog(@"SUNRISEHOUR: %li",(long)sunriseHour);
// NSLog(@"SUNSETHOUR: %li",(long)sunsetHour);

NSString *palette;

if (nowHour > sunsetHour || nowHour < sunriseHour) {
palette = @"dark";
} else {
palette = @"standard";
}

// NSLog(@"SELECTEDPALETTE: %@",palette);
[[NSUserDefaults standardUserDefaults] setObject:palette forKey:@"TFNTwitterColorSettings.colorPaletteName"];
// [[NSUserDefaults standardUserDefaults] setObject:@"dark" forKey:@"TFNTwitterColorSettings.colorPaletteName"];
	
} else {
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = (id)self;
	locationManager.distanceFilter = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	[locationManager requestWhenInUseAuthorization];
	
	[locationManager startUpdatingLocation];
	
}

%orig;

// 
// id sharedSettings = [%c(TFNTwitterColorSettings) performSelector:@selector(sharedSettings)];
// NSArray *available = [sharedSettings performSelector:@selector(availableColorPalettes)];
// id current = [sharedSettings performSelector:@selector(currentColorPalette)];
	// 
	// current = available[1];
	// 
	// [sharedSettings performSelector:@selector(applyCurrentColorPalette)];
	
}

%new(v@:)
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

if (userLocation) {
	return;
}

	userLocation = [locations lastObject];
	[manager stopUpdatingLocation];

	// NSLog(@"USERLOCATION: %f %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
	
	[self performSelector:@selector(getSuntimeForUserLocation)];

}

%new(v@:)
-(void)getSuntimeForUserLocation {
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://ahmadhashemi.com/tweaks/suntime.php?lat=%f&lng=%f",userLocation.coordinate.latitude,userLocation.coordinate.longitude];
	
	// NSLog(@"URLSTRING: %@",urlString);
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		
		if (error) {
			NSLog(@"ERROR: %@",error.localizedDescription);
			return;
		}
		
		// NSLog(@"GOTDATA: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
		
		NSString *sunriseString = dict[@"sunrise"];
		NSString *sunsetString = dict[@"sunset"];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"YYYY-MM-dd HH:mm";
		NSDate *sunrise = [formatter dateFromString:sunriseString];
		NSDate *sunset = [formatter dateFromString:sunsetString];
		
		[[NSUserDefaults standardUserDefaults] setObject:sunrise forKey:@"Sunrise"];
		[[NSUserDefaults standardUserDefaults] setObject:sunset forKey:@"Sunset"];
		
		[self performSelector:@selector(configureColorPalette)];
		
		// NSLog(@"SUNRISEHOUR: %@",sunrise);
		// NSLog(@"SUNSETHOUR: %@",sunset);
		// NSLog(@"NOW: %@",[[NSDate alloc] init]);
		
	}] resume];
	
}

%end