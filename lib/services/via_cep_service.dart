import 'package:search_cep/models/result_cep.dart';
import 'package:http/http.dart' as http;
class ViaCepService {
  static Future<ResultCep> fetchCep({String cep,String logradouro, String bairro, String localidade, String uf}) async {
    final response = await http.get('https://viacep.com.br/ws/$cep/json/');
    if (response.statusCode == 200) {
      return ResultCep.fromJson(response.body);
    } else{
      throw Exception(NoSuchMethodError);
    }
    
  }
}
