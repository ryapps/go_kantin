# Implementasi Category Canteen

## Overview

Implementasi fitur untuk menampilkan daftar kantin berdasarkan kategori yang dipilih menggunakan atribut `categories` dari entity `Stan`. Field `categories` menyimpan **Category IDs** (bukan nama kategori).

## ⚠️ Penting: Category IDs

**Stan.categories menyimpan Category IDs**, bukan nama kategori:

- ✅ Benar: `categories: ["cat_makanan", "cat_minuman"]`
- ❌ Salah: `categories: ["Makanan", "Minuman"]`

Alasan:

1. **Konsistensi data** - Nama kategori bisa berubah tanpa perlu update data stan
2. **Filtering akurat** - Berdasarkan ID yang unique
3. **Best practice** - Mengikuti standar relational data

## Struktur Entity

### Stan Entity

```dart
class Stan {
  final String id;
  final String namaStan;
  final List<String> categories; // List of category IDs (BUKAN nama)
  final double rating;
  // ... other fields
}
```

### Category Entity

```dart
class Category {
  final String id;           // ID yang disimpan di Stan.categories
  final String name;         // Nama untuk display
  final String imageUrl;
  // ... other fields
}
```

## Alur Kerja

### 1. User Memilih Kategori

Di `siswa_home_screen.dart`, ketika user tap pada kategori di `FoodCategoryGrid`:

```dart
onCategorySelected: (categoryId) {
  // 1. Cari data kategori yang dipilih
  final selectedCategory = state.categories.firstWhere(
    (cat) => cat.id == categoryId,
  );

  // 2. Filter kantin berdasarkan kategori
  // Menggunakan stan.categories.contains(categoryId)
  final filteredCanteens = state.allStalls.where((stan) {
    return stan.categories.contains(categoryId);
  }).toList();

  // 3. Navigate ke halaman baru
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CategoryCanteensScreen(
        category: selectedCategory,
        canteens: filteredCanteens,
      ),
    ),
  );
}
```

### 2. Tampilan CategoryCanteensScreen

Screen ini menampilkan:

- **AppBar** dengan nama kategori dan tombol sort
- **Header Info** dengan gambar kategori dan jumlah kantin
- **List Kantin** dalam bentuk `KantinStallCard`
- **Badge Kategori Lain** untuk kantin yang memiliki multiple categories

#### Fitur Sorting

User dapat sort kantin berdasarkan:

- **Rating Tertinggi** (default)
- **Nama (A-Z)**

```dart
void _sortCanteens() {
  setState(() {
    if (_sortBy == 'rating') {
      _sortedCanteens.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'name') {
      _sortedCanteens.sort((a, b) => a.namaStan.compareTo(b.namaStan));
    }
  });
}
```

#### Badge Kategori Lain

Jika kantin memiliki lebih dari 1 kategori, akan ditampilkan badge kategori lainnya:

```dart
if (canteen.categories.length > 1)
  Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
    child: Wrap(
      spacing: 6,
      children: [
        Text('Kategori lain:'),
        ...canteen.categories
            .where((cat) => cat != widget.category.id)
            .take(3)
            .map((catId) => Container(
              // Badge styling
            )),
      ],
    ),
  )
```

## Files yang Dimodifikasi/Dibuat

### 1. `category_canteens_screen.dart` (BARU)

Screen untuk menampilkan kantin berdasarkan kategori dengan fitur:

- Sorting (rating, nama)
- Header info kategori
- List kantin dengan badge kategori lain (menampilkan nama, bukan ID)
- Mapping category ID ke nama kategori
- Empty state handling

### 2. `siswa_home_screen.dart` (MODIFIED)

Update pada `FoodCategoryGrid.onCategorySelected`:

- Filter kantin berdasarkan `stan.categories.contains(categoryId)`
- Navigate ke `CategoryCanteensScreen`
- Pass data category, filtered canteens, dan allCategories untuk mapping

### 3. `siswa_home_bloc.dart` (MODIFIED)

- Default `selectedCategoryId` diubah menjadi **empty string**
- Tidak ada kategori yang selected di awal aplikasi
- Menampilkan semua kantin saat pertama kali buka aplikasi

### 4. `complete_stan_profile_screen.dart` (MODIFIED)

- Menyimpan **category.id** (bukan category.name) ke `_selectedCategories`
- Saat display menggunakan `category.name` untuk user-friendly
- Saat save menggunakan `category.id` untuk konsistensi data

## Cara Penggunaan

### A. Mengisi Profil Stan (Admin)

1. Admin membuka screen complete profile
2. Admin memilih kategori dari FilterChip
3. **Yang tersimpan adalah category.id** (contoh: "cat_makanan")
4. Display menampilkan category.name (contoh: "Makanan")

### B. Melihat Kantin Berdasarkan Kategori (Siswa)

1. User membuka Home Screen
2. **Tidak ada kategori yang selected** - menampilkan semua kantin
3. User tap salah satu kategori di grid
4. Sistem akan:
   - Filter semua kantin berdasarkan `stan.categories.contains(categoryId)`
   - Navigate ke CategoryCanteensScreen
   - Tampilkan list kantin yang sudah difilter
5. User dapat:
   - Sort kantin berdasarkan rating atau nama
   - Tap kantin untuk melihat detail
   - Lihat kategori lain dari kantin (menampilkan nama kategori, bukan ID)

## Relasi dengan Entity Stan

Setiap `Stan` memiliki field `categories` yang bertipe `List<String>`:

- Berisi ID dari kategori-kategori yang dimiliki kantin
- Satu kantin bisa memiliki multiple categories
- Filtering dilakukan dengan `stan.categories.contains(categoryId)`

### Contoh Data:

```dart
Stan(
  id: "stan_1",
  namaStan: "Kantin Sederhana",
  categories: ["cat_makanan", "cat_minuman", "cat_snack"],
  rating: 4.5,
  // ...
)
```

Jika user memilih kategori "Makanan" (cat_makanan), kantin ini akan muncul di list karena `categories` mengandung "cat_makanan".

## Empty State

Jika tidak ada kantin untuk kategori tersebut, akan ditampilkan:

- Icon store_outlined
- Text: "Belum ada kantin untuk kategori ini"

## Navigation

Menggunakan standard `Navigator.push` untuk pindah ke `CategoryCanteensScreen`, sehingga user bisa kembali dengan back button.
