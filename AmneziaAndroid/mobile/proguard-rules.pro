# Keep line numbers for readable crash reports (source file name is obfuscated).
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# kotlinx.serialization models live in :core and are covered by its consumer rules.
# ML Kit barcode scanning ships its own consumer rules.
