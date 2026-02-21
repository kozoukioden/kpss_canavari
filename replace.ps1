$content = Get-Content -Path "colab_notebooks\04_rag_testing.ipynb" -Raw
$content = $content.Replace('AIzaSyAxZ2TFVRz9eorr_SAQ_kP3-PhKhtCZoAE', 'YOUR_GEMINI_API_KEY_HERE')
Set-Content -Path "colab_notebooks\04_rag_testing.ipynb" -Value $content -NoNewline
