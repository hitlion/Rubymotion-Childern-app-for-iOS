#import <JavaScriptCore/JSContext.h>

typedef id (^NativeBlockArg1)(id arg1);
typedef id (^NativeBlockArg2)(id arg1, id arg2);
typedef id (^NativeBlockArg3)(id arg1, id arg2, id arg3);
typedef id (^NativeBlockArg4)(id arg1, id arg2, id arg3, id arg4);
typedef id (^NativeBlockArg5)(id arg1, id arg2, id arg3, id arg4, id arg5);
typedef id (^NativeBlockArg6)(id arg1, id arg2, id arg3, id arg4, id arg5, id arg6);
typedef id (^NativeBlockArg7)(id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7);
typedef id (^NativeBlockArg8)(id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8);
typedef id (^NativeBlockArg9)(id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9);

@interface JSContext (BlockWrappers)
-( void )addNativeMethodArg1:( NSString* )name withBlock:( NativeBlockArg1 )block;
-( void )addNativeMethodArg2:( NSString* )name withBlock:( NativeBlockArg2 )block;
-( void )addNativeMethodArg3:( NSString* )name withBlock:( NativeBlockArg3 )block;
-( void )addNativeMethodArg4:( NSString* )name withBlock:( NativeBlockArg4 )block;
-( void )addNativeMethodArg5:( NSString* )name withBlock:( NativeBlockArg5 )block;
-( void )addNativeMethodArg6:( NSString* )name withBlock:( NativeBlockArg6 )block;
-( void )addNativeMethodArg7:( NSString* )name withBlock:( NativeBlockArg7 )block;
-( void )addNativeMethodArg8:( NSString* )name withBlock:( NativeBlockArg8 )block;
-( void )addNativeMethodArg9:( NSString* )name withBlock:( NativeBlockArg9 )block;
@end

