#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>
#import <AppKit/AppKit.h>
#import "NSString+Additions.h"

//------- @interface section -------

@interface QuicktimeController: NSObject
{
	QTMovie *movie;
}
- (id)init;
- (BOOL)isQT:(NSString *)path;
-(void)dealloc;


@end

//------- @implementation section -------
@implementation QuicktimeController
- (id)init 
{
    self = [super init];
	return self; 
}
-(BOOL)setMovie:(NSString *)file
{
	//NSURL *fileURL = [NSURL fileURLWithPath: file];
	//NSLog(@"%@ url", fileURL);
	if(movie){
		[movie release];
	}
	
	if([QTMovie canInitWithFile:file]){
			movie = [[QTMovie alloc] initWithFile:file error:NULL];
			return TRUE;
			
	}else{
			return FALSE;
	}			
	
}
-(NSString *)getTimecodeInfo
{
	NSString *result = @"<Unknown timecode>";
	NSArray *tracks = [movie tracksOfMediaType:QTMediaTypeTimeCode];
	 if ([tracks count] > 0) {
			QTMedia *media = [[tracks objectAtIndex:0] media];
			TimeCodeDescriptionHandle desc = 
			(TimeCodeDescriptionHandle)NewHandleClear(sizeof(TimeCodeDescriptionHandle));
			   if (desc) {
					OSErr err = GetMoviesError();
					if (err == noErr) {

						TimeCodeDef      myTCDef;
						TimeCodeRecord    myTCRec;
						
						err = TCGetCurrentTimeCode(GetMediaHandler([media quickTimeMedia]), NULL, &myTCDef, &myTCRec, NULL);
						if (err == noErr) {
						
						 Str255    myString;
      
						err = TCTimeCodeToString(GetMediaHandler([media quickTimeMedia]), &myTCDef, &myTCRec, myString);
						if (err == noErr)
							
								result = (NSString *)CFStringCreateWithPascalString(kCFAllocatorDefault, myString, CFStringGetSystemEncoding());
						}

					}
					
			    DisposeHandle((Handle)desc);
				
			   }
			
   }
   // NSLog(@"%@", result);
 return result;
}

- (BOOL)isQT:(NSString *)path
{
    BOOL display = FALSE;
    MDItemRef item = MDItemCreate(kCFAllocatorDefault, (CFStringRef)path);
	if(item)
	{
		CFTypeRef ref = MDItemCopyAttribute(item, CFSTR("kMDItemContentType"));
		
		 if (ref) {
			if (UTTypeConformsTo(ref, CFSTR("com.apple.quicktime-movie"))) display = TRUE;
			CFRelease(ref);
		
		}
	
    }
   
    if (item) CFRelease(item);
    return display;
}

-(void)dealloc
{
	[movie release];
	[super dealloc];
}


@end
void usage(){
	printf("usage: use timecodereader to read timecode from QuickTime files, timecodereader accepts a single path arguement.\n");
}
int main (int argc, const char * argv[]) {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuicktimeController *qt =[[QuicktimeController alloc] init];

   if(argc == 2){
	
	NSArray *mountPoints = [[NSWorkspace sharedWorkspace] 
		mountedLocalVolumePaths];
	//NSLog(@"mountPoints: %@", mountPoints);
	
	NSString *path = [NSString stringWithUTF8String:argv[1]];
	NSString *fullPath  = [path stringByExpandingTildeInPath];
	id  mount;
	
	NSEnumerator* myIterator = [mountPoints objectEnumerator];
	while(mount = [myIterator nextObject])
	{
		NSArray *theComponents = [fullPath pathComponents];
		NSString *firstPath = [theComponents objectAtIndex:1];
		//NSLog(@"mount %@", mount);
		//NSLog(@"firstPath: %@", firstPath);
		
		if([mount containsString:firstPath] && ![firstPath isEqualToString:@"Volumes"])
		{
			NSString *appendedPath = [@"/Volumes" stringByAppendingPathComponent:fullPath];
			fullPath = [NSString stringWithString: appendedPath];
			break;
		}
	}
	
	NSString *convertedPath =  (NSString *)CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)fullPath, (CFStringRef)@"");

	
	
		if([qt isQT: convertedPath ])
		{
			
			BOOL isMovie = [qt setMovie: convertedPath ];
			if(isMovie){
				NSString *timecodeString = [qt getTimecodeInfo];
				fprintf(stderr,"%s\n", [timecodeString fileSystemRepresentation]);
			}else{
				fprintf(stderr," unable to allocate memory for %s\n", [convertedPath  fileSystemRepresentation]);
			}
				
		}else{
			fprintf(stderr,"%s does not appear to be a QuickTime File.\n",[convertedPath  fileSystemRepresentation]);
		}

	}else{
		usage();
	}
	
    [pool release];
	[qt release];
    return 0;
}
