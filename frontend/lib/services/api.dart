import 'dart:convert'; import 'dart:io'; import 'dart:async'; import 'package:http/http.dart' as http;
class ApiException implements Exception { final String message; final int? statusCode; const ApiException(this.message,{this.statusCode}); @override String toString()=>message; }
class Api{
  final String base=const String.fromEnvironment('API_URL',defaultValue:'http://10.0.2.2:3000/api');
  String? token;
  Map<String,String> get headers {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return {
      'Content-Type':'application/json',
      if(token!=null)'Authorization':'Bearer $token',
      'X-Timestamp': timestamp,
      'X-Client-Platform': 'flutter-android',
    };
  }
  Future<dynamic> call(String method,String path,[Map<String,dynamic>? body])async{
    final uri=Uri.parse('$base$path');
    Future<http.Response> request() async {
      switch(method){
        case'GET': return http.get(uri,headers:headers).timeout(const Duration(seconds:15));
        case'POST': return http.post(uri,headers:headers,body:jsonEncode(body??{})).timeout(const Duration(seconds:20));
        case'PATCH': return http.patch(uri,headers:headers,body:jsonEncode(body??{})).timeout(const Duration(seconds:20));
        default: throw const ApiException('Unsupported request.');
      }
    }
    try {
      http.Response r;
      try { r=await request(); } catch(e) {
        if(method!='GET') rethrow;
        await Future<void>.delayed(const Duration(milliseconds:350));
        r=await request();
      }
      if(r.statusCode<200||r.statusCode>=300)throw ApiException(_message(r),statusCode:r.statusCode);
      if(r.body.isEmpty)return {};
      try{return jsonDecode(r.body);}catch(_){throw const ApiException('The server returned an invalid response.');}
    } on ApiException { rethrow; } on TimeoutException { throw const ApiException('The connection timed out. Check your network and try again.'); } on SocketException { throw const ApiException('You appear to be offline. Check your connection and try again.'); } catch(_) { throw const ApiException('Something went wrong. Please try again.'); }
  }
  String _message(http.Response r){try{final j=jsonDecode(r.body);final m=j['message'];if(m is List)return m.join(', ');return m?.toString()??'Request failed (${r.statusCode})';}catch(_){return 'Request failed (${r.statusCode})';}}
  Future<Map<String,dynamic>> refresh(String refreshToken)=>call('POST','/auth/refresh',{'refreshToken':refreshToken}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> login(String e,String p,{String? mfa})=>call('POST','/auth/login',{'email':e,'password':p,if(mfa!=null)'mfaCode':mfa}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> register(String n,String e,String p,String c,{bool anonymousPublic=false,String? publicAlias})=>call('POST','/auth/register',{'name':n,'email':e,'password':p,'countryCode':c,'anonymousPublic':anonymousPublic,if(publicAlias!=null&&publicAlias.trim().isNotEmpty)'publicAlias':publicAlias.trim()}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> me()=>call('GET','/auth/me') as Future<Map<String,dynamic>>;
  Future<void> logout(String t)async{await call('POST','/auth/logout',{'refreshToken':t});}
  Future<List<dynamic>> cases({String q='',String? category,String? country})async{final params=<String,String>{if(q.isNotEmpty)'q':q,if(category!=null)'category':category,if(country!=null)'country':country};final qs=params.isEmpty?'':'?${Uri(queryParameters:params).query}';return await call('GET','/cases$qs') as List<dynamic>;}
  Future<List<dynamic>> mine()async=>await call('GET','/cases/mine') as List<dynamic>;
  Future<Map<String,dynamic>> createCase(Map<String,dynamic> data)=>call('POST','/cases',data) as Future<Map<String,dynamic>>;
  Future<List<dynamic>> offers({String? country})async=>await call('GET','/offers${country==null?'':'?country=$country'}') as List<dynamic>;
  Future<Map<String,dynamic>> createOffer(Map<String,dynamic> data)=>call('POST','/offers',data) as Future<Map<String,dynamic>>;
  Future<List<dynamic>> threads()async=>await call('GET','/messages/threads') as List<dynamic>;
  Future<List<dynamic>> threadMessages(String id)async=>await call('GET','/messages/threads/$id') as List<dynamic>;
  Future<Map<String,dynamic>> sendMessage(String id,String body)=>call('POST','/messages/threads/$id',{'body':body}) as Future<Map<String,dynamic>>;
  Future<List<dynamic>> notifications()async=>await call('GET','/notifications') as List<dynamic>;
  Future<Map<String,dynamic>> countryOperations(String countryCode)=>call('GET','/country-operations/public/$countryCode') as Future<Map<String,dynamic>>;
  Future<List<dynamic>> securityEvents()async=>await call('GET','/security/events') as List<dynamic>;
  Future<List<dynamic>> sessions()async=>await call('GET','/users/sessions') as List<dynamic>;
  Future<Map<String,dynamic>> profile()=>call('GET','/users/profile') as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> setupMfa()=>call('POST','/auth/mfa/setup') as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> enableMfa(String code)=>call('POST','/auth/mfa/enable',{'code':code}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> disableMfa(String code)=>call('POST','/auth/mfa/disable',{'code':code}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> verifyEmail(String token)=>call('POST','/auth/verify-email',{'token':token}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> report(String type,String description,{String? caseId})=>call('POST','/reports',{'type':type,'description':description,if(caseId!=null)'caseId':caseId}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> createPaymentIntent(String caseId,int amountMinor,String currency,{String? purpose,String? idempotencyKey})=>call('POST','/payments/intents',{'caseId':caseId,'amountMinor':amountMinor,'currency':currency,if(purpose!=null)'purpose':purpose,if(idempotencyKey!=null)'idempotencyKey':idempotencyKey}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> convertCurrency(double amount, String from, String to) => call('GET', '/currency/convert?amount=$amount&from=$from&to=$to') as Future<Map<String,dynamic>>;
  Future<List<dynamic>> myPayments() async => await call('GET','/payments/mine') as List<dynamic>;
  Future<Map<String,dynamic>?> payoutDestination() async {
    final value = await call('GET', '/payments/payout-destination');
    return value is Map<String, dynamic> ? value : null;
  }
  Future<Map<String,dynamic>> savePayoutDestination(String phone) => call('POST','/payments/payout-destination',{'countryCode':'KE','method':'MPESA','phone':phone}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> impact() async => await call('GET','/impact/me') as Map<String,dynamic>;
  Future<Map<String,dynamic>> markNotificationRead(String id) async => await call('PATCH','/notifications/$id/read') as Map<String,dynamic>;
  Future<Map<String,dynamic>> requestVerification(String caseId,{String? reason})=>call('POST','/verification/cases/$caseId/request',{'reason':reason}) as Future<Map<String,dynamic>>;
  Future<Map<String,dynamic>> createReferral(Map<String,dynamic> data)=>call('POST','/referrals',data) as Future<Map<String,dynamic>>;
}

