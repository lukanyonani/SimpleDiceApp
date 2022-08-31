import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:simple_dice_app/ad_state.dart';
import 'dart:math';
// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:simple_dice_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);


  runApp(Provider.value(
      value: adState,
      builder: (context, child) => const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  // Ads
  late BannerAd banner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState> (context);
    adState.initialization.then((status) {
      setState((){
        banner = BannerAd(
          adUnitId: adState.bannerAdUnitId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: const BannerAdListener(),
        )..load();
      });
    });

  }

  // App Vars
  int clickCount = 0;
  int leftDiceNumber = 1;
  int rightDiceNumber = 1;
  // Roll Dice Function
  void rollDice() {
    setState((){
      leftDiceNumber = Random().nextInt(6) + 1;
      rightDiceNumber = Random().nextInt(6) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 2,
        title: const Text('Dicey', style: TextStyle(color: Colors.white), ),
        centerTitle: true,
      ),
      body: content(),
      floatingActionButton:  Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.white,
          foregroundColor: Colors.lightBlueAccent,
          elevation: 0,
          icon: const Icon(
            Icons.scatter_plot,
          ),
          label: const Text('Roll'),
          onPressed: () {
            rollDice();
          },
        ),
      ),
    );
  }

  Column content() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // First Dice
                  Expanded(child: TextButton(
                      onPressed: () {
                        setState((){
                          leftDiceNumber = Random().nextInt(6) + 1;
                        });
                      },
                      child: Image.asset('assets/images/dice$leftDiceNumber.png')),
                  ),
                  // First Dice
                  Expanded(child: TextButton(
                    onPressed: () {
                      setState(() {
                        rightDiceNumber = Random().nextInt(6) + 1;
                      });
                    },
                    child: Image.asset('assets/images/dice$rightDiceNumber.png'),
                  )),
                ],
              ),
            ),
          ),
        ),
        if (banner == null)
          const SizedBox(height: 50)
        else
          SizedBox(
            height: 50,
            child: AdWidget(ad: banner,),
          )
      ],
    );
  }

}

