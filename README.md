# opspulse-qa

OpsPulse AI reposunu (`carlsberk/OpsPulse-AI-Autonomous-Incident-Response-RCA-Agent`) kendi CI'ından bağımsız
olarak kontrol eden küçük test deposu. Amaç: gerçek hataları hızlıca görmek.

## İçerik

| Yol | Ne işe yarar |
| --- | --- |
| `.github/workflows/qa.yml` | Hedef repoyu çeker; ruff, format, mypy ve pytest'i Python 3.11 / 3.12 / 3.13'te çalıştırır. Bir adım düşse bile hepsi çalışır. |
| `qa_check.sh` | Aynı kontrolleri yerelde çalıştırır ve sonda PASS/FAIL tablosu verir. |
| `patches/fix-tests-and-coverage.patch` | `KeyError: 'labels'` testini düzeltir ve 24 yeni test ekler (772 → 796). |

## GitHub'da kullanım

1. Bu klasörün içeriğini yeni boş repoya push et.
2. **Actions → QA check → Run workflow**.
   - `apply_patch` kapalı: hedef repo olduğu gibi test edilir (şu an `KeyError: 'labels'` ile 1 test düşer).
   - `apply_patch` açık: yama uygulanıp test edilir (hepsi yeşil olmalı).
3. Hedef repo özel ise workflow'a `token` verilmesi gerekir. Şu an repo herkese açık varsayılıyor.

## Yerelde kullanım

```bash
git clone https://github.com/carlsberk/OpsPulse-AI-Autonomous-Incident-Response-RCA-Agent
./qa_check.sh ./OpsPulse-AI-Autonomous-Incident-Response-RCA-Agent                 # olduğu gibi
./qa_check.sh ./OpsPulse-AI-Autonomous-Incident-Response-RCA-Agent --apply-patch   # yamayla
```

Windows'ta betiği Git Bash ya da WSL içinde çalıştır.
