class Doctor {
  final String name;
  final String hospitalName;
  final String location;
  final String imageUrl;
  final String? specialisation;
  final String? doctorImages;
  final bool isFavorite;

  Doctor({
    required this.name,
    required this.hospitalName,
    required this.location,
    required this.imageUrl,
    this.specialisation,
    this.doctorImages,
    this.isFavorite = false,
  });
}
