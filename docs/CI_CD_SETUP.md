# CI/CD Setup (GitHub Actions)

Quyidagi workflowlar qo'shildi:

- `.github/workflows/ci.yml`
  - Push/PR da `flutter analyze` va `flutter test` ishlaydi.
- `.github/workflows/cd-android.yml`
  - Tag (`v*`) yoki manual trigger (`workflow_dispatch`) da signed Android build qiladi.
  - AAB va APK artifact qilib saqlaydi.
  - Istasangiz manual trigger orqali Play Internal trackga ham yuboradi.

## GitHub Secrets

Repository -> Settings -> Secrets and variables -> Actions da quyidagilarni qo'shing:

1. `ANDROID_KEYSTORE_BASE64`
2. `ANDROID_KEYSTORE_PASSWORD`
3. `ANDROID_KEY_PASSWORD`
4. `ANDROID_KEY_ALIAS`
5. `PLAY_SERVICE_ACCOUNT_JSON` (faqat auto deploy uchun)

## Secretlarni tayyorlash

### 1) Keystoreni base64 qilish

```bash
base64 android/keystore/upload-keystore.jks | pbcopy
```

Nusxalangan qiymatni `ANDROID_KEYSTORE_BASE64` ga qo'ying.

### 2) Password va alias

`android/key.properties` ichidan quyilarni secretsga kiriting:

- `storePassword` -> `ANDROID_KEYSTORE_PASSWORD`
- `keyPassword` -> `ANDROID_KEY_PASSWORD`
- `keyAlias` -> `ANDROID_KEY_ALIAS`

### 3) Play service account JSON

- Google Cloud / Play Console'dan service-account JSON oling.
- JSON matnini to'liq holda `PLAY_SERVICE_ACCOUNT_JSON` secretiga qo'ying.

## Workflow ishlatish

### CI

- Push yoki PR ochilganda avtomatik ishlaydi.

### CD (manual)

- GitHub -> Actions -> `CD Android` -> `Run workflow`.
- `deploy_to_play = true` qilsangiz va `PLAY_SERVICE_ACCOUNT_JSON` bo'lsa,
  builddan keyin Internal trackga upload qiladi.

### CD (tag)

```bash
git tag v1.0.0
git push origin v1.0.0
```

Tag push bo'lsa build ishlaydi va artifactlar hosil bo'ladi.

## Eslatma

- `CD Android` workflow release signing secretlari bo'lmasa buildni aniq xabar bilan to'xtatadi.
- Play deploy faqat manual run (`workflow_dispatch`) va `deploy_to_play = true` bo'lganda ishlaydi.
