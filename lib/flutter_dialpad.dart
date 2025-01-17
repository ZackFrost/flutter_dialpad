library flutter_dialpad;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_dtmf/flutter_dtmf.dart';

class DialPad extends StatefulWidget {
  final ValueSetter<String> makeCall;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color dialButtonColor;
  final Color dialButtonIconColor;
  final Color backspaceButtonIconColor;
  final Color dialedNumberColor;
  final String outputMask;
  final bool enableDtmf;
  final bool enableCharacters;
  final bool isExpanded;
  final bool isReadOnly;
  final Widget customWidget;
  final int maxLength;

  DialPad(
      {this.makeCall,
      this.outputMask,
      this.buttonColor,
      this.buttonTextColor,
      this.dialButtonColor,
      this.dialButtonIconColor,
      this.backspaceButtonIconColor,
      this.dialedNumberColor,
      this.enableCharacters = false,
      this.enableDtmf,
      this.isExpanded = false,
      this.customWidget,
      this.isReadOnly = true,
      this.maxLength});

  @override
  _DialPadState createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
  var textEditingController;
  var _value = "";
  var mainTitle = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "＃"];
  var subTitle = ["", "ABC", "DEF", "GHI", "JKL", "MNO", "PQRS", "TUV", "WXYZ", null, "+", null];

  @override
  void initState() {
    textEditingController = TextEditingController();
    // textEditingController = MaskedTextController(
    //     mask: widget.outputMask != null ? widget.outputMask : '(000) 0000000');
    super.initState();
  }

  _setText(String value) async {
    if (widget.enableDtmf == null || widget.enableDtmf) FlutterDtmf.playTone(digits: value);

    setState(() {
      _value += value;
      textEditingController.text = _value;
    });
  }

  List<Widget> _getDialerButtons() {
    var rows = List<Widget>();
    var items = List<Widget>();

    for (var i = 0; i < mainTitle.length; i++) {
      if (i % 3 == 0 && i > 0) {
        rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));
        rows.add(SizedBox(
          height: 12,
        ));
        items = List<Widget>();
      }

      items.add(DialButton(
        title: mainTitle[i],
        subtitle: (widget.enableCharacters || subTitle[i] == "+") ? subTitle[i] : null,
        color: widget.buttonColor,
        textColor: widget.buttonTextColor,
        onTap: _setText,
        onLongPress: _setText,
      ));
    }
    //To Do: Fix this workaround for last row
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));
    rows.add(SizedBox(
      height: 12,
    ));

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09952217;

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: TextFormField(
              readOnly: widget.isReadOnly,
              maxLength: widget.maxLength,
              style: TextStyle(color: widget.dialedNumberColor, fontSize: sizeFactor / 2.4),
              textAlign: TextAlign.center,
              decoration: InputDecoration(border: InputBorder.none),
              controller: textEditingController,
            ),
          ),
          if (widget.customWidget != null) widget.customWidget,
          if (widget.isExpanded)
            Expanded(
              child: Container(),
            ),
          ..._getDialerButtons(),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Expanded(
                child: Center(
                  child: DialButton(
                    icon: Icons.phone,
                    color: Colors.green,
                    onTap: (value) {
                      widget.makeCall(_value);
                    },
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: screenSize.height * 0.03685504),
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.backspace,
                        size: sizeFactor / 2,
                        color:
                            _value.length > 0 ? (widget.backspaceButtonIconColor != null ? widget.backspaceButtonIconColor : Colors.white24) : Colors.white24,
                      ),
                    ),
                    onTap: _value.length == 0
                        ? null
                        : () {
                            if (_value != null && _value.length > 0) {
                              setState(() {
                                _value = _value.substring(0, _value.length - 1);
                                textEditingController.text = _value;
                              });
                            }
                          },
                    onLongPress: _value.length == 0
                        ? null
                        : () {
                            setState(() {
                              textEditingController.clear();
                              _value = "";
                            });
                          }),
              )
            ],
          )
        ],
      ),
    );
  }
}

class DialButton extends StatefulWidget {
  final Key key;
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final ValueSetter<String> onTap;
  final ValueSetter<String> onLongPress;
  final bool shouldAnimate;

  DialButton({this.key, this.title, this.subtitle, this.color, this.textColor, this.icon, this.iconColor, this.shouldAnimate, this.onTap, this.onLongPress});

  @override
  _DialButtonState createState() => _DialButtonState();
}

class _DialButtonState extends State<DialButton> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _colorTween;
  Timer _timer;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _colorTween = ColorTween(begin: widget.color != null ? widget.color : Colors.white24, end: Colors.white).animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.shouldAnimate == null || widget.shouldAnimate && _timer != null) _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;

    return GestureDetector(
      onTap: () {
        if (this.widget.onTap != null) this.widget.onTap(widget.title);

        if (widget.shouldAnimate == null || widget.shouldAnimate) {
          if (_animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
            _timer = Timer(const Duration(milliseconds: 200), () {
              setState(() {
                _animationController.reverse();
              });
            });
          }
        }
      },
      onLongPress: () {
        if (widget.subtitle == "+") widget.onLongPress("+");
      },
      child: ClipOval(
          child: AnimatedBuilder(
              animation: _colorTween,
              builder: (context, child) => Container(
                    color: _colorTween.value,
                    height: sizeFactor,
                    width: sizeFactor,
                    child: Center(
                        child: widget.icon == null
                            ? widget.subtitle != null
                                ? Column(
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Text(
                                            widget.title,
                                            style: TextStyle(fontSize: sizeFactor / 2, color: widget.textColor != null ? widget.textColor : Colors.white),
                                          )),
                                      Text(widget.subtitle, style: TextStyle(color: widget.textColor != null ? widget.textColor : Colors.white))
                                    ],
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      widget.title,
                                      style: TextStyle(
                                          fontSize: (widget.title == "*" || widget.title == "#") && widget.subtitle == null
                                              ? screenSize.height * 0.0862069
                                              : sizeFactor / 2,
                                          color: widget.textColor != null ? widget.textColor : Colors.white),
                                    ))
                            : Icon(widget.icon, size: sizeFactor / 2, color: widget.iconColor != null ? widget.iconColor : Colors.white)),
                  ))),
    );
  }
}
