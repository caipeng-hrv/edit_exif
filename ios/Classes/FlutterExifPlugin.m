#import "FlutterExifPlugin.h"

@implementation FlutterExifPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"edit_exif"
            binaryMessenger:[registrar messenger]];
  FlutterExifPlugin* instance = [[FlutterExifPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }  else if ([@"getExif" isEqualToString:call.method]) {
      result([self getExif:(NSDictionary *)call.arguments]);
  } else if ([@"setGps" isEqualToString:call.method]) {
    [self setGps:(NSDictionary *)call.arguments];
     result(NULL);
  }else if ([@"setExif" isEqualToString:call.method]) {
    [self setExif:(NSDictionary *)call.arguments];
     result(NULL);
  }else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSDictionary *)getExif:(NSDictionary *)arguments {
  NSString *url = arguments[@"path"];
  NSString *key = arguments[@"key"];
  NSURL *fileUrl = [NSURL fileURLWithPath:url];
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
  CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, 0,NULL);
  return (__bridge NSDictionary *)imageInfo;
}
- (void)setGps:(NSDictionary *)arguments {
  NSString *url = arguments[@"path"];
  NSDictionary *gpsInfo = arguments[@"gps"];
  NSURL *fileUrl = [NSURL fileURLWithPath:url];
  //获取图片全部信息
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
  CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, 0,NULL);
  NSMutableDictionary *metaDataDic = [(__bridge NSDictionary *)imageInfo mutableCopy];
  //重写gps信息
  [metaDataDic setObject:gpsInfo forKey:(NSString*)kCGImagePropertyGPSDictionary];
  CFStringRef UTI = CGImageSourceGetType(imageSource);
  //重写图片
  NSMutableData *newImageData = [NSMutableData data];
  CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1,NULL);

  //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
  CGImageDestinationAddImageFromSource(destination, imageSource, 0, (__bridge CFDictionaryRef)metaDataDic);
  CGImageDestinationFinalize(destination);
  NSString *directoryDocuments =  NSTemporaryDirectory();
  [newImageData writeToFile: [fileUrl path] atomically:YES];
  CIImage *testImage = [CIImage imageWithData:newImageData];
  NSDictionary *propDict = [testImage properties];
  NSLog(@"Properties %@", propDict);    
}
- (void)setExif:(NSDictionary *)arguments {
  NSString *url = arguments[@"path"];
  NSDictionary *exifInfo = arguments[@"exif"];
  NSURL *fileUrl = [NSURL fileURLWithPath:url];
  //获取图片全部信息
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
  CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, 0,NULL);
  NSMutableDictionary *metaDataDic = [(__bridge NSDictionary *)imageInfo mutableCopy];
  //重写exif信息
  NSMutableDictionary *exifDic =[[metaDataDic objectForKey:(NSString*)kCGImagePropertyExifDictionary] mutableCopy];
  NSArray *exifArray = [exifInfo allKeys];
  for (int i = 0; i<exifArray.count; i++) {
    NSString *key =  exifArray[i];
    NSObject *value = [exifInfo objectForKey:key];
    [exifDic setObject: value forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
  }
  NSLog(@"exif %@",exifDic); 
  [metaDataDic setObject: exifDic forKey:(NSString*)kCGImagePropertyExifDictionary];
  CFStringRef UTI = CGImageSourceGetType(imageSource);
  //重写图片
  NSMutableData *newImageData = [NSMutableData data];
  CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1,NULL);

  //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
  CGImageDestinationAddImageFromSource(destination, imageSource, 0, (__bridge CFDictionaryRef)metaDataDic);
  CGImageDestinationFinalize(destination);
  NSString *directoryDocuments =  NSTemporaryDirectory();
  [newImageData writeToFile: [fileUrl path] atomically:YES];
  CIImage *testImage = [CIImage imageWithData:newImageData];
  NSDictionary *propDict = [testImage properties];
  NSLog(@"Properties %@", propDict);    
}
@end
