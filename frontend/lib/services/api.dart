import 'dart:convert'; import 'dart:async'; import 'package:flutter/foundation.dart'; import 'package:http/http.dart' as http;
import 'network_exception_stub.dart' if (dart.library.io) 'network_exception_io.dart' as network_exceptions;
class ApiException implements Exception { final String message; final int? statusCode; const ApiException(this.message,{this.statusCode}); @override String toString()=>message; }
class Api{
  static const configuredBase = String.fromEnvironment('API_URL');
  String get base {
    if (configuredBase.isNotEmpty) {
      final configured = configuredBase.replaceFirst(RegExp(r'/+$'), '');
      return configured.endsWith('/api') ? configured : '$configured/api';
    }
    if (!kDebugMode) return 'https://helpi-eight.vercel.app/api';
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }
  String? token;
  Future<bool> Function()? onUnauthorized;
  Future<bool>? _refreshInFlight;
  Map<String,String> get headers {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return {
      'Content-Type':'application/json',
      if(token!=null)'Authorization':'Bearer $token',
      'X-Timestamp': timestamp,
      'X-Client-Platform': kIsWeb ? 'flutter-web' : 'flutter-android',
    };
  }
  Future<dynamic> call(String method,String path,[Map<String,dynamic>? body])async{
    final uri=Uri.parse('$base$path');
    Future<http.Response> request() async {
      switch(method){
        case'GET': return http.get(uri,headers:headers).timeout(const Duration(seconds:8));
        case'POST': return http.post(uri,headers:headers,body:jsonEncode(body??{})).timeout(const Duration(seconds:20));
        case'PATCH': return http.patch(uri,headers:headers,body:jsonEncode(body??{})).timeout(const Duration(seconds:20));
        default: throw const ApiException('Unsupported request.');
      }
    }
    try {
      http.Response r;
      try { r=await request(); } on Exception catch (error) {
        if(method!='GET' || !network_exceptions.isSocketException(error)) rethrow;
        await Future<void>.delayed(const Duration(milliseconds:350));
        r=await request();
      }
      if (r.statusCode == 401 && token != null && !path.startsWith('/auth/')) {
        final refreshHandler = onUnauthorized;
        if (refreshHandler != null) {
          var pending = _refreshInFlight;
          if (pending == null) {
            pending = refreshHandler();
            _refreshInFlight = pending;
          }
          final refreshed = await pending;
          if (identical(_refreshInFlight, pending)) _refreshInFlight = null;
          if (refreshed) r = await request();
        }
      }
      if(r.statusCode<200||r.statusCode>=300)throw ApiException(_message(r),statusCode:r.statusCode);
      if(r.body.isEmpty)return {};
      try{return jsonDecode(r.body);}catch(_){throw const ApiException('The server returned an invalid response.');}
    } on ApiException { rethrow; } on TimeoutException { throw const ApiException('The server took too long to respond. Check that the Helpi backend is running and try again.'); } on http.ClientException { throw const ApiException('Could not connect to the Helpi backend. Check the API address and try again.'); } catch(error) { if (network_exceptions.isSocketException(error)) throw const ApiException('Could not reach the Helpi backend. Check that it is running and that this device can reach the computer.'); throw const ApiException('Something went wrong. Please try again.'); }
  }
  Future<Map<String,dynamic>> _mapCall(String method,String path,[Map<String,dynamic>? body]) async {
    final value = await call(method,path,body);
    if (value is Map<String,dynamic>) return value;
    if (value is Map) return value.map((key,value) => MapEntry(key.toString(),value));
    throw const ApiException('The server returned an unexpected response. Please try again.');
  }
  String _message(http.Response r){try{final j=jsonDecode(r.body);final m=j['message'];if(m is List)return m.join(', ');return m?.toString()??'Request failed (${r.statusCode})';}catch(_){return 'Request failed (${r.statusCode})';}}
  Future<Map<String,dynamic>> refresh(String refreshToken)=>_mapCall('POST','/auth/refresh',{'refreshToken':refreshToken});
  Future<Map<String,dynamic>> login(String e,String p,{String? mfa})=>_mapCall('POST','/auth/login',{'email':e,'password':p,if(mfa!=null)'mfaCode':mfa});
  Future<Map<String,dynamic>> register(String n,String e,String p,String c,{bool anonymousPublic=false,String? publicAlias,String? supportGroup})=>_mapCall('POST','/auth/register',{'name':n,'email':e,'password':p,'countryCode':c,'anonymousPublic':anonymousPublic,if(supportGroup!=null)'supportGroup':supportGroup,if(publicAlias!=null&&publicAlias.trim().isNotEmpty)'publicAlias':publicAlias.trim()});
  Future<Map<String,dynamic>> me()=>_mapCall('GET','/auth/me');
  Future<void> logout(String t)async{await call('POST','/auth/logout',{'refreshToken':t});}
  Future<List<dynamic>> cases({String q='',String? category,String? country})async{final params=<String,String>{if(q.isNotEmpty)'q':q,if(category!=null)'category':category,if(country!=null)'country':country};final qs=params.isEmpty?'':'?${Uri(queryParameters:params).query}';return await call('GET','/cases$qs') as List<dynamic>;}
  Future<List<dynamic>> mine()async=>await call('GET','/cases/mine') as List<dynamic>;
  Future<Map<String,dynamic>> createCase(Map<String,dynamic> data)=>_mapCall('POST','/cases',data);
  Future<List<dynamic>> threads()async=>await call('GET','/messages/threads') as List<dynamic>;
  Future<Map<String,dynamic>> startCaseChat(String caseId,int offerAmountMinor)=>_mapCall('POST','/messages/threads',{'caseId':caseId,'offerAmountMinor':offerAmountMinor});
  Future<List<dynamic>> threadMessages(String id)async=>await call('GET','/messages/threads/$id') as List<dynamic>;
  Future<Map<String,dynamic>> sendMessage(String id,String body)=>_mapCall('POST','/messages/threads/$id',{'body':body});
  Future<List<dynamic>> notifications()async=>await call('GET','/notifications') as List<dynamic>;
  Future<Map<String,dynamic>> countryOperations(String countryCode)=>_mapCall('GET','/country-operations/public/$countryCode');
  Future<List<dynamic>> securityEvents()async=>await call('GET','/security/events') as List<dynamic>;
  Future<List<dynamic>> sessions()async=>await call('GET','/users/sessions') as List<dynamic>;
  Future<Map<String,dynamic>> profile()=>_mapCall('GET','/users/profile');
  Future<Map<String,dynamic>> setupMfa()=>_mapCall('POST','/auth/mfa/setup');
  Future<Map<String,dynamic>> enableMfa(String code)=>_mapCall('POST','/auth/mfa/enable',{'code':code});
  Future<Map<String,dynamic>> disableMfa(String code)=>_mapCall('POST','/auth/mfa/disable',{'code':code});
  Future<Map<String,dynamic>> verifyEmail(String token)=>_mapCall('POST','/auth/verify-email',{'token':token});
  Future<Map<String,dynamic>> report(String type,String description,{String? caseId})=>_mapCall('POST','/reports',{'type':type,'description':description,if(caseId!=null)'caseId':caseId});
  Future<Map<String,dynamic>> convertCurrency(double amount, String from, String to) => _mapCall('GET', '/currency/convert?amount=$amount&from=$from&to=$to');
  Future<Map<String,dynamic>> markNotificationRead(String id) => _mapCall('PATCH','/notifications/$id/read');
  Future<Map<String,dynamic>> createReferral(Map<String,dynamic> data)=>_mapCall('POST','/referrals',data);
}

