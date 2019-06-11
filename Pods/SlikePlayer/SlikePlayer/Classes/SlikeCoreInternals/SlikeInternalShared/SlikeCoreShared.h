//
//  SlikeCoreShared.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 16/07/18.
//

#ifndef SlikeCoreShared_h
#define SlikeCoreShared_h
#endif /* SlikeCoreShared_h */

#define ENABLE_LOG 0
#define ENABLE_Analytic 1

#define SK_IS_IPHONE_X         ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )812 ) < DBL_EPSILON )
#define SK_iPHONE_X_INCREASE_STATUS_HEIGHT 24
#define SK_iPHONE_X_BOTTOM_SAFE_HEIGHT     24

#ifdef DEBUG
#ifndef SlikeDLog
#   define SlikeDLog(fmt, ...) {if(ENABLE_LOG)NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#endif
#ifndef SlikeELog
#   define SlikeELog(err) {if(err) SlikeDLog(@"%@", err)}
#endif
#else
#ifndef SlikeDLog
#   define SlikeDLog(...)
#endif
#ifndef SlikeELog
#   define SlikeELog(err)
#endif
#endif
// SlikeALog always displays output regardless of the DEBUG setting
#ifndef SlikeALog
#define SlikeALog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif

#ifndef SlikeFLog
#define SlikeFLog(args...) {SlikeExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);};

#endif
void SlikeExtendNSLog(const char* file, NSInteger lineNumber, const char *functionName, NSString *format, ...);

//For Internal  Use Only
//#define __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__    0
