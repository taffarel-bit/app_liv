import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

String formatarData(DateTime data) {
  return DateFormat('dd/MM/yyyy').format(data);
}

const Map<int, Color> color = {
  50: Color.fromRGBO(31, 35, 35, .1),
  100: Color.fromRGBO(31, 35, 35, .2),
  200: Color.fromRGBO(31, 35, 35, .3),
  300: Color.fromRGBO(31, 35, 35, .4),
  400: Color.fromRGBO(31, 35, 35, .5),
  500: Color.fromRGBO(31, 35, 35, .6),
  600: Color.fromRGBO(31, 35, 35, .7),
  700: Color.fromRGBO(31, 35, 35, .8),
  800: Color.fromRGBO(31, 35, 35, .9),
  900: Color.fromRGBO(46, 60, 60, 1),
};
const MaterialColor customColor = MaterialColor(0xFF1F2323, color);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Requisições',
      theme: ThemeData(
        primarySwatch: customColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color.fromARGB(255, 58, 58, 57),
        ),
      ),
      home: RequisicoesPage(),
    );
  }
}

class Requisicao {
  String titulo;
  DateTime dataCriacao;
  String descricaoDetalhada;
  String status;
  String aFirma; // Campo para assinatura
  String beneficiario; // Campo para beneficiário

  Requisicao({
    required this.titulo,
    required this.dataCriacao,
    this.descricaoDetalhada = '',
    this.status = 'Pendente',
    this.aFirma = '',
    this.beneficiario = '', // Inicialização
  });
}

class RequisicoesPage extends StatefulWidget {
  @override
  _RequisicoesPageState createState() => _RequisicoesPageState();
}

class _RequisicoesPageState extends State<RequisicoesPage> {
  List<Requisicao> requisicoes = [];
  String searchQuery = '';

  void _addRequisicao() {
    setState(() {
      final novaRequisicao = Requisicao(
        titulo: 'Requisição Nº ${requisicoes.length + 1}',
        dataCriacao: DateTime.now(),
      );
      requisicoes.add(novaRequisicao);
      _openRequisicao(novaRequisicao); // Abrir a requisição automaticamente
    });
  }

  void _openRequisicao(Requisicao requisicao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesRequisicao(requisicao: requisicao),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequisicoes = requisicoes.where((requisicao) {
      return requisicao.titulo
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Requisições'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar requisições...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredRequisicoes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredRequisicoes[index].titulo),
            subtitle: Text(
              'Data: ${formatarData(filteredRequisicoes[index].dataCriacao)}',
            ),
            onTap: () => _openRequisicao(filteredRequisicoes[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRequisicao,
        tooltip: 'Adicionar Requisição',
        child: Icon(Icons.add),
      ),
    );
  }
}

class DetalhesRequisicao extends StatefulWidget {
  final Requisicao requisicao;

  DetalhesRequisicao({required this.requisicao});

  @override
  _DetalhesRequisicaoState createState() => _DetalhesRequisicaoState();
}

class _DetalhesRequisicaoState extends State<DetalhesRequisicao> {
  final _formKey = GlobalKey<FormState>();
  late String _descricao;
  late String _status;
  late String _aFirma;
  late String _beneficiario;

  @override
  void initState() {
    super.initState();
    setState(() {
      _descricao = widget.requisicao.descricaoDetalhada;
      _status = widget.requisicao.status;
      _aFirma = widget.requisicao.aFirma;
      _beneficiario = widget.requisicao.beneficiario;
    });
  }

  void _imprimirRequisicao() async {
    final pdf = pw.Document();

    final robotoRegularData =
        await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final robotoBoldData =
        await rootBundle.load("assets/fonts/Roboto-Bold.ttf");

    final robotoRegular = pw.Font.ttf(robotoRegularData);
    final robotoBold = pw.Font.ttf(robotoBoldData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(color: PdfColors.black, width: 2),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'LIV TORNEARIA',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 24, font: robotoBold),
                      ),
                      pw.Text(
                        'Serviços especializados em Torno, Solda, Prensa, Ferraria e Consertos em geral',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10, font: robotoRegular),
                      ),
                      pw.Text(
                        'Assistência técnica agrícola e industrial',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10, font: robotoRegular),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'CNPJ: 44.465.208/0001-51',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 14, font: robotoRegular),
                      ),
                      pw.Text(
                        'FONES:(67)998572534 / 99694062 / 99985-7908 / 99918-3834',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10, font: robotoRegular),
                      ),
                      pw.Text(
                        'RUA BENJAMIN CONSTANT, 1964, CEP79130-000, RIO BRILHANTE-MS',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10, font: robotoRegular),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(color: PdfColors.black, width: 2),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        ' ${widget.requisicao.titulo}',
                        style: pw.TextStyle(fontSize: 24, font: robotoBold),
                      ),
                      pw.Text(
                        'Data de Criação: ${formatarData(widget.requisicao.dataCriacao)}',
                        style: pw.TextStyle(font: robotoRegular),
                      ),
                      pw.Text(
                        'À firma: $_aFirma', // Campo "À firma" abaixo de "Data de Criação"
                        style: pw.TextStyle(font: robotoRegular),
                      ),
                      pw.Text(
                        'Descrição Detalhada: $_descricao',
                        style: pw.TextStyle(font: robotoRegular),
                      ),
                      pw.Text(
                        'Beneficiário: $_beneficiario', // Campo "Beneficiário"
                        style: pw.TextStyle(font: robotoRegular),
                      ),
                      pw.Text(
                        'Assinatura: $_status',
                        style: pw.TextStyle(font: robotoRegular),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      print("Erro ao tentar imprimir: $e");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    print('Current values - À Firma: $_aFirma, Beneficiário: $_beneficiario');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requisicao.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _imprimirRequisicao,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo "À Firma"
              TextFormField(
                initialValue: _aFirma,
                decoration: InputDecoration(
                  labelText: 'À Firma',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _aFirma = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Campo "Descrição Detalhada"
              TextFormField(
                initialValue: _descricao,
                decoration: InputDecoration(
                  labelText: 'Descrição Detalhada',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _descricao = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Campo "Beneficiário"
              TextFormField(
                initialValue: _beneficiario,
                decoration: InputDecoration(
                  labelText: 'Beneficiário',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _beneficiario = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Campo "Assinatura"
              DropdownButtonFormField<String>(
                value: _status,
                items: [
                  'Luis V. Taffarel',
                  'Isidro Portilho Ajarve',
                  'Juliana Meazza',
                  'Valeria S. Rocha',
                  'Pendente'
                ]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Assinatura',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print('Salvar pressionado');
                  setState(() {
                    widget.requisicao.descricaoDetalhada = _descricao;
                    widget.requisicao.status = _status;
                    widget.requisicao.aFirma = _aFirma;
                    widget.requisicao.beneficiario = _beneficiario;
                  });
                  print(
                      'Campos atualizados: À Firma: $_aFirma, Beneficiário: $_beneficiario');
                  Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
