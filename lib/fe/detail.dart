import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:submission_dasar_github/model/user.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  final User _user;

  const DetailScreen({required User user, Key? key})
      : _user = user,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < 800) {
        return DetailScreenMobile(user: _user);
      } else {
        return DetailScreenWeb(_user);
      }
    });
  }
}

class DetailMobileHeader extends StatelessWidget {
  final User _user;

  const DetailMobileHeader(this._user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle rowTitle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 32, left: 48, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Hero(
                  tag: _user.id,
                  child: ClipOval(
                      child: Image.network(_user.picUrl,
                          fit: BoxFit.cover, width: 100))),
              Row(
                  children: {
                "Repos": _user.publicRepos,
                "Followers": _user.followers,
                "Following": _user.following
              }.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  child: Column(children: [
                    Text(e.key, style: rowTitle),
                    Text(
                      "${e.value}",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                  ]),
                );
              }).toList())
            ],
          ),
          const SizedBox(height: 8),
          if (_user.name != "")
            Text(_user.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white)),
          const SizedBox(height: 8),
          if (_user.location != "")
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _user.location,
                  style: const TextStyle(color: Colors.white),
                )
              ],
            )
        ],
      ),
    );
  }
}

class DetailBody extends StatelessWidget {
  final User _user;
  final bool _isMobile;

  const DetailBody(this._user, {bool isMobile = true, Key? key})
      : _isMobile = isMobile,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = _isMobile ? 16 : 24;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("You can see detail about this user by",
                style: !_isMobile ? const TextStyle(fontSize: 20) : null),
            TextButton(
                onPressed: () async {
                  try {
                    await launch(Uri.encodeFull(_user.link));
                  } catch (err, st) {
                    log("$err\n$st");
                    ScaffoldMessengerState snackbar =
                        ScaffoldMessenger.of(context);
                    snackbar.showSnackBar(SnackBar(
                        content: const Text("Something wrong"),
                        duration: const Duration(seconds: 5),
                        action: SnackBarAction(
                          onPressed: () => snackbar.hideCurrentSnackBar(),
                          label: "Dismiss",
                          textColor: Colors.red,
                        )));
                  }
                },
                child: Text(
                  "Click here",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: size,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }
}

class DetailScreenMobile extends StatelessWidget {
  final User _user;

  const DetailScreenMobile({required User user, Key? key})
      : _user = user,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      double height;
      if (_user.location != "" && _user.name != "") {
        height = 240;
      } else if (_user.location != "" || _user.name != "") {
        height = 200;
      } else {
        height = 180;
      }
      return [
        SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              expandedHeight: height,
              flexibleSpace: FlexibleSpaceBar(
                  title: Text(_user.username),
                  background: DetailMobileHeader(_user)),
              forceElevated: innerBoxScrolled,
              pinned: true,
            ))
      ];
    }, body: Builder(builder: (BuildContext context) {
      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => DetailBody(_user),
                childCount: 1),
          )
        ],
      );
    })));
  }
}

class DetailWebHeader extends StatelessWidget {
  final User _user;

  const DetailWebHeader(this._user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
            tag: _user.id,
            child: ClipOval(
                child: Image.network(_user.picUrl,
                    fit: BoxFit.cover, width: 200))),
        const SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                children: {
              "Repos": _user.publicRepos,
              "Followers": _user.followers,
              "Following": _user.following
            }.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(children: [
                  Text(e.key,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    "${e.value}",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  )
                ]),
              );
            }).toList()),
            if (_user.name != "") const SizedBox(height: 32),
            if (_user.name != "")
              Text(_user.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
            if (_user.name != "") const SizedBox(height: 32),
            if (_user.location != "")
              Row(children: [
                const Icon(Icons.location_on_rounded, color: Colors.black),
                const SizedBox(width: 8),
                Text(_user.location)
              ]),
          ],
        )
      ],
    );
  }
}

class DetailScreenWeb extends StatelessWidget {
  final User _user;

  const DetailScreenWeb(this._user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Scrollbar(
        isAlwaysShown: true,
        scrollbarOrientation: ScrollbarOrientation.right,
        child: Padding(
            padding: const EdgeInsets.all(32),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _user.username,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              DetailWebHeader(_user),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Colors.black),
              DetailBody(_user, isMobile: false)
            ])),
      ),
    ));
  }
}
