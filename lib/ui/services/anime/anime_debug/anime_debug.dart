import 'package:flutter/material.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_player.dart';

class AnimeDebug extends StatelessWidget {
  const AnimeDebug({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 48,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.iframeAnimePlayer,
                      arguments: const AnimeIframePlayerData(
                          src: "https://ashdi.vip/vod/52812"));
                },
                child: const Text("Iframe player"))
          ],
        ),
      ),
    );
  }
}
