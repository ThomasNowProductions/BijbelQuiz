#!/bin/bash

FILES=$(grep -rl "strings\.AppStrings\." /home/thomas/Programming/BijbelQuiz/app/lib --include="*.dart" | cut -d: -f1 | sort -u | uniq)

for file in $FILES; do
  echo "Processing: $file"

  # Replace strings.AppStrings.appName with AppLocalizations.of(context).appName
  sed -i 's/strings\.AppStrings\.appName/AppLocalizations.of(context).appName/g' "$file"

  # Replace strings.AppStrings.apiErrorPrefix with AppLocalizations.of(context).apiErrorPrefix
  sed -i 's/strings\.AppStrings\.apiErrorPrefix/AppLocalizations.of(context).apiErrorPrefix/g' "$file"

  echo "Updated: $file"
done

echo "Replacement complete!"
