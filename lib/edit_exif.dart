import 'dart:async';

import 'package:flutter/services.dart';
class FlutterExif {
  String path;
  FlutterExif(this.path);
  static const MethodChannel _channel =
      const MethodChannel('edit_exif');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  Future getExif([String key]) async {
    //android获取某个属性信息 如key：TAG_GPS_LONGITUDE_REF（具体查看exif2文档）
    //ios获取所有图片信息（可以不传key）
    var platform = await FlutterExif.platformVersion;
    var value = {};
    if(platform.contains('iOS')){
      value = await _channel.invokeMethod('getExif',<String, dynamic>{'path': this.path,'key':key});
    }else{
      if(key != null){
        value = await _channel.invokeMethod('getExif',<String, dynamic>{'path': this.path,'key':key});
      }
    }
    return value;
  } 
  Future setExif(Map exif) async {
    //android查看https://developer.android.google.cn/reference/android/support/media/ExifInterface?hl=zh-cn
    //ios查看https://developer.apple.com/documentation/imageio/cgimageproperties/exif_dictionary_keys
    await _channel.invokeMethod('setExif',<String, dynamic>{'path': this.path,'exif':exif});
  }
  Future setDate(String date)async{
      var platform = await FlutterExif.platformVersion;
    if(platform.contains('iOS')){
      await setExif({'DateTimeOriginal':date});
    }else{
      await setExif({'TAG_DATETIME':date});
    }
  }
  Future setGps(Map location)async{
    var platform = await FlutterExif.platformVersion;
    if(platform.contains('iOS')){
      await _channel.invokeMethod('setGps',<String, dynamic>{'path': this.path,'gps':{
        'Latitude':location['lat'],
        'LatitudeRef':location['lat']>0?'N':'S',
        'Longitude':location['lng'],
        'LongitudeRef':location['lng']>0?'E':'W'
      }});
    }else{
      var longitude = gpsInfoConvert(location['lng']);
      var latitude = gpsInfoConvert(location['lat']);
      await setExif({
        'TAG_GPS_LATITUDE':latitude,
        'TAG_GPS_LATITUDE_REF':location['lat']>0?'N':'S',
        'TAG_GPS_LONGITUDE':longitude,
        'TAG_GPS_LONGITUDE_REF':location['lng']>0?'E':'W'
      });
    }
  }
  gpsInfoConvert(num coordinate){
      String sb = '';
      if (coordinate < 0) {
          coordinate = -coordinate;
      }
      num degrees = coordinate.floor();
      sb += degrees.toString() + '/1,';
      coordinate -= degrees;
      coordinate *= 60.0;
      num minutes = coordinate.floor();
      sb += minutes.toString() + '/1,';
      coordinate -= minutes.toDouble();
      coordinate *= 60.0;
      sb += coordinate.floor().toString() + '/1,';
      return sb;
  }
}
