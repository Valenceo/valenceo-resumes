
%.docx :
	pandoc "$(@D)/print/index.html" -o "$@"
