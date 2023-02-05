import 'package:flutter/material.dart';
import 'package:wakaranai/ui/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/routes.dart';

class AnimeDebug extends StatelessWidget {
  const AnimeDebug({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 48,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.iframeAnimePlayer,
                      arguments: AnimeIframePlayerData(
                          src: "https://ashdi.vip/vod/52812"));
                },
                child: Text("Iframe player"))
          ],
        ),
      ),
    );
  }
}
