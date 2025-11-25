import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_the_artists/domain/entities/post_entity.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // READ: Get all posts (Stream for real-time updates)
  // This listens to the 'posts' collection and updates the app whenever a post is added or deleted.
  Stream<List<PostEntity>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // We pass doc.id to the entity so we know which post to delete later
        return PostEntity.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // CREATE: Add a new post
  // This saves the post data to Firestore.
  Future<void> createPost(String userId, String description, String? mediaUrl, List<String> tags) async {
    try {
      await _firestore.collection('posts').add({
        'userId': userId,
        'description': description,
        'mediaUrl': mediaUrl ?? '',
        'tags': tags,
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // DELETE: Delete a post
  // This is your specific feature contribution to the project.
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
