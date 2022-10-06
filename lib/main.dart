import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telephony/telephony.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SMS Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({@required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum Type { num, text, tel }
List<TextEditingController> controls = [
  TextEditingController(),
  TextEditingController()
];
List<SmsMessage> getSMSs = [];

class _MyHomePageState extends State<MyHomePage> {
  final Telephony _telephony = Telephony.instance;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MyInput(index: 0, type: Type.tel),
                  MyInput(index: 1),
                  MaterialButton(
                    onPressed: _sendSMS,
                    color: Colors.red,
                    child: Text("GIT", style: TextStyle(color: Colors.white)),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      getSMSs = await _getSMS();
                      setState(() {});
                    },
                    color: Colors.blue,
                    child: Text("Gör", style: TextStyle(color: Colors.white)),
                  ),
                  Column(
                    children: List.generate(
                        getSMSs.length,
                        (index) => ListTile(
                              leading: Text(
                                getSMSs[index].body,
                                style: TextStyle(color: Colors.black),
                              ),
                            )),
                  )
                ],
              ),
            )));
  }

  _sendSMS() async {
    _telephony.sendSms(to: controls[0].text, message: controls[1].text);
  }

  Future<List<SmsMessage>> _getSMS() async {
    List<SmsMessage> _mesages = await _telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
      filter: SmsFilter.where(SmsColumn.ADDRESS).equals(controls[0].text),
    );
    for (var msg in _mesages) {
      print("${msg.body} * ${msg.address}");
    }
    print("Last***${_mesages[0].body}***");
    return _mesages;
  }
}

class MyInput extends StatefulWidget {
  final Type type;
  final int index;
  MyInput({this.index = 0, this.type = Type.text});

  @override
  _MyInputState createState() => _MyInputState();
}

class _MyInputState extends State<MyInput> {
  @override
  void initState() {
    // TODO: implement initState
    if (controls.length < widget.index + 1) {
      controls.add(TextEditingController());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: TextFormField(
          controller: controls[widget.index],
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
          ),
          keyboardType: widget.type == Type.text
              ? TextInputType.text
              : widget.type == Type.num
                  ? TextInputType.number
                  : TextInputType.phone,
        ));
  }
}
