//
//  NSString+Additions.m
//  ElementDrop


#import "NSString+Additions.h"

@implementation NSString (SearchingAdditions)

- (BOOL)containsString:(NSString *)aString
{
    return [self containsString:aString ignoringCase:NO];
}

- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag
{
    unsigned mask = (flag ? NSCaseInsensitiveSearch : NULL);
    NSRange range = [self rangeOfString:aString options:mask];
    return (range.length > 0);
}

@end
