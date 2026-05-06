import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/cloudinary_config.dart';

class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  static Future<String?> uploadToCloudinary(
    File file, {
    String folder = "courtwala",
    String resourceType = "image",
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(CloudinaryConfig.getUploadUrl(resourceType)),
    )
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Image upload failed");
    }

    final data = jsonDecode(responseBody);
    return data['secure_url'];
  }
}
