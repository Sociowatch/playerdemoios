//
//  SlikeDeviceSettings.m
//  SlikePlayer
//
//  Created by TIL on 10/08/12.
//  Copyright (c) 2012 TIL. All rights reserved.
//

#import "SlikeDeviceSettings.h"
#import "SlikeKeychain.h"
#import <sys/utsname.h>
#import "NSString+Advanced.h"

static NSString *kCoachMarkSettingString = @"kCoachMarkSettingString";

@interface SlikeDeviceSettings() <CLLocationManagerDelegate> {
    
    NSInteger _capLevel;
    NSInteger _minLevel;
    CGSize theScreenSize;
    float playerViewArea;
}


@property (nonatomic, assign) BOOL iPhoneX;
@property (nonatomic, assign) BOOL iPhone6Plus;
@property (nonatomic, assign) BOOL iPhone6;
@property (nonatomic, assign) BOOL iPhone5;
@property (nonatomic, assign) BOOL iPhone4;


///mediaSavedBitrate
@property(nonatomic, strong) CLLocation *location;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) NSString *mediaSavedBitrate;
@property(atomic, strong) NSString *userSessionId;
@property(nonatomic, strong) NSDate *sessionGenrateTime;
@property(nonatomic, strong) NSString * rid;
@property(nonatomic, strong) NSString * geoID;
@property(nonatomic, strong) NSString * m3U8HostName;
@property(nonatomic, strong) NSString * strKey;
@property(nonatomic, assign) NSInteger  nServerPlayStatus;
@property(nonatomic, assign) NSInteger  nMeasuredBitrate;
@property(nonatomic, strong) NSString * strAppVersion;
@property(nonatomic, strong) NSString * strOSVersion;
@property(nonatomic, strong) NSString * strProvidedUUID;
@property(nonatomic, strong) NSString * strManufacturer;
@property(nonatomic, strong) NSString * strAnaCache;
@property(nonatomic, assign) NSInteger  nServerPingInterval;
@property(nonatomic, assign) NSInteger  sessionTimeout;
@property(nonatomic, strong) NSString * strDeviceInfo;
@property(nonatomic, assign) BOOL       phoneDevice
;

@end

@implementation SlikeDeviceSettings

-(BOOL) isJailbroken {
    
#if !(TARGET_IPHONE_SIMULATOR)
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]){
        return YES;
    }
    NSError *error;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error==nil){
        return YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
#endif
    return NO;
}

-(void)setUniqueDeviceIdentifierAsString:(NSString *)strID {
    self.strProvidedUUID = strID;
}


- (NSString *)getUniqueDeviceIdentifierAsString {
    
    @try {
        static NSString *deviceAppGeneratedPersistentUuidKeychainKey = @"slikeDeviceAppGeneratedPersistentUuid";
        NSString *savedIdentifier = [SlikeKeychain stringForKey:deviceAppGeneratedPersistentUuidKeychainKey];
        if (savedIdentifier.length == 0) {
            savedIdentifier = [[NSUUID UUID] UUIDString];
            BOOL setDidSucceed = [SlikeKeychain setString:savedIdentifier
                                                   forKey:deviceAppGeneratedPersistentUuidKeychainKey];
            if (!setDidSucceed) {
                return savedIdentifier;
            }
        }
        return savedIdentifier;
    } @catch (NSException *exception) {
        return nil;
    }
    
    /*
     NSString *appName=[[[NSBundle mainBundle] infoDictionary]objectForKey:(NSString*)kCFBundleNameKey];
     NSError *error = nil;
     NSString *strApplicationUUID = [SFHFKeychainUtils getPasswordForUsername:@"uuid" andServiceName:appName error:&error];
     if(error) SlikeDLog(@"%@", error);
     
     if (strApplicationUUID == nil) {
     strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
     [SFHFKeychainUtils storeUsername:@"uuid" andPassword:strApplicationUUID forServiceName:appName updateExisting:YES error:&error];
     if(error) SlikeDLog(@"%@", error);
     }
     
     return strApplicationUUID;*/
    
}


- (NSString *)getMacAddress {
    if(_strProvidedUUID) return _strProvidedUUID;
    
#if TARGET_IPHONE_SIMULATOR
    return [[[NSUUID alloc] initWithUUIDString:@"9BA42188-9899-5567-10BA-982CCA3C777C"] UUIDString];
#endif
    
    return [self getUniqueDeviceIdentifierAsString];
}

#pragma mark Singleton Methods
+ (SlikeDeviceSettings *)sharedSettings {
    static SlikeDeviceSettings *sharedMySettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMySettings = [[SlikeDeviceSettings alloc] init];
    });
    return sharedMySettings;
}

- (id)init {
    
    if (self = [super init]) {
        self.isDebugMode =  NO;
        self.section =  @"";
        self.vendorID =  @"";
        self.pid =  @"";
        self.pageSection =  @"";
        self.sg =  @"";
        self.packageName =  @"";
        self.description_url =  @"";
        self.m3U8HostName =  @"";
        self.rid =  @"";
        self.geoID =  @"";
        _strDeviceInfo = nil;
        _nServerPingInterval = 6;
        _sessionTimeout = 3;
        _nServerPlayStatus = 0;
        _nMeasuredBitrate = 0;
        _strKey = @"";
        _gaId = @"";
        _comscoreId = @"";
        theScreenSize = CGSizeZero;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.mediaSavedBitrate = [defaults objectForKey:@"slike_bitrate"];
        if(self.mediaSavedBitrate == nil || [self.mediaSavedBitrate isEqualToString:@""]) {
            self.mediaSavedBitrate = @"none";
            [defaults setObject:self.mediaSavedBitrate forKey:@"slike_bitrate"];
            [defaults synchronize];
        }
        
        self.location = nil;
        [self setDeviceFlag];
    }
    return self;
}

#pragma mark CLLocationManagerDelegate delegates
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    if (currentLocation != nil) {
        SlikeDLog(@"Longitude (%.8f) and latitude (%.8f)", currentLocation.coordinate.longitude, currentLocation.coordinate.latitude);
        [[SlikeDeviceSettings sharedSettings] updateLatLong:[NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.longitude, currentLocation.coordinate.latitude]];
        [SlikeDeviceSettings sharedSettings].location = currentLocation;
    }
    // Stop Location Manager
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
    SlikeDLog(@"didUpdateToLocation: %@", currentLocation);
}


-(BOOL) isIPhoneDevice {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

-(NSString *)getAppVersion {
    
    if(_strAppVersion != nil) return _strAppVersion;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _strAppVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    
    _strAppVersion = [_strAppVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    return _strAppVersion;
}

- (void)updateLatLong:(NSString *) str {
    [self deviceInfo];
    _strDeviceInfo = [_strDeviceInfo stringByReplacingOccurrencesOfString:@"&lat=" withString:[NSString stringWithFormat:@"&lat=%@", str]];
}

- (NSString *)getKey {
    return _strKey == nil ? @"" : _strKey;
}

-(void) setKey:(NSString *)key {
    _strKey = key == nil ? @"" : key;
}

- (NSString *)getSlikeAnalyticsCache {
    
    if(!_strAnaCache) {
        _strAnaCache = [NSString stringWithFormat:@"os=19&oss=6&osv=%@&mf=%@&dm=%@&arc=%@&sd=%f&v=%@&uuid=%@&apikey=%@", [NSString getPaddedString:[self getOSVersion]], [self getManufacturer], [self getDeviceModelName],[self getCPUType],[self getScreenSizeInch], [NSString getPaddedString:[self getSDKVersion]], [self getMacAddress], [self getKey]];
        
    }
    return _strAnaCache;
}

- (NSString*)getDeviceLocation {
    NSString *strLatLong = @"";
    if(self.location) {
        strLatLong = [NSString stringWithFormat:@"%f,%f", self.location.coordinate.longitude, self.location.coordinate.latitude];
    }
    return strLatLong;
}

- (NSString *)getOSVersion {
    
    if(!_strOSVersion) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _strOSVersion = [[[UIDevice currentDevice] systemVersion] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    }
    return _strOSVersion;
}

- (NSString *) getManufacturer {
    _strManufacturer = @"Apple";
    return _strManufacturer;
}

- (NSString*)getDeviceModelName {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"x86_64"    :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",        // (Original)
                              @"iPod2,1"   :@"iPod Touch",        // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",        // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",        // (Fourth Generation)
                              @"iPod7,1"   :@"iPod Touch",        // (6th Generation)
                              @"iPhone1,1" :@"iPhone",            // (Original)
                              @"iPhone1,2" :@"iPhone",            // (3G)
                              @"iPhone2,1" :@"iPhone",            // (3GS)
                              @"iPad1,1"   :@"iPad",              // (Original)
                              @"iPad2,1"   :@"iPad 2",            //
                              @"iPad3,1"   :@"iPad",              // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",          // (GSM)
                              @"iPhone3,3" :@"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",         //
                              @"iPhone5,1" :@"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",          // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",              // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",         // (Original)
                              @"iPhone5,3" :@"iPhone 5c",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",     //
                              @"iPhone7,2" :@"iPhone 6",          //
                              @"iPhone8,1" :@"iPhone 6S",         //
                              @"iPhone8,2" :@"iPhone 6S Plus",    //
                              @"iPhone8,4" :@"iPhone SE",         //
                              @"iPhone9,1" :@"iPhone 7",          //
                              @"iPhone9,3" :@"iPhone 7",          //
                              @"iPhone9,2" :@"iPhone 7 Plus",     //
                              @"iPhone9,4" :@"iPhone 7 Plus",     //
                              @"iPhone10,1" :@"Phone 8",
                              @"iPhone10,2" :@"iPhone 8 Plus",
                              @"iPhone10,3" :@"iPhone X",
                              @"iPhone10,4" :@"iPhone 8",
                              @"iPhone10,5" :@"iPhone 8 Plus",
                              @"iPhone10,6" :@"iPhone X",
                              @"iPad4,1"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   :@"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,7"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
                              @"iPad6,8"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652)
                              @"iPad6,3"   :@"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   :@"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }
    
    return deviceName;
}

- (NSString *)getCPUType {
    
    NSString *cpuType = @"";
    if (sizeof(void*) == 4) {
        cpuType = @"32";
    } else if (sizeof(void*) == 8) {
        cpuType = @"64";
    }
    return cpuType;
}

- (CGSize)getScreenSize {
    
    if(CGSizeEqualToSize(theScreenSize, CGSizeZero)) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        theScreenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    }
    return theScreenSize;
}

- (float)getScreenSizeInch {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    int nPPI = 326/screenScale;
    
    if(screenBounds.size.width == 414 || screenScale == 3) {
        nPPI = 401/screenScale;
    } else if (screenBounds.size.width == 768) {
        if(screenScale == 1.0)
        {
            nPPI = 326/2;
            
        }else {
            nPPI= 264/2;
        }
    } else if (screenBounds.size.width == 1024)
    {
        nPPI = 264/screenScale;
        
    }
    if(screenScale == 3.0) {
        return ((sqrt(pow(screenBounds.size.width , 2) + pow(screenBounds.size.height, 2)))/nPPI)*0.87;
    }
    return (sqrt(pow(screenBounds.size.width , 2) + pow(screenBounds.size.height, 2)))/nPPI;
    
}

- (NSInteger)getScreenResEnum {
    
    [self getScreenSize];
    NSInteger wd = theScreenSize.width;
    NSInteger ht = theScreenSize.height;
    
    if(wd <= 320 && ht <= 480) return 1;
    else if(wd <= 480 && ht <= 800) return 2;
    else if(wd <= 480 && ht <= 854) return 3;
    else if(wd <= 540 && ht <= 960) return 4;
    else if(wd <= 1024 && ht <= 600) return 5;
    else if(wd <= 1024 && ht <= 768) return 6;
    else if(wd <= 1152 && ht <= 864) return 7;
    else if(wd <= 1280 && ht <= 720) return 8;
    else if(wd <= 1280 && ht <= 768) return 9;
    else if(wd <= 1280 && ht <= 800) return 10;
    else if(wd <= 1280 && ht <= 960) return 11;
    else if(wd <= 1280 && ht <= 1024) return 12;
    else if(wd <= 1360 && ht <= 768) return 13;
    else if(wd <= 1366 && ht <= 768) return 14;
    else if(wd <= 1400 && ht <= 1050) return 15;
    else if(wd <= 1440 && ht <= 900) return 16;
    else if(wd <= 1600 && ht <= 900) return 17;
    else if(wd <= 1680 && ht <= 1050) return 18;
    else if(wd <= 1920 && ht <= 1080) return 19;
    else if(wd <= 1920 && ht <= 1200) return 20;
    else if(wd <= 2048 && ht <= 1536) return 21;
    else if(wd <= 2560 && ht <= 1440) return 22;
    else if(wd <= 2560 && ht <= 1600) return 23;
    
    return 24;
}


- (NSString *)deviceInfo {
    
    if(_strDeviceInfo != nil) return _strDeviceInfo;
    
    NSArray *languageArray = [NSLocale preferredLanguages];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    NSString *language = [[languageArray objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [[locale localeIdentifier] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *model = [[currentDevice model] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *systemVersion = [[currentDevice systemVersion] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
#pragma clang diagnostic pop
    
    NSString *strUDID = [NSString stringFromMD5:[self getMacAddress]];
    NSString *strDeviceName = [[[UIDevice currentDevice] name] urlEncodedString];
    
    _strDeviceInfo = [NSString stringWithFormat:@"&device=%@&sys_version=%@&country=%@&lang=%@&app_version=%@&udn=%@&uuid=%@&prebacked=0&model=%@&manu=%@&brand=%@&jailbroken=%@&lat=%@&imei=&phone=", model, systemVersion, country, language, [self getAppVersion], strUDID, strUDID, model, strDeviceName, model, [self isJailbroken] ? @"yes" : @"no", @""];
    SlikeDLog(@"Device Info [ %@ ]", _strDeviceInfo);
    
    
    
    return _strDeviceInfo;
}


- (NSInteger)serverPingInterval {
    return _nServerPingInterval;
}

- (void)setServerPingInterval:(NSInteger) serverPingInterval {
    _nServerPingInterval = serverPingInterval/1000;
}

- (NSInteger)serverPlayStatus {
    return 10;
}

-(void)setServerPlayStatus:(NSInteger) nServerPlayStatus {
    _nServerPlayStatus = nServerPlayStatus;
}

-(NSInteger)nMeasuredBitrate {
    return _nMeasuredBitrate;
}

- (void)setMeasuredBitrate:(NSInteger)measuredBitrate {
    _nMeasuredBitrate = measuredBitrate;
}

- (NSString *)savedMediaBitrate {
    return self.mediaSavedBitrate;
}

- (void)setMediaBitrate:(NSString *)strSavedBitrate {
    
    self.mediaSavedBitrate = strSavedBitrate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(self.mediaSavedBitrate == nil || [self.mediaSavedBitrate isEqualToString:@""]) {
        self.mediaSavedBitrate = @"none";
    }
    [defaults setObject:self.mediaSavedBitrate forKey:@"slike_bitrate"];
    
    [defaults synchronize];
    SlikeDLog(@"%@",[defaults objectForKey:@"slike_bitrate"]);
}

- (void)setMediaBitrate:(NSString *)strSavedBitrate withLabel:(NSString*)strSavedBitrateLabel {
    
    self.mediaSavedBitrate = strSavedBitrate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(self.mediaSavedBitrate == nil || [self.mediaSavedBitrate isEqualToString:@""]) {
        self.mediaSavedBitrate = @"none";
    }
    
    [defaults setObject:self.mediaSavedBitrate forKey:@"slike_bitrate"];
    if(strSavedBitrateLabel && [strSavedBitrateLabel isEqualToString:@"none"]) {
        [defaults removeObjectForKey:@"slike_bitrate_label"];
    } else {
        [defaults setObject:strSavedBitrateLabel forKey:@"slike_bitrate_label"];
    }
    
    [defaults synchronize];
    SlikeDLog(@"%@",[defaults objectForKey:@"slike_bitrate"]);
}

- (NSString*)getBitrateBylabel:(SlikeConfig*)config {
    
    NSArray *arrBitare = [config.streamingInfo getVideosListByType:[config.streamingInfo getCurrentVideoSource]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *current_nBitrate =  @"none";
    
    for(Stream * stream in arrBitare) {
        if([stream.strLabel isEqualToString:[defaults objectForKey:@"slike_bitrate_label"]]) {
            current_nBitrate = [NSString stringWithFormat:@"%ld", (long)stream.nBitrate];
            break;
        }
    }
    return current_nBitrate;
}


- (NSString*)genrateUserSS:(SlikeConfig *) config {
    
    NSString * ss = nil;
    time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
    NSString *strUDID =[[SlikeDeviceSettings sharedSettings] getMacAddress] ;
    
    if(config && config!=nil) {
        ss= [NSString stringFromMD5:[NSString stringWithFormat:@"%@%@%ld%@",strUDID,config.mediaId,unixTime,[NSString randomStringWithLength:6]]];
    } else {
        
        ss= [NSString stringFromMD5:[NSString stringWithFormat:@"%@%ld%@",strUDID,unixTime,[NSString randomStringWithLength:6]]];
    }
    return ss;
}

- (NSString*)getUserSession:(SlikeConfig *) config
{
    if(self.userSessionId.length == 0) {
        self.userSessionId =[self genrateUserSS:nil];
        self.sessionGenrateTime = [NSDate date];
        
    } else if(self.sessionGenrateTime) {
        NSDate* date1 = self.sessionGenrateTime;
        NSDate* date2 = [NSDate date];
        NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
        NSInteger secondsInAMinute = 60;
        NSInteger minuteBetweenDates = distanceBetweenDates / secondsInAMinute;
        if(minuteBetweenDates<0) {
            minuteBetweenDates = - minuteBetweenDates;
        }
        if(minuteBetweenDates < _sessionTimeout) {
            self.sessionGenrateTime = [NSDate date];
        } else {
            self.userSessionId = [self genrateUserSS:nil];
            self.sessionGenrateTime = [NSDate date];
            config.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:config.mediaId];
        }
    }
    return self.userSessionId;
}

- (NSInteger)nUserSessionChangeInterval {
    return _sessionTimeout;
}

-(void)setUserSessionChangeInterval:(NSInteger) nUserSessionInterval
{
    _sessionTimeout = nUserSessionInterval/60000  ;
}

-(NSInteger)getcapLevel {
    return _capLevel;
}

- (NSInteger)getminLevel {
    return _capLevel;
}

- (void)setMax_Min_CapLevel:(NSInteger)minLevel MaxLevel:(NSInteger)capLevel {
    
    if(capLevel>0 && capLevel>minLevel) {
        
        _minLevel = minLevel*1024;
        _capLevel = capLevel*1024;
    }
}

- (void)setM3U8HostValue:(NSString *)strM3U8HostName {
    self.m3U8HostName = strM3U8HostName;
}

- (NSString*) getM3U8HostName {
    return self.m3U8HostName;
}

-(void)setVideoRid:(NSString *)ridvalue{
    self.rid =  ridvalue;
}

- (NSString*) getVideoRid {
    return self.rid;
}

- (NSString*) getGeoCountry {
    SlikeDLog(@"%@",self.geoID);
    return self.geoID;
}

- (void)setGeoCountry:(NSString *)geoLocId {
    if (geoLocId !=nil && ![geoLocId isEqualToString:@""]) {
        NSArray *isvalidGeoId = [geoLocId componentsSeparatedByString:@","];
        
        if (isvalidGeoId && [isvalidGeoId count]==1) {
            self.geoID =  [geoLocId lowercaseString];
        } else if (isvalidGeoId &&  [isvalidGeoId count] >1) {
            self.geoID = [NSString stringWithFormat:@"%@", isvalidGeoId.firstObject];
            self.geoID = [self.geoID stringByReplacingOccurrencesOfString:@" " withString:@""];
            self.geoID = [self.geoID stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
            
            self.geoID =  [self.geoID lowercaseString];
            
        }
    }
}

- (BOOL)isGeoAllowed:(NSString*)strGca GCB:(NSString*)strGcb {
    
    BOOL isAllow =  YES;
    if(self.geoID && [self.geoID length]>0) {
        
        NSArray *gcaArray = nil;
        if(strGca && [strGca length]>0) {
            gcaArray =  [[NSArray alloc]initWithArray:[strGca componentsSeparatedByString:@","]];
        }
        
        NSArray *gcbArray = nil;
        if(strGcb && [strGcb length]>0) {
            gcbArray  =  [[NSArray alloc]initWithArray:[strGcb componentsSeparatedByString:@","]];
        }
        if(((gcaArray.count>0 && ![gcaArray containsObject:self.geoID])) || (gcbArray.count>0 && [gcbArray containsObject:self.geoID])) {
            isAllow =  NO;
        }
    }
    return isAllow;
}

- (NSString*)getSDKVersion {
    return  @"2.7.8";
}

- (void)setPlayerViewArea:(id)parentView {
    
    playerViewArea = 100.00;
    if(parentView && parentView!=nil && [parentView isKindOfClass:[UIView class]]) {
        UIView *currentPlayerView = (UIView*)parentView;
        CGSize currentScreenSize = [UIScreen mainScreen].bounds.size;
        CGFloat deviceArea = currentScreenSize.width* currentScreenSize.height;
        CGFloat playerArea = currentPlayerView.bounds.size.height * currentPlayerView.bounds.size.width;
        CGFloat percentageArea = ((playerArea * 100) / deviceArea);
        playerViewArea = (float)percentageArea ;
    }
}

-(float)getPlayerViewArea {
    return playerViewArea;
}

/**
 Generate the Unique String. Will be used for Capturing the Events
 
 @param mediaId - Media Id
 @return - Uniue String
 */
- (NSString *)genrateUniqueSSId:(NSString*)mediaId {
    
    NSString * uniqueString = nil;
    time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
    NSString *strUDID =[[SlikeDeviceSettings sharedSettings] getMacAddress] ;
    
    if(mediaId && ![mediaId isEqualToString:@""]) {
        uniqueString = [NSString stringFromMD5:[NSString stringWithFormat:@"%@%@%ld%@",strUDID, mediaId, unixTime,[NSString randomStringWithLength:6]]];
    } else {
        uniqueString = [NSString stringFromMD5:[NSString stringWithFormat:@"%@%ld%@",strUDID, unixTime,[NSString randomStringWithLength:6]] ];
    }
    return uniqueString;
}
-(void)updateAdCustomParams:(SlikeConfig*)config
{
    self.section =  config.section;
    self.vendorID =  config.vendorID;
    self.pid =   config.pid;
    self.pageSection =   config.pageSection;
    self.sg =   config.pageSection;
    self.packageName =   config.packageName;
    self.description_url =   config.description_url;
}

- (void)setDeviceFlag {
    if (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )812 ) < DBL_EPSILON) {
        _iPhoneX = YES;
    }
    else if (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )736 ) < DBL_EPSILON) {
        _iPhone6Plus = YES;
    }
    else if (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )667 ) < DBL_EPSILON) {
        _iPhone6 = YES;
    }
    else if (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON) {
        _iPhone5 = YES;
    }
    else if (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON) {
        _iPhone4 = YES;
    }
}

- (BOOL)isPhoneX {
    return _iPhoneX;
}

- (BOOL)isPhone6Plus {
    return _iPhone6Plus;
}

- (BOOL)isPhone6 {
    return _iPhone6;
}

- (BOOL)isPhone5 {
    return _iPhone5;
}

- (BOOL)isPhone4 {
    return _iPhone4;
}

#pragma mark - Coach Mark
- (BOOL)hasCoachMarkShown {
  return [[NSUserDefaults standardUserDefaults]boolForKey:kCoachMarkSettingString];
}

- (void)updateCoachMarkStatus:(BOOL)hasShown {
    [[NSUserDefaults standardUserDefaults]setBool:hasShown forKey:kCoachMarkSettingString];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
@end
