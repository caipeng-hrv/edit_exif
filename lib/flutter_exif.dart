import 'dart:async';

import 'package:flutter/services.dart';
class FlutterExif {
  String path;
  FlutterExif(this.path);
  static const MethodChannel _channel =
      const MethodChannel('flutter_exif');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  Future getExif(String key) async {
    var value = await _channel.invokeMethod('getExif',<String, dynamic>{'path': this.path,'key':key});
    return value;
  } 
  Future setExif(String key,String value) async {
    await _channel.invokeMethod('setExif',<String, dynamic>{'path': this.path,'key':key,'value':value});
  }
  Future setLocation(Map location)async{
    var longitude = gpsInfoConvert(location['lng']);
    var latitude = gpsInfoConvert(location['lat']);
    await _channel.invokeMethod('setExif',<String, dynamic>{'path': this.path,'key':'TAG_GPS_LONGITUDE_REF','value':location['lng']>0?'E':'W'});
    await _channel.invokeMethod('setExif',<String, dynamic>{'path': this.path,'key':'TAG_GPS_LATITUDE_REF','value':location['lat']>0?'N':'S'});
    await _channel.invokeMethod('setExif',<String, dynamic>{'path': this.path,'key':'TAG_GPS_LONGITUDE','value':longitude});
    await _channel.invokeMethod('setExif',<String, dynamic>{'path': this.path,'key':'TAG_GPS_LATITUDE','value':latitude});
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
