// lib/Player_Panel/community_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:path_provider/path_provider.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../services/image_upload_service.dart';

// --- Models ---

class Post {
  final String id;
  final String content;
  final String userId;
  final String authorName;
  final String? authorProfilePicture;
  final DateTime createdAt;
  final List<Attachment> attachments;
  final Map<String, int> reactionCounts;
  final int commentCount;
  bool userHasReacted;
  String? userReactionType;

  Post({
    required this.id,
    required this.content,
    required this.userId,
    required this.authorName,
    this.authorProfilePicture,
    required this.createdAt,
    required this.attachments,
    required this.reactionCounts,
    required this.commentCount,
    required this.userHasReacted,
    this.userReactionType,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final author = json['user'];
    return Post(
      id: json['id'],
      content: json['content'],
      userId: json['userId'],
      authorName: '${author['firstName']} ${author['lastName']}',
      authorProfilePicture: author['profilePicture'],
      createdAt: DateTime.parse(json['createdAt']),
      attachments: (json['attachments'] as List)
          .map((a) => Attachment.fromJson(a))
          .toList(),
      reactionCounts: Map<String, int>.from(json['reactionCounts'] ?? {}),
      commentCount: json['_count'] != null ? json['_count']['comments'] ?? 0 : 0,
      userHasReacted: json['userHasReacted'] ?? false,
      userReactionType: json['userReactionType'],
    );
  }
}

class Attachment {
  final String url;
  final String type; // IMAGE or VIDEO

  Attachment({required this.url, required this.type});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(url: json['url'], type: json['type']);
  }
}

// --- Screen ---

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Post> _posts = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isMoreLoading &&
        _hasMore) {
      _fetchMorePosts();
    }
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
    });

    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.get('/community/posts?page=$_page&limit=10', token);
      final body = jsonDecode(res.body);

      if (body['success']) {
        final List newPostsData = body['data']['posts'];
        setState(() {
          _posts.clear();
          _posts.addAll(newPostsData.map((p) => Post.fromJson(p)));
          _hasMore = _page < body['data']['pagination']['totalPages'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching posts: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMorePosts() async {
    setState(() => _isMoreLoading = true);
    _page++;

    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.get('/community/posts?page=$_page&limit=10', token);
      final body = jsonDecode(res.body);

      if (body['success']) {
        final List newPostsData = body['data']['posts'];
        setState(() {
          _posts.addAll(newPostsData.map((p) => Post.fromJson(p)));
          _hasMore = _page < body['data']['pagination']['totalPages'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching more posts: $e");
    } finally {
      setState(() => _isMoreLoading = false);
    }
  }

  Future<void> _toggleReaction(Post post, String type) async {
    final token = await TokenService.getToken();
    if (token == null) return;

    // Optimistic update
    setState(() {
      if (post.userHasReacted && post.userReactionType == type) {
        // Remove
        post.userHasReacted = false;
        post.userReactionType = null;
        post.reactionCounts[type] = (post.reactionCounts[type] ?? 1) - 1;
      } else {
        // Add or Change
        if (post.userHasReacted && post.userReactionType != null) {
          post.reactionCounts[post.userReactionType!] =
              (post.reactionCounts[post.userReactionType!] ?? 1) - 1;
        }
        post.userHasReacted = true;
        post.userReactionType = type;
        post.reactionCounts[type] = (post.reactionCounts[type] ?? 0) + 1;
      }
    });

    try {
      await ApiService.post('/community/posts/${post.id}/react', token, {'type': type});
    } catch (e) {
      // Revert on error? Skipping for simplicity in this walkthrough
      debugPrint("Error toggling reaction: $e");
    }
  }

  void _showReactionPicker(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _reactionIcon(post, 'LIKE', '👍'),
            _reactionIcon(post, 'LOVE', '❤️'),
            _reactionIcon(post, 'HAHA', '😂'),
            _reactionIcon(post, 'SAD', '😢'),
          ],
        ),
      ),
    );
  }

  Widget _reactionIcon(Post post, String type, String emoji) {
    final isSelected = post.userHasReacted && post.userReactionType == type;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _toggleReaction(post, type);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : null,
          shape: BoxShape.circle,
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 32)),
      ),
    );
  }

  void _openCreatePost() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreatePostBottomSheet(),
    );

    if (result == true) {
      _fetchPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Community',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchPosts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPosts,
              child: _posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _posts.length + (_isMoreLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _posts.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return PostCard(
                          post: _posts[index],
                          onReactTap: () => _showReactionPicker(_posts[index]),
                          onCommentTap: () => _showCommentsBottomSheet(_posts[index]),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePost,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCommentsBottomSheet(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommentsBottomSheet(post: post),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No posts yet",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _openCreatePost,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: const Text("Be the first to post", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- Components ---

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onReactTap;
  final VoidCallback onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onReactTap,
    required this.onCommentTap,
  });

  String _getEmoji(String type) {
    switch (type) {
      case 'LOVE': return '❤️';
      case 'HAHA': return '😂';
      case 'SAD': return '😢';
      default: return '👍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.authorProfilePicture != null
                  ? CachedNetworkImageProvider(post.authorProfilePicture!)
                  : null,
              child: post.authorProfilePicture == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(timeago.format(post.createdAt)),
            trailing: const Icon(Icons.more_horiz),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post.content, style: const TextStyle(fontSize: 16)),
          ),

          // Attachments
          if (post.attachments.isNotEmpty) _buildAttachments(),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (post.reactionCounts.isNotEmpty) ...[
                  Row(
                    children: post.reactionCounts.entries
                        .where((e) => e.value > 0)
                        .map((e) => Text(_getEmoji(e.key)))
                        .toList(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.reactionCounts.values.fold(0, (a, b) => a + b).toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const Spacer(),
                Text("${post.commentCount} comments", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const Divider(height: 1),

          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onReactTap,
                  icon: Text(
                    post.userHasReacted ? _getEmoji(post.userReactionType!) : '👍',
                    style: TextStyle(
                      fontSize: 18,
                      color: post.userHasReacted ? AppColors.primaryColor : Colors.grey,
                    ),
                  ),
                  label: Text(
                    post.userHasReacted ? post.userReactionType! : "Like",
                    style: TextStyle(
                      color: post.userHasReacted ? AppColors.primaryColor : Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onCommentTap,
                  icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                  label: const Text("Comment", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
    if (post.attachments.length == 1) {
      final a = post.attachments.first;
      return _mediaItem(a, double.infinity, 250);
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        viewportFraction: 0.9,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
      ),
      items: post.attachments.map((a) => _mediaItem(a, double.infinity, 250)).toList(),
    );
  }

  Widget _mediaItem(Attachment a, double width, double height) {
    if (a.type == 'VIDEO') {
      return CommunityVideoPlayer(url: a.url, width: width, height: height);
    }

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: a.url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}

class CommunityVideoPlayer extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const CommunityVideoPlayer({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  State<CommunityVideoPlayer> createState() => _CommunityVideoPlayerState();
}

class _CommunityVideoPlayerState extends State<CommunityVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      placeholder: Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show Cloudinary generated thumbnail while initializing
      final thumbnailUrl = widget.url.replaceAll(RegExp(r'\.mp4$|\.mov$'), '.jpg');
      return Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: thumbnailUrl,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: Colors.black),
          ),
          const CircularProgressIndicator(color: Colors.white),
        ],
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}

class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedFiles = [];
  final Map<String, String?> _videoThumbnails = {};
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    if (_selectedFiles.length >= 5) {
      _showError("Max 5 images allowed");
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    for (var xFile in images) {
      final file = File(xFile.path);
      final size = await file.length();
      if (size > 4 * 1024 * 1024) {
        _showError("Image ${xFile.name} exceeds 4MB");
        continue;
      }
      if (_selectedFiles.length < 5) {
        setState(() => _selectedFiles.add(file));
      }
    }
  }

  Future<void> _pickVideo() async {
    // Check if video already exists
    if (_selectedFiles.any((f) => f.path.endsWith('.mp4'))) {
      _showError("Max 1 video allowed");
      return;
    }

    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    final file = File(video.path);
    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      _showError("Video exceeds 5MB");
      return;
    }

    // Generate thumbnail
    final fileName = await vt.VideoThumbnail.thumbnailFile(
      video: file.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: vt.ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );

    setState(() {
      _selectedFiles.add(file);
      _videoThumbnails[file.path] = fileName;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty && _selectedFiles.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      // 1. Upload to Cloudinary
      final List<Map<String, String>> attachments = [];
      for (var file in _selectedFiles) {
        final isVideo = file.path.toLowerCase().endsWith('.mp4') || 
                       file.path.toLowerCase().endsWith('.mov');
        
        final url = await ImageUploadService.uploadToCloudinary(
          file,
          folder: 'courtwala/community',
          resourceType: isVideo ? 'video' : 'image',
        );

        if (url != null) {
          attachments.add({
            'url': url,
            'type': isVideo ? 'VIDEO' : 'IMAGE'
          });
        }
      }

      // 2. Create Post
      final res = await ApiService.post('/community/posts', token, {
        'content': _contentController.text.trim(),
        'attachments': attachments
      });

      if (res.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        _showError("Failed to create post");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Create Post", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedFiles.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  final isVideo = file.path.endsWith('.mp4');
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: isVideo 
                            ? (_videoThumbnails[file.path] != null 
                                ? DecorationImage(image: FileImage(File(_videoThumbnails[file.path]!)), fit: BoxFit.cover)
                                : null)
                            : DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                          color: isVideo ? Colors.black : null,
                        ),
                        child: isVideo && _videoThumbnails[file.path] == null 
                          ? const Icon(Icons.videocam, color: Colors.white, size: 40) 
                          : null,
                      ),
                      Positioned(
                        right: 12,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFiles.removeAt(index)),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(onPressed: _pickImages, icon: const Icon(Icons.image, color: Colors.blue)),
              IconButton(onPressed: _pickVideo, icon: const Icon(Icons.videocam, color: Colors.red)),
              const Spacer(),
              ElevatedButton(
                onPressed: _isUploading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isUploading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Post", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CommentsBottomSheet extends StatefulWidget {
  final Post post;
  const CommentsBottomSheet({super.key, required this.post});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final List<dynamic> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.get('/community/posts/${widget.post.id}/comments', token);
      final body = jsonDecode(res.body);
      if (body['success']) {
        setState(() {
          _comments.clear();
          _comments.addAll(body['data']['comments']);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching comments: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    final token = await TokenService.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.post(
        '/community/posts/${widget.post.id}/comments',
        token,
        {'content': _commentController.text.trim()},
      );

      if (res.statusCode == 201) {
        _commentController.clear();
        _fetchComments();
      }
    } catch (e) {
      debugPrint("Error adding comment: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(child: Text("No comments yet", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final c = _comments[index];
                          final user = c['user'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: user['profilePicture'] != null
                                      ? CachedNetworkImageProvider(user['profilePicture'])
                                      : null,
                                  child: user['profilePicture'] == null ? const Icon(Icons.person, size: 16) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${user['firstName']} ${user['lastName']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(c['content'], style: const TextStyle(fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(timeago.format(DateTime.parse(c['createdAt'])), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSubmitting ? null : _addComment,
                  icon: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send, color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
