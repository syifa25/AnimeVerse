  import 'package:flutter/cupertino.dart';
  import '../models/anime.dart';
  import 'dart:convert';
  import 'package:shared_preferences/shared_preferences.dart';

  class AppStateProvider extends ChangeNotifier {
    List<Anime>_favorites = [];

    static const String _storageKey = 'favorite_anime_list';

    final bool _isLoaded = false;
    bool get isLoaded => _isLoaded;

    AppStateProvider(){
      _loadFavorites();
    }

    List <Anime> get favorites => _favorites;

    bool isFavorite(String id){
      return _favorites.any((anime) => anime.id == id);
    }


    void toggleFavorite (Anime anime){
      if(isFavorite(anime.id)){
        removeFavorite(anime.id);
      }else{
        addFavorite(anime);
      }
    }


    void addFavorite(Anime anime){
      if(!isFavorite(anime.id)){
        _favorites.add(anime);
        _saveFavorites();
        notifyListeners();
      }
    }

    void removeFavorite(String id){
      _favorites.removeWhere((anime) => anime.id == id);
      _saveFavorites();
      notifyListeners();
    }

    Future<void> _saveFavorites() async
  {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> favoritJson =
        _favorites.map((anime) => anime.toJson()).toList();

      await prefs.setString(_storageKey, jsonEncode(favoritJson));

    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

    Future<void> _loadFavorites() async {
      try {
        final prefs = await SharedPreferences.getInstance();

        final String? favoriteJson = prefs.getString(_storageKey);

        if (favoriteJson != null){
          final List<dynamic> decode = jsonDecode(favoriteJson);

          _favorites = decode
            .map((item) => Anime.fromJson(item as Map<String, dynamic>))
            .toList();

          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error loading favorites: $e');
      }
    }

  }