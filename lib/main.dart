import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LaunchScreen());
  }
}

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: 'Introduce la IP',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.0),
                      borderSide: const BorderSide(color: Colors.grey))),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const MyHomePage(
                            title: '',
                          )));
                },
                child: const Text('Continuar'))
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.ip});
  final String? ip;

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Message {
  bool own;
  String msg;
  Message(this.own, this.msg);
}

class _MyHomePageState extends State<MyHomePage> {
  List<Message> messages = [];
  late RawDatagramSocket socket;
  @override
  void initState() {
    super.initState();
    startSocket();
  }

  Future<void> startSocket() async {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 16001)
        .catchError((err, st) {
      print(err);
    });

    socket.listen((event) async {
      final dg = socket.receive();
      if (dg != null) {
        final read = String.fromCharCodes(dg.data);
        setState(() {
          messages.add(Message(false, read));
        });
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  final controller = TextEditingController();
  final focus = FocusNode();
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(10.0),
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                    itemCount: messages.length,
                    // shrinkWrap: true,
                    // primary: false,
                    itemBuilder: (ctx, i) {
                      final msg = messages[i];
                      if (msg.own) {
                        return _OwnMessage(msg: msg);
                      }
                      return _OtherMessage(msg: msg);
                    })),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.black)),
                    suffix: InkWell(
                      onTap: () {
                        //socket
                        print('IP ${widget.ip}');
                        int send = socket.send(controller.text.codeUnits,
                            InternetAddress(widget.ip ?? '127.0.0.1'), 16000);
                        print('SEND: $send');
                        setState(() {
                          messages.add(Message(true, controller.text));
                          controller.clear();
                        });
                        scrollController.jumpTo(
                            scrollController.position.maxScrollExtent);
                      },
                      child: const Icon(Icons.send),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherMessage extends StatelessWidget {
  const _OtherMessage({
    super.key,
    required this.msg,
  });

  final Message msg;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width * 0.31,
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(msg.msg),
        ),
      ),
    );
  }
}

class _OwnMessage extends StatelessWidget {
  const _OwnMessage({
    super.key,
    required this.msg,
  });

  final Message msg;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: width * 0.31,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            color: Colors.teal, borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(
            msg.msg,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class SendIntent extends Intent {}

class SendAction extends Action<SendIntent> {
  @override
  void invoke(SendIntent intent) {}
}
