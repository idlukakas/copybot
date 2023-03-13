import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  String _noHeartEmojiText = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldKey,
      title: 'Remover as linhas dos emojis ✅-❌',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Remover as linhas dos emojis'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.share,
                color: Colors.white,
              ),
              onPressed: () {
                sendTextToTelegram(message: _noHeartEmojiText.trimRight());
              },
            )
          ],
        ),
        body: Center(
          child: ListView(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              children: [
              ElevatedButton(
                onPressed: () async {
                  // Remover os emojis de coração do texto da área de transferência
                  String? noHeartEmojiText = await removeHeartEmojisFromClipboard();

                  // Colocar o texto sem os emojis de volta na área de transferência
                  await Clipboard.setData(ClipboardData(text: noHeartEmojiText));

                  // Exibir uma mensagem para o usuário
                  _scaffoldKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Linhas com os emojis removidos! Texto copiado'),
                    ),
                  );

                  // Atualizar o texto na tela
                  setState(() {
                    _noHeartEmojiText = noHeartEmojiText!.trimRight();
                  });

                },
                child: const Text('Tirar as linhas com emoji ✅-❌'),
              ),
              const SizedBox(height: 16),
              FutureBuilder<String?>(
                future: removeHeartEmojisFromClipboard(),
                builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data!);
                  } else {
                    return Container();
                  }
                },
              ),
            ]
          ),
      ),
    ),
    );
  }
}

Future<String?> removeHeartEmojisFromClipboard() async {
  // Obter o texto da área de transferência
  String? clipboardData = (await Clipboard.getData('text/plain'))?.text;

  // Remover os emojis de coração usando uma expressão regular
  String? noHeartEmojiText = clipboardData?.replaceAll(RegExp(r'.*[✅-❌](\r\n)?', multiLine: true), '');

  Clipboard.setData(ClipboardData(text: noHeartEmojiText));

  // Retornar o texto sem os emojis de coração
  return noHeartEmojiText;
}

void sendTextToTelegram({ String username = 'flash_kbot', required String message}) async {
  String url() {
    if (Platform.isAndroid || Platform.isWindows) {
      return "tg://msg_url?url=${Uri.encodeQueryComponent(message)}";
    } else {
      // return "https://t.me/$username?text=${Uri.parse(message)}";
      return "https://t.me/share?url=${Uri.encodeQueryComponent(message)}";
    }
  }
  if (await canLaunchUrl(Uri.parse(url()))) {
    print("https://wa.me/$username/?text=$message");
    await launchUrl(Uri.parse(url()));
  } else {
    throw 'Could not launch ${url()}';
  }
}