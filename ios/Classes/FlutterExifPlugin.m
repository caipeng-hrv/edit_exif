#import "FlutterExifPlugin.h"

@implementation FlutterExifPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_exif"
            binaryMessenger:[registrar messenger]];
  FlutterExifPlugin* instance = [[FlutterExifPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- ()getExif:(){
  NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"YourPic" withExtension:@""];
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
  CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, 0,NULL);
  NSDictionary *exifDic = (__bridge NSDictionary *)CFDictionaryGetValue(imageInfo, kCGImagePropertyExifDictionary) ;

}
- (void)editExif:(){
  [exifDic setObject:[NSNumber numberWithFloat:1234.3] forKey:(NSString *)kCGImagePropertyExifExposureTime];
  [exifDic setObject:@"SenseTime" forKey:(NSString *)kCGImagePropertyExifLensModel];
      
  [GPSDic setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
  [GPSDic setObject:[NSNumber numberWithFloat:116.29353] forKey:(NSString*)kCGImagePropertyGPSLatitude];

  [metaDataDic setObject:exifDic forKey:(NSString*)kCGImagePropertyExifDictionary];
  [metaDataDic setObject:GPSDic forKey:(NSString*)kCGImagePropertyGPSDictionary];

}
@end
