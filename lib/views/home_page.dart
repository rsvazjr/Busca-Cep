import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:search_cep/models/result_cep.dart';
import 'package:search_cep/services/via_cep_service.dart';
import 'package:share/share.dart';
import 'package:flushbar/flushbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = '';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Busca CEP'),
        actions: <Widget>[
          IconButton(
            icon: Icon( Theme.of(context).brightness == Brightness.dark ? Icons.brightness_medium : Icons.brightness_medium),
            onPressed: () {
              changeBrightness();
            },
          ),
          Builder(
            builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
               final RenderBox box = context.findRenderObject();
                              Share.share(text,
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
              },
            
          );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSearchCepTextField(),
              _buildSearchLogradouroTextField(),
              _buildSearchBairroTextField(),
              _buildSearchLocalidadeTextField(),
              _buildSearchUFTextField(),
              _buildSearchCepButton(),
              _buildCleanButton(),
              _buildResultCepText()
            ],
          ),
        ),
      ),
    );
  }

  void resetFields(){
    _searchBairroController.text = '';
    _searchCepController.text = '';
    _searchLocalidadeController.text = '';
    _searchUFController.text = '';
    _searchCepController.text = '';
    _searchLogradouroController.text = '';
    setState(() {
    _resultCep = null; 
    });

    

  }

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }

  ResultCep _resultCep;

  Widget _buildResultCepText() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Text(
       text = _resultCep != null ? _resultCep.toJson() : 'Preencha todos os campos!',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  var _searchCepController = TextEditingController();
  var _searchLogradouroController = TextEditingController();
  var _searchBairroController = TextEditingController();
  var _searchLocalidadeController = TextEditingController();
  var _searchUFController = TextEditingController();
  var _loading = false;

  Widget _buildSearchCepTextField() {
    return TextFormField(
      onSaved: (String value) => setState(() {
                    text = value;
                  }),
      inputFormatters: [
        LengthLimitingTextInputFormatter(8),
        
      ],
      validator: (value) {
        if (value.isEmpty) {
          return 'Preencha corretamente o campo!';
        }else if(value.length < 8){
          return 'O cep necessita no mínimo 8 dígitos';
        }
      },
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'Cep'),
      controller: _searchCepController,
      enabled: !_loading,
    );
  }

  Widget _buildSearchLogradouroTextField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'Endereço'),
      controller: _searchLogradouroController,
      enabled: !_loading,
    );
  }

  Widget _buildSearchBairroTextField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'Bairro'),
      controller: _searchBairroController,
      enabled: !_loading,
    );
  }

  Widget _buildSearchLocalidadeTextField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'Cidade'),
      controller: _searchLocalidadeController,
      enabled: !_loading,
    );
  }

  Widget _buildSearchUFTextField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'UF'),
      controller: _searchUFController,
      enabled: !_loading,
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: RaisedButton(
        onPressed: _validar,
        child: _loading ? _showLoading() : Text('Buscar'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  Widget _buildCleanButton(){
    return  Container(
      height: 17,
    child:FlatButton(
      padding: EdgeInsets.only(left: 2,right: 20),
                onPressed: () {
                  resetFields();
                },
                child: Text(
                  "Limpar Campos",
                  style: TextStyle( fontSize: 15.5),
                ),
    ),
              );
    
  }

  void _validar() async {
    if (_formKey.currentState.validate()) {
      return _searchCep();
    }
    
  }

  void _showFlushBar(BuildContext context) {
    Flushbar(
      title: 'Erro encontrado',
      message: 'CEP Inválido!',
      icon: Icon(
        Icons.info_outline,
        size: 28,
        color: Colors.blue.shade300,
      ),
      duration: Duration(seconds: 3),
    )..show(context);
  }

  Widget _showLoading() {
    return Container(
      width: 15.0,
      height: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  void _searching({bool enable}) {
    setState(() {
      _loading = enable;
    });
  }

  Future _searchCep() async {
    _searching(enable: true);
    final cep = _searchCepController.text;
    final logradouro = _searchLogradouroController.text;
    final bairro = _searchBairroController.text;
    final localidade = _searchLocalidadeController.text;
    final uf = _searchUFController.text;
    try {
      final result = await ViaCepService.fetchCep(
          cep: cep,
          logradouro: logradouro,
          bairro: bairro,
          localidade: localidade,
          uf: uf);

      if (result.cep == null) {
        _showFlushBar(context);
          _searchLogradouroController.text = '';
          _searchUFController.text = '';
          _searchLocalidadeController.text = '';
          _searchBairroController.text = '';
        _resultCep = result;
        _searching(enable: false);
      } else {
        setState(() {
          _resultCep = result;
          _searching(enable: false);
          _searchLogradouroController.text = result.logradouro;
          _searchUFController.text = result.uf;
          _searchLocalidadeController.text = result.localidade;
          _searchBairroController.text = result.bairro;
        });
      }
    }on Exception catch (e) {
      _showFlushBar(context);
      _searching(enable: false);
    }
  }
}
