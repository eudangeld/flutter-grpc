// @dart = 2.8

import 'package:flutter/material.dart';
import 'package:fluttergrpc/generated/helloworld.pbgrpc.dart';
import 'package:grpc/grpc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter and GRPC',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter grpc client '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title});
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _received = 'Nothing received yet';

  Future<void> grpcGreetings() async {
    final channel = ClientChannel(
      'localhost',
      port: 50051,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        codecRegistry:
            CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
      ),
    );
    final stub = GreeterClient(channel);

    final name = 'world';

    try {
      final response = await stub.sayHello(
        HelloRequest()..name = name,
        options: CallOptions(compression: const GzipCodec()),
      );
      setState(() {
        _received = response.message;
      });
    } catch (e) {
      setState(() {
        _received = 'Error, check if u started the server before this call';
      });
    }
    await channel.shutdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
                child: Text('Push on GRPC server'), onPressed: grpcGreetings),
            Text(_received)
          ],
        ),
      ),
    );
  }
}
