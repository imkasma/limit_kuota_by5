# Tugas Perbaikan Struktur Folder

Tujuan: Merapikan struktur proyek agar modular, mudah dikembangkan, mudah diuji, dan konsisten.

Hasil akhir yang diharapkan:
- Kode terorganisir per fitur/core
- Aset terpusat di folder `assets/`
- Imports bersih menggunakan `package:limit_kuota/...`
- Tes dan CI terintegrasi
- Dokumentasi migrasi tersedia

## Layout yang disarankan
- `lib/`
  - `lib/src/core/` : shared services, repositories, models, widgets, utils, themes, constants
  - `lib/src/features/<feature>/` : per-fiturnya (screens, widgets, models, data)
  - `lib/main.dart` : entrypoint
- `assets/` : `images/`, `icons/`, `fonts/`
- `test/` : `unit/` dan `widget/`
- `docs/` : panduan arsitektur & migrasi
- `scripts/` : helper scripts (opsional)

## Langkah pelaksanaan (urut, untuk ditugaskan)

1. Audit Struktur Repo
	- Tugas: Inventaris semua file/folder; catat file yang perlu dipindah (contoh: `db_helper.dart`, `network.dart`, `helper.dart`), duplikat, dan dependensi lint/analysis.
	- Output: `docs/audit.md` berisi peta sekarang → target, dan daftar risiko (import break, tests).
	- Estimasi: 2–4 jam. Owner: Junior/AI. Acceptance: `audit.md` disetujui reviewer.

2. Definisikan Layout Baru
	- Tugas: Tetapkan layout final (pakai template di atas), konvensi penamaan (feature per-folder), dan aturan modular (apa masuk `core` vs `features`).
	- Output: `docs/structure.md` + contoh path untuk 3 file nyata.
	- Estimasi: 1–2 jam. Owner: Senior/Lead. Acceptance: disetujui reviewer.

3. Buat Folder & README per Folder
	- Tugas: Buat folder baru sesuai layout; tiap folder kecil tambah `README.md` yang singkat (tujuan, aturan, contoh impor).
	- Output: Folder kosong + README.
	- Estimasi: 0.5–1 jam. Owner: Junior/AI.

4. Pindahkan Aset & Media
	- Tugas: Kumpulkan semua gambar/icon/font dari repo, pindahkan ke `assets/images/`, `assets/icons/`, `assets/fonts/` menggunakan `git mv` untuk mempertahankan history.
	- Tindakan tambahan: Update `pubspec.yaml` untuk mendaftarkan assets.
	- Estimasi: 1–2 jam. Owner: Junior/AI. Acceptance: `flutter pub get` sukses; gambar muncul saat build.

5. Pindahkan File Satu-per-satu (Move + Refactor)
	- Tugas: Untuk setiap file kode (mulai dari util/DB/network → core, UI kecil → core/widgets atau feature), lakukan: a) buat branch, b) `git mv` file ke lokasi baru, c) refactor import via IDE (atau script), d) run `flutter analyze`.
	- Rekomendasi urutan: utilities → services → models → widgets → screens.
	- Estimasi: per file 10–30 menit; total bergantung jumlah (perkiraan 3–8 jam). Owner: Junior (pakai IDE) atau AI (scripted). Acceptance: project compiles & `flutter analyze` tanpa error.

6. Refactor Import Paths & Perbaiki Breaks
	- Tugas: Perbarui semua import, gunakan refactor tool IDE agar aman. Jika menggunakan script/AI, lakukan search/replace dengan pola package imports (`package:limit_kuota/...`) bukan relative path.
	- Estimasi: 1–3 jam. Owner: Junior/AI. Acceptance: No unresolved imports; app runs.

7. Konsolidasi Widget & Komponen Reusable
	- Tugas: Pindahkan komponen kecil yang dipakai banyak tempat ke `lib/src/core/widgets/` dan document naming / props.
	- Estimasi: 2–4 jam. Owner: Junior. Acceptance: tidak ada duplikasi widget; review UX.

8. Pisahkan Layanan, Repository, DB
	- Tugas: Tempatkan `db_helper.dart` dan logika DB di `lib/src/core/data/` atau `lib/src/core/services/`; `network.dart` ke `lib/src/core/services/`. 
	- Estimasi: 2–4 jam. Owner: Junior (dibimbing). Acceptance: fungsionalitas DB/network tetap sama; tests terkait lulus.

9. Perbarui Struktur & Tes
	- Tugas: Pindahkan/ubah test paths sesuai layout; jalankan `flutter test` dan perbaiki import di test.
	- Estimasi: 1–3 jam. Owner: Junior. Acceptance: Semua test existing lulus.

10. Terapkan Linting & Formatting
	 - Tugas: Pastikan `analysis_options.yaml` konsisten; tambahkan `flutter_lints` atau aturan proyek; jalankan `dart format .` dan `flutter analyze`. Tambah pre-commit hook (format + analyze).
	 - Estimasi: 1–2 jam. Owner: Junior/DevOps. Acceptance: `dart format` idempotent; CI lint pass.

11. Setup CI Minimal
	 - Tugas: Tambahkan workflow CI (contoh GitHub Actions) yang menjalankan `flutter pub get`, `flutter analyze`, `flutter test` pada PR.
	 - Estimasi: 2–4 jam. Owner: DevOps / Senior. Acceptance: PR fail/pass sesuai hasil script.

12. Dokumentasi Migrasi & README
	 - Tugas: Perbarui `README.md` root dengan cara menjalankan, struktur folder singkat, aturan commit, dan file `docs/migration.md` yang menjelaskan mapping file lama→baru + contoh perintah `git mv`.
	 - Estimasi: 1–2 jam. Owner: Junior. Acceptance: Dokumentasi jelas dan bisa di-follow.

13. PR Review, Incremental Merge
	 - Tugas: Buat PR kecil per kelompok perubahan (assets, core, features, tests), minta review, jalankan CI, merge bertahap.
	 - Estimasi: per PR 1–2 jam review. Owner: Senior reviewer. Acceptance: Semua PR CI green dan reviewer approve.

## Checklist Ringkas (untuk eksekutor)
- Gunakan `git mv` untuk mempreserve history.
- Kerjakan per-PR kecil (maks 10–15 file/fitur).
- Jalankan `flutter analyze` dan `flutter test` sebelum push.
- Sertakan di PR: ringkasan perubahan, mapping file lama→baru, langkah verifikasi.
- Jika menggunakan AI untuk move+replace: lakukan PR manual review pertama sebelum mengotomatiskan sisanya.

