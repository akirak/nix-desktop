{ extension
, name
, attrs
, writeTextFile
}:
writeTextFile {
  name = "${name}-systemd-${extension}";
  destination = "/share/systemd/user/${name}.${extension}";
  text = attrs.text;
}
