# magic_slide_ppt(BLoC + Supabase + HTTP)



## What it is
A simple Flutter app demonstrating:
- Signup/Login with Supabase
- Persistent auth
- MagicSlides Topic → PPT integration using the public API
- PDF preview and download
- BLoC pattern (flutter_bloc)

## How to run
1. Flutter SDK (>=3.0)
2. Replace values in `lib/core/constants.dart`:
    - `SUPABASE_URL` and `SUPABASE_ANON_KEY`
    - `MAGicslIDES_ACCESS_ID` with the provided access id
3. `flutter pub get`
4. Run `flutter run` (or build an APK with `flutter build apk`)

## Database used
- **Supabase** (Auth only).
- **Confirm your signup**
Follow this link to confirm your user:

Confirm your mail

## Architecture
- BLoC for state management (`AuthBloc`, `GenerateBloc`)
- Repositories for external services (`AuthRepository`, `MagicSlidesRepository`)
- Services for downloads and API calls
- Simple screens for login, signup, home and result

## Final notes / places to customized(Why This Project Was Customized?)

The **official MagicSlide Api provided for testing exceeded install limits** and could not run on the device.  
Because of that:
- The Api was **not used** in PresentationRepositoryImpl i used rootBundle.loadString('assets/z.json');
- Instead, a **custom generator UI + API integration** was developed from scratch 

## Known issues / notes 
- This sample expects MagicSlides to return a direct file URL in `data.url`.
- PDF preview works only if the generated file is PDF.
- On Android, storage permission is requested for download; behavior differs across OS versions.
  
## demo Folder 
- you see the demo App
## GitHub Repository

You can find the full project source here:  
**https://github.com/poorna-nag/magic_slide_ppt.git**
