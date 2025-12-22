class ExternalLinks {
  static const String devUrl = 'http://10.0.2.2:3000/image';

  static const String prodUrl =
      'https://imagify-backend-r4q2.onrender.com/image';

  static const bool useProduction = true;

  static String get baseUrl => useProduction ? prodUrl : devUrl;
}
