const NSString *__babbo_voco_native_utils_version = @"1.0";

@interface NativeUtils : NSObject
+( void ) redirectNSLogToPath:( NSString *)path truncate:( BOOL )truncate;
@end

@implementation NativeUtils

+( void ) redirectNSLogToPath:( NSString *)path truncate:( BOOL )truncate
{
  const char *flags = ( truncate ) ? "w":"a+";
  freopen([path cStringUsingEncoding:NSUTF8StringEncoding], flags, stderr);
}

@end

/* vim: ft=objc
 */
