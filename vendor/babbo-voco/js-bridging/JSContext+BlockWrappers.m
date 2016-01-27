#import "JSContext+BlockWrappers.h"

@implementation JSContext (BlockWrappers)

-( void )addNativeMethodArg1:( NSString* )name withBlock:( NativeBlockArg1 )block
{
	self[name] = ^(id arg1) {
		return block(arg1);
	};
}

-( void )addNativeMethodArg2:( NSString* )name withBlock:( NativeBlockArg2 )block
{
	self[name] = ^(id arg1, id arg2) {
		return block(arg1, arg2);
	};
}

-( void )addNativeMethodArg3:( NSString* )name withBlock:( NativeBlockArg3 )block
{
	self[name] = ^(id arg1, id arg2, id arg3) {
		return block(arg1, arg2, arg3);
	};
}

-( void )addNativeMethodArg4:( NSString* )name withBlock:( NativeBlockArg4 )block
{
	self[name] = ^(id arg1, id arg2, id arg3, id arg4) {
		return block(arg1, arg2, arg3, arg4);
	};
}

-( void )addNativeMethodArg5:( NSString* )name withBlock:( NativeBlockArg5 )block
{
	self[name] = ^(id arg1, id arg2, id arg3, id arg4, id arg5) {
		return block(arg1, arg2, arg3, arg4, arg5);
	};
}

-( void )addNativeMethodArg6:( NSString* )name withBlock:( NativeBlockArg6 )block
{
	self[name] = ^(id arg1, id arg2, id arg3, id arg4, id arg5, id arg6) {
		return block(arg1, arg2, arg3, arg4, arg5, arg6);
	};
}

-( void )addNativeMethodArg7:( NSString* )name withBlock:( NativeBlockArg7 )block
{
	self[name] = ^(id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7) {
		return block(arg1, arg2, arg3, arg4, arg5, arg6, arg7);
	};
}

-( void )addNativeMethodArg8:( NSString* )name withBlock:( NativeBlockArg8 )block
{
	self[name] = ^(id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8) {
		return block(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	};
}

-( void )addNativeMethodArg9:( NSString* )name withBlock:( NativeBlockArg9 )block
{
	self[name] = ^(id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) {
		return block(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
	};
}
@end

