python3 negate.py leuven-theme.el > leuven-dark-theme.el

sed -i 's/leuven/leuven-dark/g' leuven-dark-theme.el # ensures emacs can detect and understand the file
sed -i 's/leuven-dark-dark/leuven-dark/g' leuven-dark-theme.el # prevents any overcorrection
sed -i 's/Awesome Emacs color theme on white background/Awesome Emacs color theme on dark background/' leuven-dark-theme.el
sed -i "s/(provide-theme 'leuven)/(provide-theme 'leuven-dark)/" leuven-dark-theme.el

echo "Colors inverted."
echo "You probably still need to change the theme's name in"
echo "the generated file.  This may be automated some day."
