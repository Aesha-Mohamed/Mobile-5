import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostService {
  static const _postsUrl = String.fromEnvironment(
    'POSTS_API_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com/posts',
  );

  Future<List<Post>> getPosts() async {
    final box = await Hive.openBox<Post>('postsBox');
    try {
      final response = await http
          .get(Uri.parse(_postsUrl), headers: const {
            'Accept': 'application/json',
            'User-Agent': 'FlutterHiveOfflinePosts/1.0',
          })
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200)
        throw Exception('API returned ${response.statusCode}');
      final posts = (jsonDecode(response.body) as List<dynamic>)
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
      await box.clear();
      await box.addAll(posts);
      print('Loaded from API and cached to Hive: ${posts.length}');
      return posts;
    } catch (error) {
      print('Posts API request failed: $error');
      if (box.isNotEmpty) {
        print('Loaded from Hive offline: ${box.length}');
        return box.values.toList();
      }
      throw Exception('No Internet and No Cached Data');
    }
  }
}
