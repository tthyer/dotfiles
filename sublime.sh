# Package control for Sublime
if [[ ! -f "$HOME/Library/Application Support/Sublime Text 3/Installed Packages/Package Control.sublime-package" ]]; then
  echo "Installing package control for Sublime. This will take effect when Sublime restarts."
  wget https://packagecontrol.io/Package%20Control.sublime-package --directory-prefix="$HOME/Library/Application Support/Sublime Text 3/Installed Packages/"
  echo "Done."
else
  echo "Package control for Sublime has already been installed."
fi

sublime_things_to_do=(
  "Pretty JSON"
  "Dockerfile Syntax Highlighting"
  "RawLineEdit"
  "MarkdownPreview"
  "SublimeLinter"
  "SublimeLinter-json"
  "SublimeLinter-flake8"
  )
echo "Things to install for Sublime through Package Control:"
for i in "${sublime_things_to_do[@]}"
do
  echo $i
done
