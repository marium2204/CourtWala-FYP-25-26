class CloudinaryConfig {
  static const String cloudName = "dj2rvk9xk";
  static const String uploadPreset = "courtwala_unsigned";

  static String getUploadUrl(String resourceType) =>
      "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload";
}
