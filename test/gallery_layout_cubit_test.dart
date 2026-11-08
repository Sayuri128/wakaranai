import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('defaults to the comfortable grid', () async {
    final GalleryLayoutCubit cubit = GalleryLayoutCubit();
    await cubit.init();
    expect(cubit.state, GalleryLayout.comfortable);
    await cubit.close();
  });

  test('cycles through every layout and wraps around', () async {
    final GalleryLayoutCubit cubit = GalleryLayoutCubit();
    await cubit.cycle();
    expect(cubit.state, GalleryLayout.compact);
    await cubit.cycle();
    expect(cubit.state, GalleryLayout.list);
    await cubit.cycle();
    expect(cubit.state, GalleryLayout.comfortable);
    await cubit.close();
  });

  test('restores the last chosen layout', () async {
    final GalleryLayoutCubit first = GalleryLayoutCubit();
    await first.select(GalleryLayout.list);
    await first.close();

    final GalleryLayoutCubit second = GalleryLayoutCubit();
    await second.init();
    expect(second.state, GalleryLayout.list);
    await second.close();
  });

  test('falls back to the comfortable grid for an unknown stored name', () {
    expect(galleryLayoutFromName('mosaic'), GalleryLayout.comfortable);
    expect(galleryLayoutFromName(null), GalleryLayout.comfortable);
  });

  test('keeps the library layout separate from the gallery layout', () async {
    final GalleryLayoutCubit gallery = GalleryLayoutCubit();
    final LibraryLayoutCubit library = LibraryLayoutCubit();
    await gallery.select(GalleryLayout.compact);
    await library.select(GalleryLayout.list);
    await gallery.close();
    await library.close();

    final GalleryLayoutCubit restoredGallery = GalleryLayoutCubit();
    final LibraryLayoutCubit restoredLibrary = LibraryLayoutCubit();
    await restoredGallery.init();
    await restoredLibrary.init();
    expect(restoredGallery.state, GalleryLayout.compact);
    expect(restoredLibrary.state, GalleryLayout.list);
    await restoredGallery.close();
    await restoredLibrary.close();
  });
}
