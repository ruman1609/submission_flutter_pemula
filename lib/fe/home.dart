import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:submission_dasar_github/be/repositories.dart';
import 'package:submission_dasar_github/fe/detail.dart';
import 'package:submission_dasar_github/model/user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < 600) {
        return const HomeScreenMobile();
      } else if (constraints.maxWidth < 1100) {
        return const HomeScreenMobOrWeb(isMobile: true);
      } else {
        return const HomeScreenMobOrWeb(isMobile: false);
      }
    });
  }
}

class ErrorText extends StatelessWidget {
  final String _errorText;

  const ErrorText(this._errorText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(_errorText,
      style: const TextStyle(
          fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center);
}

class InformationText extends StatelessWidget {
  final bool _isEmpty;

  const InformationText({bool isEmpty = false, Key? key})
      : _isEmpty = isEmpty,
        super(key: key);

  @override
  Widget build(BuildContext context) => Text(
      _isEmpty
          ? "Results not found"
          : "Type your search username in Search Box",
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center);
}

mixin SearchCommand<T extends StatefulWidget> on State<T> {
  final IRepositories _repo = NetworkRepositories();
  final List<User> _users = [];
  StreamSubscription<List<User>>? _sub;
  String _errText = "";
  bool _isErr = false;
  bool _isSearching = false;

  void doSearch(String text) {
    if (text == "") return;
    setState(() => _isSearching = true);
    if (_sub != null) {
      log("Cancelled");
      _sub!.cancel();
    }
    _sub = _repo.getSearchUser(text).asStream().listen((List<User> newList) {
      setState(() {
        _isSearching = true;
        _users.clear();
        _users.addAll(newList);
        _isErr = false;
        _isSearching = false;
      });
    });
    _sub?.onError((err, st) {
      setState(() {
        _isSearching = false;
        _isErr = true;
        _errText =
            "$err\nTry to restart the app or search with another keyword";
      });
      log("$err\n$st");
    });
    log("${_users.length} search: $text");
  }
}

class _GitUserList extends StatefulWidget {
  final User _user;

  const _GitUserList(this._user, {Key? key}) : super(key: key);

  @override
  State<_GitUserList> createState() => _GitUserListState();
}

class _GitUserListState extends State<_GitUserList> with SearchCommand {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          try {
            setState(() => widget._user.isLoading = true);
            User detailUser = await _repo.getDetailUser(widget._user.username);
            setState(() {
              _isErr = false;
              widget._user.isLoading = false;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailScreen(user: detailUser)));
          } catch (err, st) {
            log("$err\n$st");
            setState(() {
              _errText = "$err";
              _isErr = true;
              widget._user.isLoading = false;
            });
          }
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                    child: Hero(
                  tag: widget._user.id,
                  child: ClipOval(
                    child: Image.network(widget._user.picUrl),
                  ),
                )),
                const SizedBox(width: 16),
                Expanded(
                    flex: 2,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget._user.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("${widget._user.id}",
                              style: const TextStyle(color: Colors.grey)),
                          if (widget._user.isLoading)
                            const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ))
                        ]))
              ],
            ),
          ),
        ));
  }
}

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({Key? key}) : super(key: key);

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile>
    with SearchCommand {
  final TextEditingController _controller = TextEditingController();
  String _lastInput = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Github Search")),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: _controller,
              onChanged: (String? text) {
                if (_lastInput != text!) {
                  setState(() => _lastInput = text);
                  doSearch(_controller.text);
                }
              },
              decoration: InputDecoration(
                  hintText: "Type GitHub Username here",
                  prefixIcon: const Icon(Icons.search),
                  labelText: "Search (Username)",
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.black, width: 2)),
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  suffixIcon: IconButton(
                      onPressed: _controller.clear,
                      icon: const Icon(Icons.close)))),
          const SizedBox(height: 16),
          _isSearching
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
              : (_isErr)
                  ? ErrorText(_errText)
                  : (_controller.text.isEmpty || _users.isEmpty)
                      ? InformationText(
                          isEmpty:
                              (_users.isEmpty && _controller.text.isNotEmpty))
                      : Flexible(
                          child: ListView.builder(
                              shrinkWrap:
                                  true, // shrinkwrap true mesti pake Flexible
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) =>
                                  _GitUserList(_users[index]),
                              itemCount: _users.length),
                        )
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _GitUserGrid extends StatefulWidget {
  final User _user;

  const _GitUserGrid(this._user, {Key? key}) : super(key: key);

  @override
  State<_GitUserGrid> createState() => _GitUserGridState();
}

class _GitUserGridState extends State<_GitUserGrid> with SearchCommand {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () async {
          try {
            setState(() => widget._user.isLoading = true);
            User detailUser = await _repo.getDetailUser(widget._user.username);
            setState(() {
              _isErr = false;
              widget._user.isLoading = false;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailScreen(user: detailUser)));
          } catch (err, st) {
            log("$err\n$st");
            setState(() {
              _errText = "$err";
              _isErr = true;
              widget._user.isLoading = false;
            });
          }
        },
        child: Card(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: ClipOval(
                    child: Image.network(widget._user.picUrl,
                        fit: BoxFit.cover, width: 200),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget._user.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("${widget._user.id}",
                            style: const TextStyle(color: Colors.grey))
                      ],
                    )),
                    if (widget._user.isLoading)
                      const Flexible(
                          child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              )))
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}

class HomeScreenMobOrWeb extends StatefulWidget {
  final bool _isMobile;

  const HomeScreenMobOrWeb({required bool isMobile, Key? key})
      : _isMobile = isMobile,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenMobOrWebState();
}

class _HomeScreenMobOrWebState extends State<HomeScreenMobOrWeb>
    with SearchCommand {
  final TextEditingController _controller = TextEditingController();
  String _lastInput = "";

  @override
  Widget build(BuildContext context) {
    int count = (widget._isMobile) ? 4 : 7;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Github Search",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: _controller,
                  onChanged: (String? text) {
                    if (_lastInput != text!) {
                      setState(() => _lastInput = text);
                      doSearch(_controller.text);
                    }
                  },
                  decoration: InputDecoration(
                      hintText: "Type GitHub Username here",
                      prefixIcon: const Icon(Icons.search),
                      labelText: "Search (Username)",
                      focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide:
                              BorderSide(color: Colors.black, width: 2)),
                      enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey, width: 2)),
                      suffixIcon: widget._isMobile
                          ? IconButton(
                              onPressed: _controller.clear,
                              icon: const Icon(Icons.close))
                          : null)),
              const SizedBox(height: 16),
              _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black)),
                    )
                  : (_isErr)
                      ? ErrorText(_errText)
                      : (_controller.text.isEmpty || _users.isEmpty)
                          ? InformationText(
                              isEmpty: (_users.isEmpty &&
                                  _controller.text.isNotEmpty))
                          : Expanded(
                              child: Scrollbar(
                                scrollbarOrientation:
                                    ScrollbarOrientation.right,
                                isAlwaysShown: true,
                                child: GridView.count(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  crossAxisCount: count,
                                  children: _users
                                      .map((user) => _GitUserGrid(user))
                                      .toList(),
                                ),
                              ),
                            )
            ],
          ),
        ));
  }
}
