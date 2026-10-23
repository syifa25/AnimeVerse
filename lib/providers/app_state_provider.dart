  import 'package:flutter/cupertino.dart';
  import '../models/anime.dart';
  import 'dart:convert';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../data/dummy_data.dart';

  class AppStateProvider extends ChangeNotifier {
    List<Anime>_favorites = [];
    

    

    static const String _storageKey = 'favorite_anime_list';

    bool _isLoaded = false;
    bool get isLoaded => _isLoaded;

    AppStateProvider(){
      _loadFavorites();
    }

    List<Anime> get favorites => _favorites;

    String _selectedGenre = "All";

    String get selectedGenre => _selectedGenre;

    void setSelectedGenre(String genre) {
      _selectedGenre = genre;
      notifyListeners();
    }

    String _homeSearchQuery = "";
    String _favoriteSearchQuery = "";

    String get homeSearchQuery => _homeSearchQuery;
    String get favoriteSearchQuery => _favoriteSearchQuery;

    void setHomeSearchQuery(String query){
      _homeSearchQuery = query;
      notifyListeners();
    }

    void setFavoriteSearchQuery(String query){
      _favoriteSearchQuery = query;
      notifyListeners();
    }

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

    List<Anime> getFilterAnimeForHome(){
      List<Anime> result = DummyData.animeList;

      if(_selectedGenre != "All"){
        result = result.where((anime){
          final genres = anime.genre.split(',').map((g) => g.trim()).toList();

          return genres.contains(_selectedGenre);
        }).toList();
      }

      if (_homeSearchQuery.isNotEmpty){
        result = result.where((anime){
          return anime.title
            .toLowerCase()
            .contains(_homeSearchQuery.toLowerCase());
        }).toList();
      }
      return result;
    }

    List<Anime> getFilteredFavorites(){
      List<Anime> result = _favorites;
      if(_favoriteSearchQuery.isNotEmpty){
        result = result.where((anime){
          return anime.title
            .toLowerCase()
            .contains(_favoriteSearchQuery.toLowerCase());
        }).toList();
      }
      return result;
    }

    
    Future<void> _saveFavorites() async {
      try {
        final prefs = await SharedPreferences.getInstance();

        final List<Map<String, dynamic>> favoritJson =
            _favorites.map((anime) => anime.toJson()).toList();

        final success = await prefs.setString(
          _storageKey,
          jsonEncode(favoritJson),
        );

        debugPrint('SAVE FAVORITES: $success');
        debugPrint('JUMLAH FAVORITES: ${_favorites.length}');
      } catch (e) {
        debugPrint('Error saving favorites: $e');
      }
    }


    Future<void> _loadFavorites() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        

        debugPrint('PREFS INSTANCE: $prefs');
        debugPrint('SEMUA KEYS: ${prefs.getKeys()}');
        debugPrint('DATA FAVORIT: ${prefs.getString(_storageKey)}');

        debugPrint('STORAGE KEY: $_storageKey');
        debugPrint('SEMUA KEYS: ${prefs.getKeys()}');

        final String? favoriteJson = prefs.getString(_storageKey);

        debugPrint('DATA TERSIMPAN: $favoriteJson');

        if (favoriteJson != null) {
          final List<dynamic> decoded = jsonDecode(favoriteJson);

          _favorites = decoded
              .map(
                (item) => Anime.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();

          debugPrint('JUMLAH FAVORIT DIMUAT: ${_favorites.length}');
        }
      } catch (e) {
        debugPrint('Error loading favorites: $e');
      } finally {
        _isLoaded = true;
        notifyListeners();
      }
    }

  }