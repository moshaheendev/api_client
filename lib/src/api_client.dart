import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;


class ApiClient{

  static final ApiClient _singleton=ApiClient._internal();
  factory ApiClient(){
    return _singleton;
  }
  ApiClient._internal();

  static String? _baseURL;
  static String? _token;
  final http.Client _client=http.Client();

  static init({String? baseUrl,String? token}){
    _baseURL=baseUrl;
    _token=token;
  }

  Map<String,String> _headers(){
    Map<String,String> headers={
      'Content-Type':'application/json',
      'Authorization':'Bearer $_token'
    };
    return headers;
  }

  void get({
    required String endpoint,
    required Function(Map response) onSuccess,
    required Function(Map response)onError
  })async{
    try{
      final http.Response response=await _client.get(Uri.parse(_baseURL!+endpoint),headers: _headers());
      _handleResponse(response: response,onSuccess: onSuccess, onError: onError);
    }on http.ClientException catch(e) {
      onError({"error":e.message});
    }catch(e){
      onError({"error":e.toString()});
    }
  }

  void post({
    required String endpoint,
    Map body=const{},
    required Function(Map response) onSuccess,
    required Function(Map response)onError
  })async{
    try{
      final http.Response response=await _client.post(Uri.parse(_baseURL!+endpoint),body: jsonEncode(body),headers: _headers());
      _handleResponse(response: response,onSuccess: onSuccess, onError: onError);
    }on http.ClientException catch(e) {
      onError({"error":e.message});
    }catch(e){
      onError({"error":e.toString()});
    }
  }

  void postMultipart({
    required String endpoint,
    Map body=const{},
    Map<String,File> files=const{},
    required Function(Map response) onSuccess,
    required Function(Map response)onError
  })async{
    try{
      final http.MultipartRequest multipartRequest= http.MultipartRequest('POST',Uri.parse(_baseURL!+endpoint));
      multipartRequest.headers.addAll(_headers());
      body.forEach((key, value) {
        multipartRequest.fields[key]=value;
      });
      files.forEach((key,file) async{
        var multipartFile= await http.MultipartFile.fromPath(key,file.path);
        multipartRequest.files.add(multipartFile);
      });
      final http.StreamedResponse streamedResponse=await multipartRequest.send();
      final http.Response response=await http.Response.fromStream(streamedResponse);
      _handleResponse(response: response,onSuccess: onSuccess, onError: onError);
    }on http.ClientException catch(e) {
      onError({"error":e.message});
    }catch(e){
      onError({"error":e.toString()});
    }
  }

  void patch({
    required String endpoint,
    dynamic body,
    required Function(Map response) onSuccess,
    required Function(Map response)onError
  })async{
    try{
      final http.Response response=await _client.patch(Uri.parse(_baseURL!+endpoint),body: jsonEncode(body),headers: _headers());
      _handleResponse(response: response,onSuccess: onSuccess, onError: onError);
    }on http.ClientException catch(e) {
      onError({"error":e.message});
    }catch(e){
      onError({"error":e.toString()});
    }
  }

  void put({
    required String endpoint,
    Map body=const{},
    required Function(Map response) onSuccess,
    required Function(Map response)onError
  })async{
    try{
      final http.Response response=await _client.put(Uri.parse(_baseURL!+endpoint),body:jsonEncode(body),headers: _headers());
      _handleResponse(response: response,onSuccess: onSuccess, onError: onError);
    }on http.ClientException catch(e) {
      onError({"error":e.message});
    }catch(e){
      onError({"error":e.toString()});
    }
  }

  void delete({
    required String endpoint,
    required Function(Map response) onSuccess,
    required Function(Map response)onError
  })async{
    try{
      final http.Response response=await _client.delete(Uri.parse(_baseURL!+endpoint),headers: _headers());
      _handleResponse(response: response,onSuccess: onSuccess, onError: onError);
    }on http.ClientException catch(e) {
      onError({"error":e.message});
    }catch(e){
      onError({"error":e.toString()});
    }
  }

  void _handleResponse({required dynamic response,required Function(Map response) onSuccess,required Function(Map response) onError}){
    if(response.statusCode>=200&&response.statusCode<300){
      onSuccess(json.decode(utf8.decode(response.bodyBytes)));
    }else{
      onError(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

}