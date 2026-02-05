# All Canteens Feature Documentation

## Overview

Fitur "All Canteens" memungkinkan pengguna melihat daftar lengkap semua kantin dengan sistem pagination, infinite scroll, dan pencarian real-time.

## Struktur File

### 1. BLoC Layer

#### Events (`lib/features/stan/presentation/bloc/all_canteens_event.dart`)

- `LoadAllCanteens()` - Load halaman pertama (10 item)
- `LoadMoreCanteens()` - Load halaman berikutnya saat scroll
- `RefreshCanteens()` - Pull to refresh
- `SearchCanteens(String query)` - Pencarian kantin

#### States (`lib/features/stan/presentation/bloc/all_canteens_state.dart`)

- `AllCanteensInitial()` - State awal
- `AllCanteensLoading()` - Loading state
- `AllCanteensLoaded()` - State dengan data
  - `List<Stan> canteens` - Daftar kantin
  - `bool hasReachedMax` - Flag untuk pagination
  - `bool isLoadingMore` - Loading saat load more
  - `String searchQuery` - Query pencarian
- `AllCanteensError(String message)` - Error state

#### BLoC (`lib/features/stan/presentation/bloc/all_canteens_bloc.dart`)

**Konfigurasi Pagination:**

- `_pageSize = 10` - Jumlah item per halaman
- `_currentPage` - Tracking halaman saat ini
- `_allCanteens` - Cache semua kantin dari API

**Mekanisme:**

1. **Load Initial:** Ambil semua data dari `GetAllStansUseCase`, tampilkan 10 pertama
2. **Load More:** Slice data berikutnya saat user scroll ke bawah
3. **Search:** Filter data berdasarkan `namaStan`, `namaPemilik`, atau `description`
4. **Refresh:** Reset pagination dan reload data

### 2. UI Layer

#### Screen (`lib/features/stan/presentation/screens/all_canteens_screen.dart`)

**Komponen Utama:**

- **SearchBar:** CustomTextField dengan debounce untuk pencarian
- **ListView:** Menampilkan daftar kantin
- **Pagination Indicator:** Loading circular di bottom saat load more
- **Pull to Refresh:** RefreshIndicator untuk reload data
- **Scroll Detection:** Trigger load more saat scroll 90%

**Features:**

1. **Infinite Scroll**

   ```dart
   bool _isBottom = _scrollController.position.pixels >=
                    _scrollController.position.maxScrollExtent * 0.9;
   ```

2. **Search dengan Debounce**
   - User mengetik di search bar
   - Event `SearchCanteens` triggered
   - Filter dilakukan di BLoC

3. **Empty State**
   - Menampilkan pesan jika tidak ada kantin
   - Icon dan text informatif

4. **Loading States**
   - Shimmer/skeleton untuk initial load
   - Circular indicator untuk load more

## Integration

### 1. Dependency Injection (`lib/core/di/injection_container.dart`)

```dart
sl.registerFactory(() => AllCanteensBloc(getAllStansUseCase: sl()));
```

### 2. Routing (`lib/core/routes/app_routes.dart`)

```dart
GoRoute(
  path: '/all-canteens',
  builder: (context, state) => BlocProvider(
    create: (context) => sl<AllCanteensBloc>(),
    child: const AllCanteensScreen(),
  ),
),
```

### 3. Navigation dari Home (`lib/features/home/presentation/screens/siswa_home_screen.dart`)

```dart
GestureDetector(
  onTap: () {
    context.push('/all-canteens');
  },
  child: Text('See All', ...),
),
```

## Usage Flow

1. **User opens home screen**
   - Melihat maksimal 5 kantin
   - Button "See All" terlihat di section "Kantin Populer"

2. **User taps "See All"**
   - Navigate ke `/all-canteens`
   - `AllCanteensBloc` di-create
   - Event `LoadAllCanteens` triggered otomatis

3. **Initial Load**
   - BLoC load semua kantin dari API
   - Tampilkan 10 item pertama
   - Set `hasReachedMax = false` jika ada lebih dari 10

4. **User scrolls down**
   - Saat scroll mencapai 90% dari max scroll
   - Trigger `LoadMoreCanteens` event
   - Load 10 item berikutnya
   - Update `hasReachedMax` jika sudah tidak ada lagi

5. **User searches**
   - Ketik di search bar
   - `SearchCanteens(query)` event triggered
   - Filter kantin berdasarkan query
   - Reset ke halaman pertama hasil search

6. **User pulls to refresh**
   - Trigger `RefreshCanteens` event
   - Reset `_currentPage = 0`
   - Reload data dari awal

## Technical Details

### Pagination Logic

```dart
List<Stan> _getPaginatedCanteens() {
  final startIndex = _currentPage * _pageSize;
  final endIndex = startIndex + _pageSize;

  if (startIndex >= _allCanteens.length) {
    return [];
  }

  return _allCanteens.sublist(
    startIndex,
    endIndex > _allCanteens.length ? _allCanteens.length : endIndex,
  );
}
```

### Search Filter

```dart
final filtered = _allCanteens.where((stan) {
  final query = event.query.toLowerCase();
  return stan.namaStan.toLowerCase().contains(query) ||
         stan.namaPemilik.toLowerCase().contains(query) ||
         (stan.description?.toLowerCase().contains(query) ?? false);
}).toList();
```

### Scroll Detection

```dart
void _onScroll() {
  if (_isBottom && !state.isLoadingMore && !state.hasReachedMax) {
    add(LoadMoreCanteens());
  }
}

bool get _isBottom {
  if (!_scrollController.hasClients) return false;
  final maxScroll = _scrollController.position.maxScrollExtent;
  final currentScroll = _scrollController.position.pixels;
  return currentScroll >= (maxScroll * 0.9); // Trigger at 90%
}
```

## Optimization

### Performance

- ✅ Data di-cache di BLoC (`_allCanteens`)
- ✅ Pagination untuk mengurangi render items
- ✅ Lazy loading dengan scroll detection
- ✅ Search filter dilakukan di memory (fast)

### UX

- ✅ Pull to refresh untuk reload data
- ✅ Loading indicator saat fetch data
- ✅ Empty state yang informatif
- ✅ Scroll preload di 90% (bukan 100%)

### Best Practices

- ✅ Separation of concerns (BLoC pattern)
- ✅ Dependency injection
- ✅ Reusable widgets (CustomTextField, KantinStallCard)
- ✅ Proper error handling
- ✅ Clean architecture

## Testing Checklist

- [ ] Load initial 10 items
- [ ] Scroll down load 10 more items
- [ ] Search functionality works
- [ ] Pull to refresh reloads data
- [ ] Empty state displays correctly
- [ ] Loading states display properly
- [ ] Navigation from home works
- [ ] Back button returns to home
- [ ] Tap kantin card navigates to detail

## Future Enhancements

1. **Filter & Sort**
   - Filter by category
   - Sort by rating, distance, popularity
2. **Advanced Search**
   - Search by menu items
   - Search by price range
3. **Caching**
   - Local storage with Hive
   - Offline support
4. **Analytics**
   - Track search queries
   - Track popular canteens

## Dependencies Used

- `flutter_bloc` - State management
- `go_router` - Navigation
- `get_it` - Dependency injection
- Existing `GetAllStansUseCase` - Data fetching
