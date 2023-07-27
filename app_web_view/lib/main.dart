import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _controller;
  late TextEditingController _editingController;

  final Set<String> _urlHistory = {};

  String _url = 'https://flutter.dev/';



  @override
  void initState() {
    super.initState();
    _url = 'https://flutter.dev/';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (_urlHistory.length > 5) _urlHistory.remove(_urlHistory.last);
            log(url);
            _urlHistory.add(url);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
    _editingController = TextEditingController(text: _url);
    _urlHistory.add(_url);
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  goToPage(String url) async {
    if(!(url.contains('https://') || url.contains('http://'))){
      _url = 'https://$url';
    }
    log(_url);
    _editingController.text = _url;
    await _controller.loadRequest(Uri.parse(_url));
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.grey.withOpacity(0.4),
              height: 60,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        await _controller.goBack();
                      },
                      icon: const Icon(Icons.arrow_back)),
                  IconButton(
                      onPressed: () async {
                        await _controller.goForward();
                      },
                      icon: const Icon(Icons.arrow_forward)),
                  IconButton(
                      onPressed: () async {}, icon: const Icon(Icons.refresh)),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _editingController,
                      maxLines: 1,
                      minLines: 1,
                      onFieldSubmitted: goToPage,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.history),
                    onSelected: goToPage,
                    itemBuilder: (BuildContext context) {
                      return _urlHistory.map((String choice) {
                        log(choice);
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice, overflow: TextOverflow.ellipsis,),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}