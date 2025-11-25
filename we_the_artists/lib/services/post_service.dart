import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_the_artists/domain/entities/post_entity.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // READ: Stream of posts
  Stream<List<PostEntity>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostEntity.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // CREATE: Add a post
  Future<void> createPost(String userId, String description, String? mediaUrl, List<String> tags) async {
    await _firestore.collection('posts').add({
      'userId': userId,
      'description': description,
      'mediaUrl': mediaUrl ?? '',
      'tags': tags,
      'likes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // DELETE: This is your feature contribution
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
