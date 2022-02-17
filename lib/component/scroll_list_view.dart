import 'package:flutter/material.dart';

/* 
example:
Container(
  height: 50,
  margin: const EdgeInsets.all(0),
  child: ScrollTabComponent(
      list: const [
        "全部",
        "新闻",
        "历史",
        "图片",
        "美女",
        "军事",
        "母婴",
        "本地",
      ],
      activeItem: '全部',
      onPressed: (item) {
        print(item);
      })), */
class ScrollTabComponent extends StatefulWidget {
  //列表数据[1,2,3,4]
  final List list;
  //回调函数 会把点击的列表项传出来
  final Function onPressed;
  //每项的内边距
  final EdgeInsets itemPadding;
  //按钮的尺寸
  final Size? size;
  //激活项
  final String activeItem;
  //激活颜色
  final Color activeColors;
  //点击时背景颜色
  final Color overlayColor;
  //字体大小
  final double? fontSize;
  //字体颜色
  final Color? fontColor;
  //边框颜色
  final Color? color;
  //按钮内边距
  final EdgeInsets? padding;

  const ScrollTabComponent({
    Key? key,
    required this.list,
    required this.onPressed,
    this.itemPadding = const EdgeInsets.all(10),
    this.size = const Size(60, 30),
    this.activeItem = '',
    this.activeColors = Colors.blue,
    this.overlayColor = const Color(0xFF64B5F6),
    this.fontSize = 16,
    this.fontColor = const Color(0xff333333),
    this.color = const Color(0xffdddddd),
    this.padding = const EdgeInsets.fromLTRB(10, 4, 10, 4),
  }) : super(key: key);

  @override
  _ScrollTabComponentState createState() => _ScrollTabComponentState();
}

class _ScrollTabComponentState extends State<ScrollTabComponent> {
  //滚动列表项
  List _list = [];
  //当前Item值
  String _activeItem = '';
  //分类滚动所需要的使用的key 集合map
  Map itemKey = {};
  //容器的key 用于最外层边框去宽度 这样可用放到任意容器内了
  GlobalKey containerkey = GlobalKey();
  //滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _list = widget.list;
    for (var item in _list) {
      itemKey[item] = GlobalKey();
    }
    _activeItem = widget.activeItem;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollItem(_activeItem);
    });
  }

  @override
  void dispose() {
    //释放资源
    _scrollController.dispose();
    super.dispose();
  }

  _scrollItem(item) {
    setState(() {
      _activeItem = item;
    });
    widget.onPressed(item);
    //当前index
    int index = _list.indexWhere((element) => element == item);
    //控件渲染对象
    RenderBox itemRenderBox = itemKey[item].currentContext.findRenderObject();
    //容器渲染对象
    RenderBox containerRenderBox =
        (containerkey.currentContext!.findRenderObject()) as RenderBox;
    //控件尺寸
    double controlWidth = itemRenderBox.size.width;
    //控件当前相对于屏幕的横坐标
    double controlOffsetX = itemRenderBox.localToGlobal(Offset.zero).dx;
    //父容器相对于屏幕的横坐标
    double containerOffsetX = containerRenderBox.localToGlobal(Offset.zero).dx;
    //相对于父容器的横坐标
    double offsetX = controlOffsetX - containerOffsetX;
    //容器宽度
    double containerWith = containerkey.currentContext!.size!.width;
    // print(containerWith);
    //判断 是否在中间 在中间当然不用动了
    if ((offsetX + controlWidth / 2) != containerWith / 2) {
      //计算便宜量需要的index索引值 比如前面几个或者最后几个不能滚动到中间的最小最大索引 -1是因为索引是从0开始的
      int limitIndex = ((containerWith / 2) / controlWidth).round() - 1;
      if (index > limitIndex && index < _list.length - 1 - limitIndex) {
        //滚动到中间
        //需要用到计算的绝对偏移量
        double absOffsetX = offsetX - containerWith / 2;
        //注意一下括号就行
        double scrollValue = absOffsetX.abs() +
            (absOffsetX > 0 ? (controlWidth / 2) : -(controlWidth / 2));
        //滚动条旧位置
        double scrollOffsetX = _scrollController.position.extentBefore;
        //计算最终滚动要滚动到的位置
        scrollValue =
            scrollOffsetX + (absOffsetX > 0 ? scrollValue : -scrollValue);
        //滚动到中间
        _scrollController.animateTo(scrollValue,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      } else if (index <= limitIndex) {
        //滚动到起始位置
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      } else if (index >= _list.length - 1 - limitIndex) {
        //滚动到最后
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        key: containerkey,
        //水平滚动列表
        child: SingleChildScrollView(
          //水平滚动
          scrollDirection: Axis.horizontal,
          //滚动控制器
          controller: _scrollController,
          child: Row(
            children: _list
                .map((item) => GestureDetector(
                      child: Container(
                        key: itemKey[item],
                        padding: widget.itemPadding,
                        child: TextButtonComponent(
                            onPressed: () {
                              _scrollItem(item);
                            },
                            text: item,
                            color: item == _activeItem
                                ? widget.activeColors
                                : widget.color as Color,
                            backgroundColor: item == _activeItem
                                ? widget.activeColors
                                : Colors.transparent,
                            textStyle: item == _activeItem
                                ? TextStyle(
                                    color: Colors.white,
                                    fontSize: widget.fontSize)
                                : TextStyle(
                                    color: widget.fontColor,
                                    fontSize: widget.fontSize),
                            overlayColor: item == _activeItem
                                ? widget.activeColors
                                : widget.overlayColor,
                            padding: widget.padding),
                      ),
                    ))
                .toList(),
          ),
        ));
  }
}

class TextButtonComponent extends StatelessWidget {
  //定义属性 要用final关键字 可以参数用?表示
  //如果可选参数不加问号，则必须在构造函数中初始化赋值
  final String text;
  final TextStyle? textStyle;
  final Color color; //主题色
  final Color overlayColor; //点击时背景颜色
  final Color backgroundColor; //背景颜色
  final EdgeInsets? padding;
  final VoidCallback? onPressed;

  //声明构造函数及里面的需要传入的属性 {}内的表示可选参数
  const TextButtonComponent({
    this.text = '',
    this.textStyle = const TextStyle(color: Colors.blue, fontSize: 14),
    this.color = Colors.blue,
    this.overlayColor = const Color(0xFFE3F2FD),
    this.backgroundColor = Colors.transparent,
    this.padding = const EdgeInsets.fromLTRB(10, 4, 10, 4),
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //文字按钮
    return TextButton(
      style: ButtonStyle(
        //内边距
        padding: MaterialStateProperty.all(padding),
        //边框
        side: MaterialStateProperty.all(BorderSide(color: color, width: 1)),
        //圆角
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        //背景
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        //点击时背景
        overlayColor: MaterialStateProperty.all(overlayColor),
      ),
      onPressed: onPressed ?? () {},
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
