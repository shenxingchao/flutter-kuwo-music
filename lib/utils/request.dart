import 'package:dio/dio.dart';

class Request {
  // 工厂模式
  factory Request() => _getInstance();
  static Request get instance => _getInstance();
  static Request? _instance;

  //取消接口请求token 单例
  //音频播放器
  late CancelToken cancelToken;

  Request._internal() {
    //全局AudioPlayer对象只有一个实例
    cancelToken = CancelToken();
  }

  static Request _getInstance() {
    _instance ??= Request._internal();
    return _instance as Request;
  }

  //初始化请求配置
  static final BaseOptions baseOptions = BaseOptions(
      //基础url
      baseUrl: "http://sanic-kuwo.o8o8o8.com/api/v1/",
      //请求数据类型
      contentType: "application/json; charset=utf-8",
      //超时时间ms
      connectTimeout: 5000);

  //取消接口请求
  void cancelHttp() {
    cancelToken.cancel();
    //重置不然所有请求都取消了
    cancelToken = CancelToken();
  }

  static http({url, type, data}) async {
    if (type == 'get') {
      if (data != null && !data.isEmpty) {
        url += "?";
        data.forEach((key, value) {
          url += key.toString() + "=" + value.toString() + "&&";
        });
        url = url.replaceRange(url.length - 2, url.length, '');
        data = {};
      }
    }

    Dio dio = Dio(baseOptions);
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   //这一段是解决安卓https抓包的问题
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) {
    //     return Platform.isAndroid;
    //   };
    //   client.findProxy = (uri) {
    //     return "PROXY 192.168.1.75:80";
    //   };
    // };

    //拦截器
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      //请求拦截 token 附加方法暂时不需要 options.headers['X-Token'] = 'token string';
      return handler.next(options);
    }, onResponse: (response, handler) {
      //响应拦截 这里创建不了DioError进不了reject 所以错误代码全部在then后面处理
      return handler.resolve(response);
    }, onError: (DioError e, handler) {
      //出错拦截
      return handler.reject(e);
    }));

    //返回结果
    Response response;
    //重新请求次数
    int numberOfRequest = 10;
    //重新请求间隙1000ms
    int requestDelay = 1000;

    //捕获异常
    try {
      Future<Response> fn({count = 1}) async {
        response = await dio.request(url,
            data: data ?? {},
            options: Options(method: type),
            cancelToken: Request.instance.cancelToken);
        //如果data 为null 也重新请求
        if (response.data == null && count < numberOfRequest) {
          await Future.delayed(Duration(milliseconds: requestDelay), () async {
            count++;
            response = await fn(count: count);
          });
        }
        return response;
      }

      response = await fn();
      return response;
    } on DioError catch (e) {
      if (e.response!.statusCode != null) {
        return e.response!.statusCode;
      } else {
        return "其他未知错误";
      }
    }
  }
}
